import 'package:dartz/dartz.dart';

import '../../core/failure.dart';
import '../entities/tv_series.dart';
import '../repositories/tv_series_repository.dart';

class GetTvSeriesDetail {
  final TvSeriesRepository repository;

  GetTvSeriesDetail(this.repository);

  Future<Either<Failure, TvSeries>> execute(int id) {
    return repository.getTvSeriesDetail(id);
  }
}
