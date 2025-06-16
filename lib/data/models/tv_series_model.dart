import 'package:equatable/equatable.dart';

import '../../domain/entities/tv_series.dart';

class TvSeriesModel extends Equatable {
  final int id;
  final String name;
  final String? posterPath;
  final String? overview;
  final double voteAverage;

  const TvSeriesModel({
    required this.id,
    required this.name,
    this.posterPath,
    this.overview,
    required this.voteAverage,
  });

  factory TvSeriesModel.fromJson(Map<String, dynamic> json) => TvSeriesModel(
        id: json["id"],
        name: json["name"],
        posterPath: json["poster_path"],
        overview: json["overview"],
        voteAverage: json["vote_average"]?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "poster_path": posterPath,
        "overview": overview,
        "vote_average": voteAverage,
      };

  TvSeries toEntity() {
    return TvSeries(
      id: id,
      name: name,
      posterPath: posterPath ?? "",
      overview: overview ?? "",
      voteAverage: voteAverage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        posterPath,
        overview,
        voteAverage,
      ];
}
