import 'package:equatable/equatable.dart';

class TvSeries extends Equatable {
  final int id;
  final String name;
  final String posterPath;
  final String overview;
  final double voteAverage;

  const TvSeries({
    required this.id,
    required this.name,
    required this.posterPath,
    required this.overview,
    required this.voteAverage,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        posterPath,
        overview,
        voteAverage,
      ];
}
