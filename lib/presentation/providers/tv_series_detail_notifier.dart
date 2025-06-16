import 'package:flutter/material.dart';

import '../../domain/entities/tv_series.dart';
import '../../domain/usecases/get_tv_series_detail.dart';
import '../../domain/usecases/get_watchlist_tv_series.dart';

class TvSeriesDetailNotifier extends ChangeNotifier {
  final GetTvSeriesDetail getTvSeriesDetail;
  final GetWatchlistTvSeries getWatchlistTvSeries;

  TvSeriesDetailNotifier({
    required this.getTvSeriesDetail,
    required this.getWatchlistTvSeries,
  });

  late TvSeries _tvSeries;
  TvSeries get tvSeries => _tvSeries;

  RequestState _tvSeriesState = RequestState.empty;
  RequestState get tvSeriesState => _tvSeriesState;

  bool _isAddedToWatchlist = false;
  bool get isAddedToWatchlist => _isAddedToWatchlist;

  String _message = '';
  String get message => _message;

  String _watchlistMessage = '';
  String get watchlistMessage => _watchlistMessage;

  Future<void> fetchTvSeriesDetail(int id) async {
    _tvSeriesState = RequestState.loading;
    notifyListeners();

    final detailResult = await getTvSeriesDetail.execute(id);

    detailResult.fold(
      (failure) {
        _tvSeriesState = RequestState.error;
        _message = failure.message;
        notifyListeners();
      },
      (tvSeries) {
        _tvSeriesState = RequestState.loaded;
        _tvSeries = tvSeries;
        notifyListeners();
      },
    );
  }

  Future<void> loadWatchlistStatus(int id) async {
    final result = await getWatchlistTvSeries.isAddedToWatchlist(id);
    _isAddedToWatchlist = result;
    notifyListeners();
  }

  Future<void> addWatchlist(TvSeries tvSeries) async {
    final result = await getWatchlistTvSeries.saveWatchlist(tvSeries);

    result.fold(
      (failure) {
        _watchlistMessage = failure.message;
      },
      (successMessage) {
        _watchlistMessage = successMessage;
      },
    );

    await loadWatchlistStatus(tvSeries.id);
  }

  Future<void> removeFromWatchlist(TvSeries tvSeries) async {
    final result = await getWatchlistTvSeries.removeWatchlist(tvSeries);

    result.fold(
      (failure) {
        _watchlistMessage = failure.message;
      },
      (successMessage) {
        _watchlistMessage = successMessage;
      },
    );

    await loadWatchlistStatus(tvSeries.id);
  }
}

enum RequestState { empty, loading, loaded, error }
