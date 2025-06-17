import 'dart:io';
import 'package:expert_flutter_dicoding/core/constants.dart';
import 'package:expert_flutter_dicoding/core/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper databaseHelper;
  late String databasesPathString;
  late String targetDbPath;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasesPathString = await getDatabasesPath();
    targetDbPath = p.join(databasesPathString, DBConstants.databaseName);
  });

  setUp(() async {
    await DatabaseHelper.instance.close();
    databaseHelper = DatabaseHelper.instance;

    final dbFile = File(targetDbPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    final dbAsDirectory = Directory(targetDbPath);
    if (await dbAsDirectory.exists()) {
      await dbAsDirectory.delete(recursive: true);
    }
  });

  tearDown(() async {
    await databaseHelper.close();
    final dbFile = File(targetDbPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    final dbAsDirectory = Directory(targetDbPath);
    if (await dbAsDirectory.exists()) {
      await dbAsDirectory.delete(recursive: true);
    }
  });

  group('DatabaseHelper Test', () {
    test('should create database and watchlist table correctly', () async {
      final db = await databaseHelper.database;

      expect(db.isOpen, true);
      final tables = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', DBConstants.watchlistTable]);
      expect(tables.isNotEmpty, true);

      final tableInfo =
          await db.rawQuery('PRAGMA table_info(${DBConstants.watchlistTable})');
      final columns = tableInfo.map((row) => row['name'] as String).toList();
      expect(
          columns,
          containsAll([
            'id',
            'name',
            'overview',
            'poster_path',
            'vote_average',
            'number_of_seasons',
            'number_of_episodes',
            'seasons'
          ]));
    });

    test('should properly upgrade database from v1 to v2', () async {
      final dbFile = File(targetDbPath);
      final oldDb = await openDatabase(
        dbFile.path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
              'CREATE TABLE ${DBConstants.watchlistTable} (id INTEGER PRIMARY KEY, name TEXT, overview TEXT, poster_path TEXT, vote_average REAL)');
        },
      );
      await oldDb
          .insert(DBConstants.watchlistTable, {'id': 1, 'name': 'Test Show'});
      await oldDb.close();

      final newDb = await databaseHelper.database;

      final tableInfo = await newDb
          .rawQuery('PRAGMA table_info(${DBConstants.watchlistTable})');
      final columns = tableInfo.map((row) => row['name'] as String).toList();
      expect(columns,
          containsAll(['number_of_seasons', 'number_of_episodes', 'seasons']));

      final data = await newDb.query(DBConstants.watchlistTable);
      expect(data.first['name'], 'Test Show');
    });
  });
}
