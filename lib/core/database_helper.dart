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
    try {
      if (oldVersion < 2) {
        await db.transaction((txn) async {
          // Add new columns for season information
          await txn.execute('''
            ALTER TABLE ${DBConstants.watchlistTable}
            ADD COLUMN number_of_seasons INTEGER;
          ''');
          await txn.execute('''
            ALTER TABLE ${DBConstants.watchlistTable}
            ADD COLUMN number_of_episodes INTEGER;
          ''');
          await txn.execute('''
            ALTER TABLE ${DBConstants.watchlistTable}
            ADD COLUMN seasons TEXT;
          ''');

          // Validate data integrity
          final result = await txn.query(DBConstants.watchlistTable);
          for (final row in result) {
            final vote = row['vote_average'];
            if (vote != null && vote is! double && vote is! int) {
              throw Exception('Invalid data found during upgrade');
            }
          }
        });
      }
    } catch (e) {
      throw Exception('Failed to upgrade database: ${e.toString()}');
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      _instance = null;  // Clear instance so a new one will be created
    }
  }
}
