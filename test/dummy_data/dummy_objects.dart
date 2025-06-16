import 'dart:convert';

import 'package:expert_flutter_dicoding/data/models/season_model.dart';
import 'package:expert_flutter_dicoding/data/models/tv_series_model.dart';
import 'package:expert_flutter_dicoding/domain/entities/season.dart';
import 'package:expert_flutter_dicoding/domain/entities/tv_series.dart';

const testTvSeries = TvSeries(
  id: 1,
  name: 'Test Series',
  posterPath: '/path.jpg',
  overview: 'Test Overview',
  voteAverage: 8.0,
  numberOfSeasons: 2,
  numberOfEpisodes: 24,
  seasons: [
    Season(
      id: 1,
      name: 'Season 1',
      overview: 'First season',
      posterPath: '/path.jpg',
      seasonNumber: 1,
      episodeCount: 12,
      airDate: '2021-01-01',
    ),
    Season(
      id: 2,
      name: 'Season 2',
      overview: 'Second season',
      posterPath: '/path.jpg',
      seasonNumber: 2,
      episodeCount: 12,
      airDate: '2022-01-01',
    ),
  ],
);

const testTvSeriesModel = TvSeriesModel(
  id: 1,
  name: 'Test Series',
  posterPath: '/path.jpg',
  overview: 'Test Overview',
  voteAverage: 8.0,
  numberOfSeasons: 2,
  numberOfEpisodes: 24,
  seasons: [
    SeasonModel(
      id: 1,
      name: 'Season 1',
      overview: 'First season',
      posterPath: '/path.jpg',
      seasonNumber: 1,
      episodeCount: 12,
      airDate: '2021-01-01',
    ),
    SeasonModel(
      id: 2,
      name: 'Season 2',
      overview: 'Second season',
      posterPath: '/path.jpg',
      seasonNumber: 2,
      episodeCount: 12,
      airDate: '2022-01-01',
    ),
  ],
);

final testTvSeriesMap = {
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
    },
    {
      'id': 2,
      'name': 'Season 2',
      'overview': 'Second season',
      'poster_path': '/path.jpg',
      'season_number': 2,
      'episode_count': 12,
      'air_date': '2022-01-01',
    },
  ]),
};
