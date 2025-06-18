import 'package:equatable/equatable.dart';
import '../../domain/entities/movie.dart';

class MovieModel extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final double voteAverage;

  const MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) => MovieModel(
        id: json["id"],
        title: json["title"] ?? json["name"] ?? '',
        overview: json["overview"] ?? '',
        posterPath: json["poster_path"] ?? '',
        voteAverage: (json["vote_average"] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "overview": overview,
        "poster_path": posterPath,
        "vote_average": voteAverage,
      };

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
    };
  }

  Movie toEntity() => Movie(
        id: id,
        title: title,
        overview: overview,
        posterPath: posterPath,
        voteAverage: voteAverage,
      );

  factory MovieModel.fromEntity(Movie movie) => MovieModel(
        id: movie.id,
        title: movie.title,
        overview: movie.overview,
        posterPath: movie.posterPath,
        voteAverage: movie.voteAverage,
      );

  factory MovieModel.fromMap(Map<String, dynamic> map) => MovieModel(
        id: map["id"],
        title: map["title"],
        overview: map["overview"],
        posterPath: map["poster_path"],
        voteAverage: map["vote_average"]?.toDouble() ?? 0.0,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        overview,
        posterPath,
        voteAverage,
      ];
}
