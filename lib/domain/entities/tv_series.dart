import 'package:equatable/equatable.dart';
import 'package:expert_flutter_dicoding/domain/entities/season.dart';

class TvSeries extends Equatable {
  final int id;
  final String name;
  final String posterPath;
  final String overview;
  final double voteAverage;
  final List<Season>? seasons;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;

  const TvSeries({
    required this.id,
    required this.name,
    required this.posterPath,
    required this.overview,
    required this.voteAverage,
    this.seasons,
    this.numberOfSeasons,
    this.numberOfEpisodes,
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
