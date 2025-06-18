import '../../core/exception.dart';
import '../../core/database_helper.dart';
import '../models/movie_model.dart';

abstract class MovieLocalDataSource {
  Future<String> insertWatchlist(MovieModel movie);
  Future<String> removeWatchlist(MovieModel movie);
  Future<MovieModel?> getMovieById(int id);
  Future<List<MovieModel>> getWatchlistMovies();
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  final DatabaseHelper databaseHelper;

  MovieLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<String> insertWatchlist(MovieModel movie) async {
    try {
      await databaseHelper.insertMovieWatchlist(movie.toJson());
      return 'Added to Watchlist';
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<String> removeWatchlist(MovieModel movie) async {
    try {
      await databaseHelper.removeMovieWatchlist(movie.id);
      return 'Removed from Watchlist';
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<MovieModel?> getMovieById(int id) async {
    final result = await databaseHelper.getMovieById(id);
    if (result != null) {
      return MovieModel.fromMap(result);
    } else {
      return null;
    }
  }

  @override
  Future<List<MovieModel>> getWatchlistMovies() async {
    try {
      final result = await databaseHelper.getWatchlistMovies();
      return result.map((data) => MovieModel.fromMap(data)).toList();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}
