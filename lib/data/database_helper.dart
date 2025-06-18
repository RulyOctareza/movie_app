import 'dart:developer';

import 'package:expert_flutter_dicoding/core/constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  DatabaseHelper._internal() {
    _instance = this;
  }
  factory DatabaseHelper() => _instance ?? DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
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
      try {
        await db.execute(
            'ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN number_of_seasons INTEGER;');
        await db.execute(
            'ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN number_of_episodes INTEGER;');
        await db.execute(
            'ALTER TABLE ${DBConstants.watchlistTable} ADD COLUMN seasons TEXT;');
      } catch (e) {
        // Handle error jika kolom sudah ada atau error lainnya
        log('Error upgrading database from v1 to v2: $e');
      }
    }
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DBConstants.databaseName);

    try {
      final db = await openDatabase(
        path,
        version: DBConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      return db;
    } catch (e) {
      log(
          'Error opening/upgrading database: $e. Deleting the database and rethrowing error.');
      // Jika terjadi error saat membuka atau upgrade, hapus file database yang mungkin korup.
      try {
        await deleteDatabase(path);
      } catch (deleteError) {
        log('Failed to delete database: $deleteError');
      }
      // Lempar kembali error asli agar test atau aplikasi bisa menanganinya.
      throw Exception('Failed to initialize database: $e');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null; // Reset database instance
  }
}
