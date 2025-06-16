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

      final db = await openDatabase(
        databasePath,
        version: DBConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      return db;
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
      // Add new columns for season information
      await db.execute('''
        ALTER TABLE ${DBConstants.watchlistTable}
        ADD COLUMN number_of_seasons INTEGER;
      ''');
      await db.execute('''
        ALTER TABLE ${DBConstants.watchlistTable}
        ADD COLUMN number_of_episodes INTEGER;
      ''');
      await db.execute('''
        ALTER TABLE ${DBConstants.watchlistTable}
        ADD COLUMN seasons TEXT;
      ''');
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
