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

  // For dependency injection support
  factory DatabaseHelper() => instance;

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<String> getDbPath() async {
    final path = await getDatabasesPath();
    return join(path, DBConstants.databaseName);
  }

  Future<Database> _initDb() async {
    try {
      final databasePath = await getDbPath();
      final dbFile = File(databasePath);

      // Check if database file exists and delete it if it's corrupted
      if (await dbFile.exists()) {
        try {
          // Try to open the database to check if it's valid
          final testDb = await openDatabase(
            databasePath,
            readOnly: true,
          );
          await testDb.close();
        } catch (e) {
          // Database is corrupted, delete it
          await dbFile.delete();
        }
      }

      // Create or open the database
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
    // Create movies watchlist table
    await db.execute(DBConstants.tableMovieWatchlistCreateQuery);

    // Create TV series watchlist table
    await db.execute(DBConstants.tableTvSeriesWatchlistCreateQuery);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create the new tables with the correct schema
      await _onCreate(db, newVersion);

      // Migrate data from the old watchlist table to the new tables
      final oldData = await db.query(DBConstants.watchlistTable);
      for (var item in oldData) {
        if (item['isMovie'] == 1) {
          await db.insert(DBConstants.watchlistMoviesTable, {
            'id': item['id'],
            'title': item['title'],
            'overview': item['overview'],
            'poster_path': item['poster_path'],
            'vote_average': item['vote_average'],
          });
        } else {
          await db.insert(DBConstants.watchlistTvSeriesTable, {
            'id': item['id'],
            'name': item['name'],
            'overview': item['overview'],
            'poster_path': item['poster_path'],
            'vote_average': item['vote_average'],
            'number_of_seasons': item['number_of_seasons'],
            'number_of_episodes': item['number_of_episodes'],
            'seasons': item['seasons'],
          });
        }
      }

      // Drop the old table
      await db.execute('DROP TABLE IF EXISTS ${DBConstants.watchlistTable}');
    }
  }

  Future<int> insertMovieWatchlist(Map<String, dynamic> movie) async {
    final db = await database;
    return await db.insert(DBConstants.watchlistMoviesTable, movie);
  }

  Future<int> insertTvSeriesWatchlist(Map<String, dynamic> tvSeries) async {
    final db = await database;
    return await db.insert(DBConstants.watchlistTvSeriesTable, tvSeries);
  }

  Future<int> removeMovieWatchlist(int id) async {
    final db = await database;
    return await db.delete(
      DBConstants.watchlistMoviesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> removeTvSeriesWatchlist(int id) async {
    final db = await database;
    return await db.delete(
      DBConstants.watchlistTvSeriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getMovieById(int id) async {
    final db = await database;
    final results = await db.query(
      DBConstants.watchlistMoviesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    }

    return null;
  }

  Future<Map<String, dynamic>?> getTvSeriesById(int id) async {
    final db = await database;
    final results = await db.query(
      DBConstants.watchlistTvSeriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> getWatchlistMovies() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results =
          await db.query(DBConstants.watchlistMoviesTable);
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getWatchlistTvSeries() async {
    final db = await database;
    final List<Map<String, dynamic>> results =
        await db.query(DBConstants.watchlistTvSeriesTable);
    return results;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
