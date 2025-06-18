// test/core/database_error_handling_test.dart

import 'dart:io';
import 'package:expert_flutter_dicoding/core/database_helper.dart';
import 'package:expert_flutter_dicoding/core/constants.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper databaseHelper;
  late String dbPath;

  flutter_test.setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dbPath = await getDatabasesPath();
  });

  flutter_test.setUp(() {
    databaseHelper = DatabaseHelper.instance;
  });

  flutter_test.tearDown(() async {
    await databaseHelper.close();
    final dbFile = File(p.join(dbPath, DBConstants.databaseName));
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  });

  flutter_test.group('Database Error Handling', () {
    flutter_test.test('should handle double close gracefully', () async {
      // Arrange
      final db = await databaseHelper.database;
      flutter_test.expect(db.isOpen, flutter_test.isTrue);

      // Act
      await databaseHelper.close();
      await databaseHelper.close(); // Panggilan kedua tidak boleh error

      // Assert
      // Memanggil database lagi akan membuat instance baru
      final newDb = await databaseHelper.database;
      flutter_test.expect(newDb.isOpen, flutter_test.isTrue);
      flutter_test.expect(identical(db, newDb), flutter_test.isFalse,
          reason: "A new database instance should be created after closing.");
    });

    flutter_test.test('should handle multiple database initialization attempts',
        () async {
      // Arrange
      final db1 = await databaseHelper.database;

      // Act
      final db2 = await databaseHelper.database;

      // Assert
      flutter_test.expect(identical(db1, db2), flutter_test.isTrue);
    });
  });
}
