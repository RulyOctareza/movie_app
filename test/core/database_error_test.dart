import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:expert_flutter_dicoding/core/database_helper.dart';

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

    test('should handle multiple database initialization attempts', () async {
      // arrange
      final db1 = await databaseHelper.database;

      // act
      final db2 = await databaseHelper.database;

      // assert
      expect(identical(db1, db2), isTrue);
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
    return databaseFactoryFfi.databaseExists(path);
  }

  @override
  Future<void> deleteDatabase(String path) {
    return databaseFactoryFfi.deleteDatabase(path);
  }

  @override
  Future<Uint8List> readDatabaseBytes(String path) {
    return databaseFactoryFfi.readDatabaseBytes(path);
  }

  @override
  Future<void> setDatabasesPath(String path) {
    return databaseFactoryFfi.setDatabasesPath(path);
  }

  @override
  Future<void> writeDatabaseBytes(String path, Uint8List bytes) {
    return databaseFactoryFfi.writeDatabaseBytes(path, bytes);
  }
}

@override
Future<bool> databaseExists(String path) {
  return databaseFactoryFfi.databaseExists(path);
}

@override
Future<void> deleteDatabase(String path) {
  return databaseFactoryFfi.deleteDatabase(path);
}

@override
Future<Uint8List> readDatabaseBytes(String path) {
  return databaseFactoryFfi.readDatabaseBytes(path);
}

@override
Future<void> setDatabasesPath(String path) {
  return databaseFactoryFfi.setDatabasesPath(path);
}

@override
Future<void> writeDatabaseBytes(String path, Uint8List bytes) {
  return databaseFactoryFfi.writeDatabaseBytes(path, bytes);
}
