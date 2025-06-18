import 'package:dartz/dartz.dart';
import '../../core/failure.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class RemoveWatchlist {
  final MovieRepository repository;

  RemoveWatchlist(this.repository);

  Future<Either<Failure, String>> execute(Movie movie) {
    return repository.removeWatchlist(movie);
  }
}
