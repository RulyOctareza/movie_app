import 'package:dartz/dartz.dart';
import '../../core/failure.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetWatchlistMovies {
  final MovieRepository repository;

  GetWatchlistMovies(this.repository);

  Future<Either<Failure, List<Movie>>> execute() {
    return repository.getWatchlistMovies();
  }
}
