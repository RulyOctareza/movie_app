import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/exception.dart';
import '../../core/constants.dart';
import '../models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getNowPlayingMovies();
  Future<List<MovieModel>> getPopularMovies();
  Future<List<MovieModel>> getTopRatedMovies();
  Future<MovieModel> getMovieDetail(int id);
  Future<List<MovieModel>> searchMovies(String query);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final http.Client client;

  MovieRemoteDataSourceImpl({required this.client});

  @override
  Future<List<MovieModel>> getNowPlayingMovies() async {
    final uri = Uri.parse('${Urls.baseUrl}/movie/now_playing').replace(
      queryParameters: {'api_key': Urls.apiKey},
    );
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return List<MovieModel>.from(
          (json.decode(response.body)['results'] as List)
              .map((x) => MovieModel.fromJson(x)));
    } else {
      throw ServerException();
    }
  }

  @override
  Future<MovieModel> getMovieDetail(int id) async {
    final uri = Uri.parse('${Urls.baseUrl}/movie/$id').replace(
      queryParameters: {'api_key': Urls.apiKey},
    );
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return MovieModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MovieModel>> getPopularMovies() async {
    final uri = Uri.parse('${Urls.baseUrl}/movie/popular').replace(
      queryParameters: {'api_key': Urls.apiKey},
    );
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return List<MovieModel>.from(
          (json.decode(response.body)['results'] as List)
              .map((x) => MovieModel.fromJson(x)));
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MovieModel>> getTopRatedMovies() async {
    final uri = Uri.parse('${Urls.baseUrl}/movie/top_rated').replace(
      queryParameters: {'api_key': Urls.apiKey},
    );
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return List<MovieModel>.from(
          (json.decode(response.body)['results'] as List)
              .map((x) => MovieModel.fromJson(x)));
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    final uri = Uri.parse('${Urls.baseUrl}/search/movie').replace(
      queryParameters: {
        'api_key': Urls.apiKey,
        'query': query,
      },
    );
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return List<MovieModel>.from(
          (json.decode(response.body)['results'] as List)
              .map((x) => MovieModel.fromJson(x)));
    } else {
      throw ServerException();
    }
  }
}
