import 'package:flutter/foundation.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/search_movies.dart';
import '../../core/state_enum.dart';

class MovieSearchNotifier extends ChangeNotifier {
  final SearchMovies searchMovies;

  MovieSearchNotifier({required this.searchMovies});

  RequestState _state = RequestState.empty;
  RequestState get state => _state;

  List<Movie> _searchResult = [];
  List<Movie> get searchResult => _searchResult;

  String _message = '';
  String get message => _message;

  Future<void> fetchMovieSearch(String query) async {
    _state = RequestState.loading;
    notifyListeners();

    final result = await searchMovies.execute(query);
    result.fold(
      (failure) {
        _message = failure.message;
        _state = RequestState.error;
        notifyListeners();
      },
      (data) {
        _searchResult = data;
        _state = RequestState.loaded;
        notifyListeners();
      },
    );
  }
}
