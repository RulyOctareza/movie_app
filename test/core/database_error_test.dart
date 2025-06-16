import 'dart:io';
import 'dart:typed_data';
import 'package:expert_flutter_dicoding/core/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../dummy_data/dummy_objects.dart';
import 'package:expert_flutter_dicoding/core/constants.dart';

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

  group('Database Error Handling', () {
    test('should handle double close gracefully', () async {
      // arrange
      await databaseHelper.database; // ensure database is open

      // act & assert
      await databaseHelper.close(); // first close
      await databaseHelper.close(); // second close should not throw
    });

    test('should handle database upgrade corruption', () async {
      // arrange
      await databaseHelper.close();
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, DBConstants.databaseName));

      // Create v1 database with test data
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

          await db.insert(DBConstants.watchlistTable, testTvSeriesMap);
        },
      );
      await oldDb.close();

      // Corrupt the database during upgrade
      await dbFile.writeAsString('corrupt');

      // act & assert
      expect(() async {
        await databaseHelper.database;
      }, throwsA(isA<Exception>()));

      // cleanup
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
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

      // Create a corrupted v1 database
      await dbFile.writeAsString('''
        PRAGMA user_version = 1;
        CREATE TABLE corrupt_table (
          id INTEGER PRIMARY
        '''); // intentionally malformed SQL

      // act & assert
      expect(() async {
        await databaseHelper.database;
      }, throwsA(isA<Exception>()));

      // cleanup
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
    });
  });
}

TestDatabaseFactory createErrorFactory(String path) {
  return TestDatabaseFactory()..setDatabasePath(path);
}

class TestDatabaseFactory implements DatabaseFactory {
  late String _path;

  void setDatabasePath(String path) {
    _path = path;
  }

  @override
  Future<Database> openDatabase(String path,
      {OpenDatabaseOptions? options}) async {
    throw Exception('Failed to open database');
  }

  @override
  Future<String> getDatabasesPath() async => _path;

  @override
  Future<bool> databaseExists(String path) {
    // TODO: implement databaseExists
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDatabase(String path) {
    // TODO: implement deleteDatabase
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readDatabaseBytes(String path) {
    // TODO: implement readDatabaseBytes
    throw UnimplementedError();
  }

  @override
  Future<void> setDatabasesPath(String path) {
    // TODO: implement setDatabasesPath
    throw UnimplementedError();
  }

  @override
  Future<void> writeDatabaseBytes(String path, Uint8List bytes) {
    // TODO: implement writeDatabaseBytes
    throw UnimplementedError();
  }
}

@override
Future<bool> databaseExists(String path) {
  // TODO: implement databaseExists
  throw UnimplementedError();
}

@override
Future<void> deleteDatabase(String path) {
  // TODO: implement deleteDatabase
  throw UnimplementedError();
}

@override
Future<Uint8List> readDatabaseBytes(String path) {
  // TODO: implement readDatabaseBytes
  throw UnimplementedError();
}

@override
Future<void> setDatabasesPath(String path) {
  // TODO: implement setDatabasesPath
  throw UnimplementedError();
}

@override
Future<void> writeDatabaseBytes(String path, Uint8List bytes) {
  // TODO: implement writeDatabaseBytes
  throw UnimplementedError();
}
