import 'package:flutter/material.dart';

import '../../domain/entities/tv_series.dart';
import '../../domain/usecases/search_tv_series.dart';

class TvSeriesSearchNotifier extends ChangeNotifier {
  final SearchTvSeries searchTvSeries;

  TvSeriesSearchNotifier({required this.searchTvSeries});

  var _searchResult = <TvSeries>[];
  List<TvSeries> get searchResult => _searchResult;

  RequestState _state = RequestState.empty;
  RequestState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> fetchTvSeriesSearch(String query) async {
    _state = RequestState.loading;
    notifyListeners();

    final result = await searchTvSeries.execute(query);
    result.fold(
      (failure) {
        _state = RequestState.error;
        _message = failure.message;
        _searchResult = [];
        notifyListeners();
      },
      (data) {
        _state = RequestState.loaded;
        _searchResult = data;
        notifyListeners();
      },
    );
  }
}

enum RequestState { empty, loading, loaded, error }
