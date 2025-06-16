import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../models/tv_series_model.dart';

abstract class TvSeriesRemoteDataSource {
  Future<List<TvSeriesModel>> getNowPlayingTvSeries();
  Future<List<TvSeriesModel>> getPopularTvSeries();
  Future<List<TvSeriesModel>> getTopRatedTvSeries();
  Future<TvSeriesModel> getTvSeriesDetail(int id);
  Future<List<TvSeriesModel>> getTvSeriesRecommendations(int id);
  Future<List<TvSeriesModel>> searchTvSeries(String query);
}

class TvSeriesRemoteDataSourceImpl implements TvSeriesRemoteDataSource {
  final http.Client client;

  TvSeriesRemoteDataSourceImpl({required this.client});

  @override
  Future<List<TvSeriesModel>> getNowPlayingTvSeries() async {
    final uri = Uri.parse('${Urls.baseUrl}/tv/on_the_air').replace(
      queryParameters: {'api_key': Urls.apiKey},
    );
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return List<TvSeriesModel>.from((json.decode(response.body)['results'] as List)
          .map((x) => TvSeriesModel.fromJson(x))
          .where((element) => element.posterPath != null));
    } else {
      throw Exception('Failed to fetch now playing TV series');
    }
  }

  @override
  Future<List<TvSeriesModel>> getPopularTvSeries() async {
    final uri = Uri.parse('${Urls.baseUrl}/tv/popular').replace(
      queryParameters: {'api_key': Urls.apiKey},
    );
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return List<TvSeriesModel>.from((json.decode(response.body)['results'] as List)
          .map((x) => TvSeriesModel.fromJson(x))
          .where((element) => element.posterPath != null));
    } else {
      throw Exception('Failed to fetch popular TV series');
    }
  }

  @override
  Future<List<TvSeriesModel>> getTopRatedTvSeries() async {
    final uri = Uri.parse('${Urls.baseUrl}/tv/top_rated').replace(
      queryParameters: {'api_key': Urls.apiKey},
    );
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return List<TvSeriesModel>.from((json.decode(response.body)['results'] as List)
          .map((x) => TvSeriesModel.fromJson(x))
          .where((element) => element.posterPath != null));
    } else {
      throw Exception('Failed to fetch top rated TV series');
    }
  }

  @override
  Future<TvSeriesModel> getTvSeriesDetail(int id) async {
    final uri = Uri.parse('${Urls.baseUrl}/tv/$id').replace(
      queryParameters: {'api_key': Urls.apiKey},
    );
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return TvSeriesModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch TV series detail');
    }
  }

  @override
  Future<List<TvSeriesModel>> getTvSeriesRecommendations(int id) async {
    final uri = Uri.parse('${Urls.baseUrl}/tv/$id/recommendations').replace(
      queryParameters: {'api_key': Urls.apiKey},
    );
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return List<TvSeriesModel>.from((json.decode(response.body)['results'] as List)
          .map((x) => TvSeriesModel.fromJson(x))
          .where((element) => element.posterPath != null));
    } else {
      throw Exception('Failed to fetch TV series recommendations');
    }
  }

  @override
  Future<List<TvSeriesModel>> searchTvSeries(String query) async {
    final uri = Uri.parse('${Urls.baseUrl}/search/tv').replace(
      queryParameters: {
        'api_key': Urls.apiKey,
        'query': query,
      },
    );
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return List<TvSeriesModel>.from((json.decode(response.body)['results'] as List)
          .map((x) => TvSeriesModel.fromJson(x))
          .where((element) => element.posterPath != null));
    } else {
      throw Exception('Failed to search TV series');
    }
  }
}
