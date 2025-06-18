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
      await databaseHelper.insertTvSeriesWatchlist(tvSeries.toJson());
      return 'Added to Watchlist';
    } catch (e) {
      throw Exception('Failed to add watchlist: ${e.toString()}');
    }
  }

  @override
  Future<String> removeWatchlist(TvSeriesModel tvSeries) async {
    try {
      await databaseHelper.removeTvSeriesWatchlist(tvSeries.id);
      return 'Removed from Watchlist';
    } catch (e) {
      throw Exception('Failed to remove watchlist: ${e.toString()}');
    }
  }

  @override
  Future<TvSeriesModel?> getTvSeriesById(int id) async {
    final result = await databaseHelper.getTvSeriesById(id);
    if (result != null) {
      return TvSeriesModel.fromJson(result);
    } else {
      return null;
    }
  }

  @override
  Future<List<TvSeriesModel>> getWatchlistTvSeries() async {
    final result = await databaseHelper.getWatchlistTvSeries();
    return result.map((data) => TvSeriesModel.fromJson(data)).toList();
  }
}
