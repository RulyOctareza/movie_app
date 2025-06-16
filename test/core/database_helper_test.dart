import 'dart:io';
import 'dart:typed_data';
import 'package:expert_flutter_dicoding/core/database_helper.dart';
import 'package:expert_flutter_dicoding/core/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mockito/mockito.dart';

// Mock class for database factory
class MockDatabaseFactory implements DatabaseFactory {
  final bool throwError;

  MockDatabaseFactory({this.throwError = false});

  @override
  Future<Database> openDatabase(String path, {OpenDatabaseOptions? options}) {
    if (throwError) {
      throw Exception('Error opening database');
    }
    return databaseFactoryFfi.openDatabase(path, options: options);
  }

  @override
  Future<void> deleteDatabase(String path) {
    return databaseFactoryFfi.deleteDatabase(path);
  }

  @override
  Future<bool> databaseExists(String path) {
    return databaseFactoryFfi.databaseExists(path);
  }

  @override
  Future<String> getDatabasesPath() {
    return databaseFactoryFfi.getDatabasesPath();
  }

  @override
  Future<void> setDatabasesPath(String path) {
    return databaseFactoryFfi.setDatabasesPath(path);
  }

  @override
  Future<Uint8List> readDatabaseBytes(String path) {
    // TODO: implement readDatabaseBytes
    throw UnimplementedError();
  }

  @override
  Future<void> writeDatabaseBytes(String path, Uint8List bytes) {
    // TODO: implement writeDatabaseBytes
    throw UnimplementedError();
  }
}

