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

    // test('should handle errors during database upgrade', () async {
    //   // Initialize with version 1
    //   final helperV1 = DatabaseHelper(dbName: 'ditonton.db', dbVersion: 1);
    //   await helperV1.database;
    //   await helperV1.close();

    //   // Create a helper that will cause an error during upgrade
    //   // For example, by trying to add a column that already exists in a bad way
    //   // This requires a custom DatabaseHelper that can simulate upgrade errors
    //   final mockDatabase = MockDatabase();
    //   final helperV2WithError = DatabaseHelper(
    //     dbName: 'ditonton.db',
    //     dbVersion: 2,
    //     // This is a simplified way to inject error simulation
    //     // A more robust way would be to mock the database actions
    //     // For this test, we assume _onUpgrade might throw if something goes wrong
    //     // and the DatabaseHelper is designed to catch and rethrow or handle it.
    //   );

    //   // We expect an exception if the upgrade process itself throws one.
    //   // The exact exception type and message depend on DatabaseHelper's error handling.
    //   expect(
    //     () async => await helperV2WithError.database,
    //     throwsA(isA<Exception>()), // Or a more specific DatabaseException
    //     reason: 'DatabaseHelper should throw an exception if _onUpgrade fails.'
    //   );
    // });

    // test('should properly handle database upgrade path', () async {
    //   // V1: Initial schema
    //   final helperV1 = DatabaseHelper(dbName: 'ditonton.db', dbVersion: 1);
    //   Database? dbV1 = await helperV1.database;
    //   expect(await dbV1!.getVersion(), 1);
    //   // Verify V1 schema (e.g., watchlist table exists without new V2 columns)
    //   var tablesV1 = await dbV1.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='watchlist'");
    //   expect(tablesV1.isNotEmpty, isTrue);
    //   var columnsV1 = await dbV1.rawQuery("PRAGMA table_info(watchlist)");
    //   expect(columnsV1.any((col) => col['name'] == 'isMovie'), isTrue); // V1 column
    //   expect(columnsV1.any((col) => col['name'] == 'number_of_seasons'), isFalse); // V2 column should not exist
    //   await helperV1.close();

    //   // V2: Upgrade to add number_of_seasons
    //   final helperV2 = DatabaseHelper(dbName: 'ditonton.db', dbVersion: 2);
    //   Database? dbV2 = await helperV2.database;
    //   expect(await dbV2!.getVersion(), 2);
    //   var columnsV2 = await dbV2.rawQuery("PRAGMA table_info(watchlist)");
    //   expect(columnsV2.any((col) => col['name'] == 'isMovie'), isTrue);
    //   expect(columnsV2.any((col) => col['name'] == 'number_of_seasons'), isTrue); // V2 column should exist
    //   await helperV2.close();

    //   // V3: Upgrade to add another_new_column (hypothetical)
    //   final helperV3 = DatabaseHelper(dbName: 'ditonton.db', dbVersion: 3);
    //   Database? dbV3 = await helperV3.database;
    //   expect(await dbV3!.getVersion(), 3);
    //   var columnsV3 = await dbV3.rawQuery("PRAGMA table_info(watchlist)");
    //   expect(columnsV3.any((col) => col['name'] == 'isMovie'), isTrue);
    //   expect(columnsV3.any((col) => col['name'] == 'number_of_seasons'), isTrue);
    //   expect(columnsV3.any((col) => col['name'] == 'another_new_column'), isTrue); // V3 column
    //   await helperV3.close();
    // });
  });
}
