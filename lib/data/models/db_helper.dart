import 'package:sqflite/sqflite.dart';

import '../../core/constants.dart';
import 'movie_model.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  Database? _database;

  DatabaseHelper._instance() {
    _databaseHelper = this;
  }

  factory DatabaseHelper() => _databaseHelper ?? DatabaseHelper._instance();

  Future<Database?> get database async {
    _database ??= await _initDb();
    return _database;
  }

  Future<Database> _initDb() async {
    final path = await getDatabasesPath();
    final databasePath = '$path/ditonton.db';

    var db = await openDatabase(databasePath, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(DBConstants.tableMovieWatchlistCreateQuery);
    await db.execute(DBConstants.tableTvSeriesWatchlistCreateQuery);
  }

  Future<int> insertWatchlist(MovieModel movie) async {
    final db = await database;
    return await db!.insert(DBConstants.watchlistMoviesTable, movie.toJson());
  }

  Future<int> removeWatchlist(MovieModel movie) async {
    final db = await database;
    return await db!.delete(
      DBConstants.watchlistMoviesTable,
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  Future<Map<String, dynamic>?> getMovieById(int id) async {
    final db = await database;
    final results = await db!.query(
      DBConstants.watchlistMoviesTable,
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
    final List<Map<String, dynamic>> results =
        await db!.query(DBConstants.watchlistMoviesTable);
    return results;
  }
}
