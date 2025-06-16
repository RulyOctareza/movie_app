import 'package:expert_flutter_dicoding/core/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:expert_flutter_dicoding/core/constants.dart';

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
    databaseFactory =
        null; // This will cause an error when trying to open the database

    // act & assert
    expect(() async {
      await databaseHelper.database;
    }, throwsException);
  });

  test('should add new columns when upgrading database version', () async {
    final oldPath = await getDatabasesPath();
    final oldDatabasePath = join(oldPath, 'old_${DBConstants.databaseName}');

    // Create database with old schema (version 1)
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
          await db.execute('ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN number_of_seasons INTEGER');
          await db.execute('ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN number_of_episodes INTEGER');
          await db.execute('ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN seasons TEXT');
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
          await db.execute('ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN number_of_seasons INTEGER');
          await db.execute('ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN number_of_episodes INTEGER');
          await db.execute('ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN seasons TEXT');
        }
      },
    );

    // assert
    final table = await newDb.query('sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', DBConstants.watchlistTable]);
    final createScript = table.first['sql'] as String;

    expect(createScript.toLowerCase(), contains('number_of_seasons integer'));
    expect(createScript.toLowerCase(), contains('number_of_episodes integer'));
    expect(createScript.toLowerCase(), contains('seasons text'));

    await newDb.close();
    await deleteDatabase(oldDatabasePath);
  });
}
