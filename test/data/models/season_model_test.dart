import 'package:expert_flutter_dicoding/data/models/season_model.dart';
import 'package:expert_flutter_dicoding/domain/entities/season.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tSeasonModel = SeasonModel(
    id: 1,
    name: 'Season 1',
    overview: 'First season',
    posterPath: '/path.jpg',
    seasonNumber: 1,
    episodeCount: 12,
    airDate: '2021-01-01',
  );

  const tSeason = Season(
    id: 1,
    name: 'Season 1',
    overview: 'First season',
    posterPath: '/path.jpg',
    seasonNumber: 1,
    episodeCount: 12,
    airDate: '2021-01-01',
  );

  test('should be a subclass of Season entity', () {
    final result = tSeasonModel.toEntity();
    expect(result, tSeason);
  });

  test('should return a valid model from JSON', () {
    // arrange
    final Map<String, dynamic> jsonMap = {
      'id': 1,
      'name': 'Season 1',
      'overview': 'First season',
      'poster_path': '/path.jpg',
      'season_number': 1,
      'episode_count': 12,
      'air_date': '2021-01-01',
    };

    // act
    final result = SeasonModel.fromJson(jsonMap);

    // assert
    expect(result, tSeasonModel);
  });

  test('should return a JSON map containing proper data', () {
    // act
    final result = tSeasonModel.toJson();

    // assert
    final expectedJsonMap = {
      'id': 1,
      'name': 'Season 1',
      'overview': 'First season',
      'poster_path': '/path.jpg',
      'season_number': 1,
      'episode_count': 12,
      'air_date': '2021-01-01',
    };
    expect(result, expectedJsonMap);
  });

  test('should handle null values from JSON', () {
    // arrange
    final Map<String, dynamic> jsonMap = {
      'id': 1,
      'name': 'Season 1',
      'overview': null,
      'poster_path': null,
      'season_number': 1,
      'episode_count': null,
      'air_date': null,
    };

    // act
    final result = SeasonModel.fromJson(jsonMap);

    // assert
    expect(result.overview, '');
    expect(result.posterPath, null);
    expect(result.episodeCount, 0);
    expect(result.airDate, '');
  });
}
