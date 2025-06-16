import 'dart:io';
import 'package:expert_flutter_dicoding/core/database_helper.dart';
import 'package:expert_flutter_dicoding/core/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper databaseHelper;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() {
    databaseFactory = databaseFactoryFfi;
    databaseHelper = DatabaseHelper.instance;
  });

  tearDown(() async {
    await databaseHelper.close();
    final dbPath = await getDatabasesPath();
    final dbFile = File(join(dbPath, DBConstants.databaseName));
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  });

  group('Database Creation', () {
    test('should create database with all required columns', () async {
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
      expect(createScript.toLowerCase(), contains('number_of_seasons integer'));
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

      // Create a read-only directory to cause creation error
      await Directory(dbFile.parent.path).create(recursive: true);
      await Process.run('chmod', ['444', dbFile.parent.path]);

      // act & assert
      expect(() async {
        await databaseHelper.database;
      }, throwsA(isA<Exception>()));

      // cleanup
      await Process.run('chmod', ['744', dbFile.parent.path]);
    });
  });

  group('Database Upgrade', () {
    test('should successfully upgrade from v1 to v2', () async {
      // arrange
      await databaseHelper.close();
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, DBConstants.databaseName));

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

      expect(createScript.toLowerCase(), contains('number_of_seasons integer'));
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

        // Insert invalid data that will cause upgrade validation to fail
        await db.rawInsert('''
            INSERT INTO ${DBConstants.watchlistTable} (id, name, overview, poster_path, vote_average)
            VALUES (1, 'Test Show', 'Overview', '/test.jpg', 'not-a-number')
          ''');
      });
      await oldDb.close();

      // act & assert
      expect(() async {
        await databaseHelper.database;
      }, throwsA(isA<Exception>()));
    });
  });
}
