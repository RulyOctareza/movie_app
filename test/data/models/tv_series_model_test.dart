import 'dart:convert';
import 'package:expert_flutter_dicoding/data/models/season_model.dart';
import 'package:expert_flutter_dicoding/data/models/tv_series_model.dart';
import 'package:expert_flutter_dicoding/domain/entities/tv_series.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../dummy_data/dummy_objects.dart';

void main() {
  group('TvSeriesModel', () {
    test('should convert from json with complete data', () {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'name': 'Test Series',
        'poster_path': '/path.jpg',
        'overview': 'Test Overview',
        'vote_average': 8.0,
        'number_of_seasons': 2,
        'number_of_episodes': 24,
        'seasons': [
          {
            'id': 1,
            'name': 'Season 1',
            'overview': 'First season',
            'poster_path': '/path.jpg',
            'season_number': 1,
            'episode_count': 12,
            'air_date': '2021-01-01',
          },
          {
            'id': 2,
            'name': 'Season 2',
            'overview': 'Second season',
            'poster_path': '/path.jpg',
            'season_number': 2,
            'episode_count': 12,
            'air_date': '2022-01-01',
          }
        ]
      };

      // act
      final result = TvSeriesModel.fromJson(jsonMap);

      // assert
      expect(result.id, 1);
      expect(result.name, 'Test Series');
      expect(result.posterPath, '/path.jpg');
      expect(result.overview, 'Test Overview');
      expect(result.voteAverage, 8.0);
      expect(result.numberOfSeasons, 2);
      expect(result.numberOfEpisodes, 24);
      expect(result.seasons?.length, 2);
    });

    test('should convert to json with complete data', () {
      // arrange
      const model = testTvSeriesModel;

      // act
      final result = model.toJson();

      // assert
      expect(result['id'], 1);
      expect(result['name'], 'Test Series');
      expect(result['poster_path'], '/path.jpg');
      expect(result['overview'], 'Test Overview');
      expect(result['vote_average'], 8.0);
      expect(result['number_of_seasons'], 2);
      expect(result['number_of_episodes'], 24);
      expect(jsonDecode(result['seasons'] as String), isA<List>());
    });

    test('should convert from json with string seasons data', () {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'name': 'Test Series',
        'poster_path': '/path.jpg',
        'overview': 'Test Overview',
        'vote_average': 8.0,
        'number_of_seasons': 2,
        'number_of_episodes': 24,
        'seasons': jsonEncode([
          {
            'id': 1,
            'name': 'Season 1',
            'overview': 'First season',
            'poster_path': '/path.jpg',
            'season_number': 1,
            'episode_count': 12,
            'air_date': '2021-01-01',
          }
        ])
      };

      // act
      final result = TvSeriesModel.fromJson(jsonMap);

      // assert
      expect(result.seasons?.length, 1);
      expect(result.seasons?.first, isA<SeasonModel>());
    });

    test('should convert to entity', () {
      // arrange
      const model = testTvSeriesModel;

      // act
      final result = model.toEntity();

      // assert
      expect(result, isA<TvSeries>());
      expect(result.id, model.id);
      expect(result.name, model.name);
      expect(result.posterPath, model.posterPath);
      expect(result.overview, model.overview);
      expect(result.voteAverage, model.voteAverage);
      expect(result.numberOfSeasons, model.numberOfSeasons);
      expect(result.numberOfEpisodes, model.numberOfEpisodes);
      expect(result.seasons?.length, model.seasons?.length);
    });

    test('should handle null values correctly', () {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'name': 'Test Series',
        'vote_average': null,
        'poster_path': null,
        'overview': null,
        'seasons': null,
        'number_of_seasons': null,
        'number_of_episodes': null,
      };

      // act
      final result = TvSeriesModel.fromJson(jsonMap);

      // assert
      expect(result.posterPath, null);
      expect(result.overview, null);
      expect(result.voteAverage, 0.0);
      expect(result.seasons, null);
      expect(result.numberOfSeasons, null);
      expect(result.numberOfEpisodes, null);
    });

    test('should implement Equatable correctly', () {
      // arrange
      const model1 = TvSeriesModel(
        id: 1,
        name: 'Test',
        voteAverage: 8.0,
      );

      const model2 = TvSeriesModel(
        id: 1,
        name: 'Test',
        voteAverage: 8.0,
      );

      const model3 = TvSeriesModel(
        id: 2,
        name: 'Test',
        voteAverage: 8.0,
      );

      // assert
      expect(model1 == model2, true);
      expect(model1 == model3, false);
      expect(model1.props, [
        model1.id,
        model1.name,
        model1.posterPath,
        model1.overview,
        model1.voteAverage,
      ]);
    });
  });
}
