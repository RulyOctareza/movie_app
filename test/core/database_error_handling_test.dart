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

  group('Database Error Handling', () {
    test('should handle double close gracefully', () async {
      // arrange
      await databaseHelper.database; // ensure database is open
      
      // act & assert
      await databaseHelper.close(); // first close
      await databaseHelper.close(); // second close should not throw
    });

    test('should handle database initialization errors', () async {
      // arrange
      await databaseHelper.close();
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, DBConstants.databaseName));
      
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
      
      // Create a corrupted database file
      await dbFile.writeAsString('corrupt content');

      // act & assert
      expect(() async {
        await databaseHelper.database;
      }, throwsA(isA<Exception>()));
    });

    test('should handle multiple database initialization attempts', () async {
      // arrange
      final db1 = await databaseHelper.database;
      
      // act
      final db2 = await databaseHelper.database;
      
      // assert
      expect(identical(db1, db2), isTrue);
    });

    test('should handle database corruption during upgrade', () async {
      // arrange
      await databaseHelper.close();
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, DBConstants.databaseName));
      
      // Create v1 database
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

      // Corrupt the database
      await dbFile.writeAsString('corrupt content');

      // act & assert
      expect(() async {
        await databaseHelper.database;
      }, throwsA(isA<Exception>()));
    });

    test('should handle failed database upgrade gracefully', () async {
      // arrange
      await databaseHelper.close();
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, DBConstants.databaseName));
      
      // Create v1 database with valid schema but corrupt data
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
          
          // Insert invalid data that will cause upgrade to fail
          await db.execute('''
            INSERT INTO ${DBConstants.watchlistTable} (id, name, overview, poster_path, vote_average)
            VALUES (1, null, null, null, 'invalid')
          ''');
        },
      );
      await oldDb.close();

      // act & assert
      expect(() async {
        await databaseHelper.database;
      }, throwsA(isA<Exception>()));
    });
  });
}
