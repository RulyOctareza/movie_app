import 'package:expert_flutter_dicoding/domain/entities/tv_series.dart';
import 'package:expert_flutter_dicoding/domain/repositories/tv_series_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:expert_flutter_dicoding/core/failure.dart';

class DummyTvSeriesRepository implements TvSeriesRepository {
  @override
  Future<Either<Failure, List<TvSeries>>> getNowPlayingTvSeries() async =>
      const Right([]);
  @override
  Future<Either<Failure, List<TvSeries>>> getPopularTvSeries() async =>
      const Right([]);
  @override
  Future<Either<Failure, List<TvSeries>>> getTopRatedTvSeries() async =>
      const Right([]);
  @override
  Future<Either<Failure, TvSeries>> getTvSeriesDetail(int id) async =>
      Right(TvSeries(
          id: id, name: '', posterPath: '', overview: '', voteAverage: 0.0));
  @override
  Future<Either<Failure, List<TvSeries>>> getTvSeriesRecommendations(
          int id) async =>
      const Right([]);
  @override
  Future<Either<Failure, List<TvSeries>>> searchTvSeries(String query) async =>
      const Right([]);
  @override
  Future<Either<Failure, String>> saveWatchlist(TvSeries tvSeries) async =>
      const Right('');
  @override
  Future<Either<Failure, String>> removeWatchlist(TvSeries tvSeries) async =>
      const Right('');
  @override
  Future<bool> isAddedToWatchlist(int id) async => false;
  @override
  Future<Either<Failure, List<TvSeries>>> getWatchlistTvSeries() async =>
      const Right([]);
}
