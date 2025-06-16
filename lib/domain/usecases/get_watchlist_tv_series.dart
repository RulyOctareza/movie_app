import 'package:dartz/dartz.dart';

import '../../core/failure.dart';
import '../entities/tv_series.dart';
import '../repositories/tv_series_repository.dart';

class GetWatchlistTvSeries {
  final TvSeriesRepository repository;

  GetWatchlistTvSeries(this.repository);

  Future<Either<Failure, List<TvSeries>>> execute() {
    return repository.getWatchlistTvSeries();
  }

  Future<Either<Failure, String>> saveWatchlist(TvSeries tvSeries) {
    return repository.saveWatchlist(tvSeries);
  }

  Future<Either<Failure, String>> removeWatchlist(TvSeries tvSeries) {
    return repository.removeWatchlist(tvSeries);
  }

  Future<bool> isAddedToWatchlist(int id) {
    return repository.isAddedToWatchlist(id);
  }
}
