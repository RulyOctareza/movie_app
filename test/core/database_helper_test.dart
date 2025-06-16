import 'package:expert_flutter_dicoding/core/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
