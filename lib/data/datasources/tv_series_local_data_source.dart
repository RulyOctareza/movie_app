import '../../core/constants.dart';
import '../../core/database_helper.dart';
import '../models/tv_series_model.dart';

abstract class TvSeriesLocalDataSource {
  Future<String> insertWatchlist(TvSeriesModel tvSeries);
  Future<String> removeWatchlist(TvSeriesModel tvSeries);
  Future<TvSeriesModel?> getTvSeriesById(int id);
  Future<List<TvSeriesModel>> getWatchlistTvSeries();
}

class TvSeriesLocalDataSourceImpl implements TvSeriesLocalDataSource {
  final DatabaseHelper databaseHelper;

  TvSeriesLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<String> insertWatchlist(TvSeriesModel tvSeries) async {
    try {
      final database = await databaseHelper.database;
      await database.insert(DBConstants.watchlistTable, tvSeries.toJson());
      return 'Added to Watchlist';
    } catch (e) {
      throw Exception('Failed to add watchlist');
    }
  }

  @override
  Future<String> removeWatchlist(TvSeriesModel tvSeries) async {
    try {
      final database = await databaseHelper.database;
      await database.delete(
        DBConstants.watchlistTable,
        where: 'id = ?',
        whereArgs: [tvSeries.id],
      );
      return 'Removed from Watchlist';
    } catch (e) {
      throw Exception('Failed to remove watchlist');
    }
  }

  @override
  Future<TvSeriesModel?> getTvSeriesById(int id) async {
    final database = await databaseHelper.database;
    final result = await database.query(
      DBConstants.watchlistTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return TvSeriesModel.fromJson(result.first);
    } else {
      return null;
    }
  }

  @override
  Future<List<TvSeriesModel>> getWatchlistTvSeries() async {
    final database = await databaseHelper.database;
    final result = await database.query(DBConstants.watchlistTable);
    return result.map((data) => TvSeriesModel.fromJson(data)).toList();
  }
}
