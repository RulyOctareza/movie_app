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
  });

  group('Advanced Database Operations', () {
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
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
    });

    test('should properly handle database upgrade path', () async {
      // arrange
      await databaseHelper.close();
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, DBConstants.databaseName));

      // Create a v1 database with sample data
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

          // Insert test data
          await db.insert(DBConstants.watchlistTable, {
            'id': 1,
            'name': 'Test Show',
            'overview': 'Test Overview',
            'poster_path': '/test.jpg',
            'vote_average': 8.5
          });
        },
      );
      await oldDb.close();

      // Get a new database instance (should trigger upgrade)
      final db = await databaseHelper.database;

      // Check if new columns exist
      final table = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', DBConstants.watchlistTable]);
      final createScript = table.first['sql'] as String;

      expect(createScript.toLowerCase(), contains('number_of_seasons'));
      expect(createScript.toLowerCase(), contains('number_of_episodes'));
      expect(createScript.toLowerCase(), contains('seasons'));

      // Verify old data is preserved
      final result = await db.query(DBConstants.watchlistTable);
      expect(result.length, 1);
      expect(result.first['name'], 'Test Show');

      // cleanup
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
    });
  });
}
