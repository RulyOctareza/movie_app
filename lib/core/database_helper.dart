import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/constants.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    try {
      final path = await getDatabasesPath();
      final databasePath = join(path, DBConstants.databaseName);

      try {
        final db = await openDatabase(
          databasePath,
          version: DBConstants.databaseVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
          onOpen: (db) async {
            // Validate database integrity
            try {
              await db.query(DBConstants.watchlistTable, limit: 1);
            } catch (e) {
              await db.close();
              throw Exception('Database validation failed: ${e.toString()}');
            }
          },
        );
        return db;
      } catch (e) {
        // If database is corrupted, delete it and try again
        final dbFile = File(databasePath);
        if (await dbFile.exists()) {
          await dbFile.delete();
        }
        throw Exception('Failed to open database: ${e.toString()}');
      }
    } catch (e) {
      throw Exception('Failed to initialize database: ${e.toString()}');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
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
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Simulate a data validation/migration step that could fail with invalid data.
      if (oldVersion == 1) {
        // This check is specific to the upgrade path from v1 to v2.
        final List<Map<String, dynamic>> oldWatchlist =
            await db.query(DBConstants.watchlistTable);
        for (var item in oldWatchlist) {
          final voteAverage = item['vote_average'];
          // If vote_average is not null and not a number, it's problematic for this hypothetical validation.
          if (voteAverage != null && voteAverage is! num) {
            // This error will be caught by _initDb's try-catch block.
            throw StateError(
                'Upgrade from v1 to v2 failed: Invalid data type for vote_average. Expected num, got ${voteAverage.runtimeType} for value "$voteAverage".');
          }
        }
      }

      // Proceed with schema changes if validation passed or wasn't applicable
      await db.execute(
          'ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN number_of_seasons INTEGER;');
      await db.execute(
          'ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN number_of_episodes INTEGER;');
      await db.execute(
          'ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN seasons TEXT;');
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      _instance = null;
    }
  }
}
