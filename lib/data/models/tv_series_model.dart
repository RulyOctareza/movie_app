import 'dart:convert';
import 'package:equatable/equatable.dart';

import '../../domain/entities/tv_series.dart';
import '../models/season_model.dart';

class TvSeriesModel extends Equatable {
  final int id;
  final String name;
  final String? posterPath;
  final String? overview;
  final double voteAverage;
  final List<SeasonModel>? seasons;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;

  const TvSeriesModel({
    required this.id,
    required this.name,
    this.posterPath,
    this.overview,
    required this.voteAverage,
    this.seasons,
    this.numberOfSeasons,
    this.numberOfEpisodes,
  });

  factory TvSeriesModel.fromJson(Map<String, dynamic> json) => TvSeriesModel(
        id: json["id"],
        name: json["name"],
        posterPath: json["poster_path"],
        overview: json["overview"],
        voteAverage: json["vote_average"]?.toDouble() ?? 0.0,
        numberOfSeasons: json["number_of_seasons"],
        numberOfEpisodes: json["number_of_episodes"],
        seasons: json["seasons"] != null
            ? (json["seasons"] is String 
                ? (jsonDecode(json["seasons"]) as List)
                    .map((x) => SeasonModel.fromJson(x))
                    .toList()
                : (json["seasons"] as List)
                    .map((x) => SeasonModel.fromJson(x))
                    .toList())
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "poster_path": posterPath,
        "overview": overview,
        "vote_average": voteAverage,
        "number_of_seasons": numberOfSeasons,
        "number_of_episodes": numberOfEpisodes,
        "seasons": seasons != null
            ? jsonEncode(seasons!.map((x) => x.toJson()).toList())
            : null,
      };

  TvSeries toEntity() {
    return TvSeries(
      id: id,
      name: name,
      posterPath: posterPath ?? "",
      overview: overview ?? "",
      voteAverage: voteAverage,
      seasons: seasons?.map((model) => model.toEntity()).toList(),
      numberOfSeasons: numberOfSeasons,
      numberOfEpisodes: numberOfEpisodes,
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