void main() {
  late DatabaseHelper databaseHelper;

  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
  });

  setUp(() {
    // Change the default factory for testing
    databaseFactory = databaseFactoryFfi;
    databaseHelper = DatabaseHelper.instance;
  });

  tearDown(() async {
    await databaseHelper.close();
  });

  test('should create database when initialized', () async {
    // act
    final db = await databaseHelper.database;

    // assert
    expect(db, isNotNull);
    expect(db.isOpen, true);
  });

  test('should maintain singleton instance', () async {
    // act
    final instance1 = DatabaseHelper.instance;
    final instance2 = DatabaseHelper.instance;

    // assert
    expect(identical(instance1, instance2), true);
  });

  test('should create watchlist table when database is created', () async {
    // act
    final db = await databaseHelper.database;

    // assert
    final tables = await db
        .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
    final tableNames = tables.map((e) => e['name'] as String).toList();
    expect(tableNames, contains(DBConstants.watchlistTable));
  });

  test('watchlist table should have all required columns', () async {
    // act
    final db = await databaseHelper.database;

    // assert
    final table = await db.query('sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', DBConstants.watchlistTable]);
    final createScript = table.first['sql'] as String;

    expect(createScript.toLowerCase(), contains('id integer primary key'));
    expect(createScript.toLowerCase(), contains('name text'));
    expect(createScript.toLowerCase(), contains('overview text'));
    expect(createScript.toLowerCase(), contains('poster_path text'));
    expect(createScript.toLowerCase(), contains('vote_average real'));
    expect(createScript.toLowerCase(), contains('number_of_seasons integer'));
    expect(createScript.toLowerCase(), contains('number_of_episodes integer'));
    expect(createScript.toLowerCase(), contains('seasons text'));
  });

  test('should handle database initialization errors', () async {
    // arrange
    await databaseHelper.close();

    // Set an invalid path that will cause initialization to fail
    final invalidPath = join('invalid', 'path', 'that', 'doesnt', 'exist');
    when(getDatabasesPath()).thenAnswer((_) async => invalidPath);

    // act & assert
    expect(() async {
      await databaseHelper.database;
    }, throwsA(isA<Exception>()));
  });

  test('should throw exception when database initialization fails', () async {
    // arrange
    await databaseHelper.close();
    final oldFactory = databaseFactory;
    databaseFactory = MockDatabaseFactory(throwError: true);

    // act & assert
    expect(() async {
      await databaseHelper.database;
    }, throwsA(isA<Exception>()));

    // cleanup
    databaseFactory = oldFactory;
  });

  group('Database Creation and Upgrade', () {
    test('should create new database with correct schema', () async {
      // arrange
      await databaseHelper.close();
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, DBConstants.databaseName));
      if (await dbFile.exists()) {
        await dbFile.delete();
      }

      // act
      final db = await databaseHelper.database;

      // assert
      final tables = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', DBConstants.watchlistTable]);
      final createScript = tables.first['sql'] as String;

      expect(createScript.toLowerCase(), contains('id integer primary key'));
      expect(createScript.toLowerCase(), contains('name text'));
      expect(createScript.toLowerCase(), contains('overview text'));
      expect(createScript.toLowerCase(), contains('poster_path text'));
      expect(createScript.toLowerCase(), contains('vote_average real'));
      expect(createScript.toLowerCase(), contains('number_of_seasons integer'));
      expect(
          createScript.toLowerCase(), contains('number_of_episodes integer'));
      expect(createScript.toLowerCase(), contains('seasons text'));
    });

    test('should properly upgrade database from v1 to v2', () async {
      // arrange
      await databaseHelper.close();
      final dbPath = await getDatabasesPath();
      final oldDatabasePath =
          join(dbPath, 'old_test_${DBConstants.databaseName}');

      // Create v1 database
      final oldDb = await openDatabase(
        oldDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE ${DBConstants.watchlistTable} (
            id INTEGER PRIMARY KEY,
            name TEXT,
            overview TEXT,
            poster_path TEXT,
            vote_average REAL
          )
        ''');
        },
      );

      // Insert test data
      await oldDb.insert(DBConstants.watchlistTable, {
        'id': 1,
        'name': 'Test',
        'overview': 'Test Overview',
        'poster_path': '/test.jpg',
        'vote_average': 8.0,
      });

      await oldDb.close();

      // Upgrade database to version 2
      final newDb = await openDatabase(
        oldDatabasePath,
        version: 2,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
                'ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN number_of_seasons INTEGER');
            await db.execute(
                'ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN number_of_episodes INTEGER');
            await db.execute(
                'ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN seasons TEXT');
          }
        },
      );

      // Verify new columns exist
      final table = await newDb.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', DBConstants.watchlistTable]);
      final createScript = table.first['sql'] as String;

      expect(createScript.toLowerCase(), contains('number_of_seasons'));
      expect(createScript.toLowerCase(), contains('number_of_episodes'));
      expect(createScript.toLowerCase(), contains('seasons'));

      // Verify old data is preserved
      final result = await newDb.query(DBConstants.watchlistTable);
      expect(result.length, 1);
      expect(result.first['name'], 'Test');

      await newDb.close();
      await deleteDatabase(oldDatabasePath);
    });

    test('should add new columns when upgrading from version 1 to version 2',
        () async {
      // arrange
      final oldPath = await getDatabasesPath();
      final oldDatabasePath = join(oldPath, 'old_${DBConstants.databaseName}');

      // Create version 1 database
      final oldDb = await openDatabase(
        oldDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE ${DBConstants.watchlistTable} (
            id INTEGER PRIMARY KEY,
            name TEXT,
            overview TEXT,
            poster_path TEXT,
            vote_average REAL
          );
        ''');
        },
      );
      await oldDb.close();

      // act
      final newDb = await openDatabase(
        oldDatabasePath,
        version: DBConstants.databaseVersion,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE ${DBConstants.watchlistTable} (
            id INTEGER PRIMARY KEY,
            name TEXT,
            overview TEXT,
            poster_path TEXT,
            vote_average REAL,
            number_of_seasons INTEGER,
            number_of_episodes INTEGER,
            seasons TEXT
          )
        ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
                'ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN number_of_seasons INTEGER');
            await db.execute(
                'ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN number_of_episodes INTEGER');
            await db.execute(
                'ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN seasons TEXT');
          }
        },
      );

      // assert
      final table = await newDb.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', DBConstants.watchlistTable]);
      final createScript = table.first['sql'] as String;

      expect(createScript.toLowerCase(), contains('number_of_seasons integer'));
      expect(
          createScript.toLowerCase(), contains('number_of_episodes integer'));
      expect(createScript.toLowerCase(), contains('seasons text'));

      await newDb.close();
      await deleteDatabase(oldDatabasePath);
    });

    test('singleton pattern should work correctly', () async {
      // act
      final instance1 = DatabaseHelper.instance;
      final instance2 = DatabaseHelper.instance;

      // assert
      expect(identical(instance1, instance2), true);
    });

    test('close should clear database and instance', () async {
      // arrange
      final db = await databaseHelper.database;
      expect(db.isOpen, true);

      // act
      await databaseHelper.close();

      // assert
      // Getting database again should create a new instance
      final newDb = await databaseHelper.database;
      expect(identical(db, newDb), false);
    });

    test('should handle errors during database upgrade', () async {
      // arrange
      await databaseHelper.close();
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, DBConstants.databaseName));

      // Create a v1 database
      final oldDb = await openDatabase(
        dbFile.path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE ${DBConstants.watchlistTable} (
            id INTEGER PRIMARY KEY,
            name TEXT,
            overview TEXT,
            poster_path TEXT,
            vote_average REAL
          )
        ''');
        },
      );
      await oldDb.close();

      // Corrupt the database to cause upgrade error
      await dbFile.writeAsString('corrupted content');

      // act & assert
      expect(() async {
        await databaseHelper.database;
      }, throwsA(isA<Exception>()));

      // cleanup
      await dbFile.delete();
    });

    group('Database Creation', () {
      test('should create database with all required columns', () async {
        // arrange
        await databaseHelper.close();
        final dbPath = await getDatabasesPath();
        final dbFile = File(join(dbPath, DBConstants.databaseName));
        if (await dbFile.exists()) {
          await dbFile.delete();
        }

        // act
        final db = await databaseHelper.database;

        // assert
        final table = await db.query('sqlite_master',
            where: 'type = ? AND name = ?',
            whereArgs: ['table', DBConstants.watchlistTable]);
        final createScript = table.first['sql'] as String;

        // Verify all required columns are present
        expect(createScript.toLowerCase(), contains('id integer primary key'));
        expect(createScript.toLowerCase(), contains('name text'));
        expect(createScript.toLowerCase(), contains('overview text'));
        expect(createScript.toLowerCase(), contains('poster_path text'));
        expect(createScript.toLowerCase(), contains('vote_average real'));
        expect(
            createScript.toLowerCase(), contains('number_of_seasons integer'));
        expect(
            createScript.toLowerCase(), contains('number_of_episodes integer'));
        expect(createScript.toLowerCase(), contains('seasons text'));

        // Test inserting data to verify table structure
        final id = await db.insert(DBConstants.watchlistTable, {
          'name': 'Test Show',
          'overview': 'Test Overview',
          'poster_path': '/test.jpg',
          'vote_average': 8.5,
          'number_of_seasons': 2,
          'number_of_episodes': 20,
          'seasons': '["Season 1", "Season 2"]'
        });

        expect(id, greaterThan(0));

        // Query the inserted data
        final result = await db.query(DBConstants.watchlistTable);
        expect(result.length, 1);
        expect(result.first['name'], 'Test Show');
        expect(result.first['number_of_seasons'], 2);
        expect(result.first['number_of_episodes'], 20);
        expect(result.first['seasons'], '["Season 1", "Season 2"]');
      });

      test('should handle database creation errors gracefully', () async {
        // arrange
        await databaseHelper.close();
        final dbPath = await getDatabasesPath();
        final dbFile = File(join(dbPath, DBConstants.databaseName));
        if (await dbFile.exists()) {
          await dbFile.delete();
        }

        // Create a directory with the same name to cause creation error
        await Directory(dbFile.path).create(recursive: true);

        // act & assert
        expect(() async {
          await databaseHelper.database;
        }, throwsA(isA<Exception>()));

        // cleanup
        await Directory(dbFile.path).delete();
      });
    });

    group('Database Upgrade', () {
      test('should successfully upgrade from v1 to v2', () async {
        // arrange
        await databaseHelper.close();
        final dbPath = await getDatabasesPath();
        final dbFile = File(join(dbPath, DBConstants.databaseName));

        if (await dbFile.exists()) {
          await dbFile.delete();
        }

        // Create v1 database with test data
        final oldDb = await openDatabase(dbFile.path, version: 1,
            onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${DBConstants.watchlistTable} (
              id INTEGER PRIMARY KEY,
              name TEXT,
              overview TEXT,
              poster_path TEXT,
              vote_average REAL
            )
          ''');

          // Insert test data
          await db.insert(DBConstants.watchlistTable, {
            'id': 1,
            'name': 'Old Test Show',
            'overview': 'Test Overview',
            'poster_path': '/test.jpg',
            'vote_average': 8.5
          });
        });
        await oldDb.close();

        // Get database instance (triggers upgrade)
        final db = await databaseHelper.database;

        // Verify table structure
        final table = await db.query('sqlite_master',
            where: 'type = ? AND name = ?',
            whereArgs: ['table', DBConstants.watchlistTable]);
        final createScript = table.first['sql'] as String;

        expect(
            createScript.toLowerCase(), contains('number_of_seasons integer'));
        expect(
            createScript.toLowerCase(), contains('number_of_episodes integer'));
        expect(createScript.toLowerCase(), contains('seasons text'));

        // Verify old data is preserved
        final result = await db.query(DBConstants.watchlistTable);
        expect(result.length, 1);
        expect(result.first['name'], 'Old Test Show');
        expect(result.first['vote_average'], 8.5);

        // Verify new columns can be updated
        await db.update(
            DBConstants.watchlistTable,
            {
              'number_of_seasons': 3,
              'number_of_episodes': 30,
              'seasons': '["S1","S2","S3"]'
            },
            where: 'id = ?',
            whereArgs: [1]);

        final updatedResult = await db.query(DBConstants.watchlistTable);
        expect(updatedResult.first['number_of_seasons'], 3);
        expect(updatedResult.first['number_of_episodes'], 30);
        expect(updatedResult.first['seasons'], '["S1","S2","S3"]');
      });

      test('should handle upgrade errors when old data is invalid', () async {
        // arrange
        await databaseHelper.close();
        final dbPath = await getDatabasesPath();
        final dbFile = File(join(dbPath, DBConstants.databaseName));

        if (await dbFile.exists()) {
          await dbFile.delete();
        }

        // Create v1 database with invalid data
        final oldDb = await openDatabase(dbFile.path, version: 1,
            onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${DBConstants.watchlistTable} (
              id INTEGER PRIMARY KEY,
              name TEXT,
              overview TEXT,
              poster_path TEXT,
              vote_average REAL
            )
          ''');

          // Insert invalid data
          await db.rawInsert('''
            INSERT INTO ${DBConstants.watchlistTable} (id, name, overview, poster_path, vote_average)
            VALUES (1, 'Test Show', 'Overview', '/test.jpg', 'invalid')
          ''');
        });
        await oldDb.close();

        // act & assert
        expect(() async {
          await databaseHelper.database;
        }, throwsA(isA<Exception>()));
      });
    });
  });
}
