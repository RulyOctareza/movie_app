import 'package:dartz/dartz.dart';
import '../../core/failure.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetMovieDetail {
  final MovieRepository repository;

  GetMovieDetail(this.repository);

  Future<Either<Failure, Movie>> execute(int id) {
    return repository.getMovieDetail(id);
  }
}
