import 'dart:convert';

import 'package:expert_flutter_dicoding/core/constants.dart';
import 'package:expert_flutter_dicoding/data/datasources/tv_series_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/dummy_objects.dart';
import 'tv_series_remote_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late TvSeriesRemoteDataSourceImpl dataSource;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = TvSeriesRemoteDataSourceImpl(client: mockHttpClient);
  });

  group('Get Now Playing TV Series', () {
    test('should return list of TV Series Model when the response code is 200',
        () async {
      // arrange
      when(mockHttpClient.get(Uri.parse('${Urls.baseUrl}/tv/on_the_air')
              .replace(queryParameters: {'api_key': Urls.apiKey})))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'results': [testTvSeriesMap]
              }),
              200));
      // act
      final result = await dataSource.getNowPlayingTvSeries();
      // assert
      expect(result, [testTvSeriesModel]);
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      // arrange
      when(mockHttpClient.get(Uri.parse('${Urls.baseUrl}/tv/on_the_air')
              .replace(queryParameters: {'api_key': Urls.apiKey})))
          .thenAnswer((_) async => http.Response('Not Found', 404));
      // act
      final call = dataSource.getNowPlayingTvSeries();
      // assert
      expect(() => call, throwsA(isA<Exception>()));
    });
  });

  group('Get Popular TV Series', () {
    test('should return list of TV Series Model when the response code is 200',
        () async {
      // arrange
      when(mockHttpClient.get(Uri.parse('${Urls.baseUrl}/tv/popular')
              .replace(queryParameters: {'api_key': Urls.apiKey})))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'results': [testTvSeriesMap]
              }),
              200));
      // act
      final result = await dataSource.getPopularTvSeries();
      // assert
      expect(result, [testTvSeriesModel]);
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      // arrange
      when(mockHttpClient.get(Uri.parse('${Urls.baseUrl}/tv/popular')
              .replace(queryParameters: {'api_key': Urls.apiKey})))
          .thenAnswer((_) async => http.Response('Not Found', 404));
      // act
      final call = dataSource.getPopularTvSeries();
      // assert
      expect(() => call, throwsA(isA<Exception>()));
    });
  });

  group('Get Top Rated TV Series', () {
    test('should return list of TV Series Model when the response code is 200',
        () async {
      // arrange
      when(mockHttpClient.get(Uri.parse('${Urls.baseUrl}/tv/top_rated')
              .replace(queryParameters: {'api_key': Urls.apiKey})))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'results': [testTvSeriesMap]
              }),
              200));
      // act
      final result = await dataSource.getTopRatedTvSeries();
      // assert
      expect(result, [testTvSeriesModel]);
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      // arrange
      when(mockHttpClient.get(Uri.parse('${Urls.baseUrl}/tv/top_rated')
              .replace(queryParameters: {'api_key': Urls.apiKey})))
          .thenAnswer((_) async => http.Response('Not Found', 404));
      // act
      final call = dataSource.getTopRatedTvSeries();
      // assert
      expect(() => call, throwsA(isA<Exception>()));
    });
  });

  group('Get TV Series Detail', () {
    const tId = 1;

    test('should return TV Series Detail Model when the response code is 200',
        () async {
      // arrange
      when(mockHttpClient.get(Uri.parse('${Urls.baseUrl}/tv/$tId')
              .replace(queryParameters: {'api_key': Urls.apiKey})))
          .thenAnswer(
              (_) async => http.Response(jsonEncode(testTvSeriesMap), 200));
      // act
      final result = await dataSource.getTvSeriesDetail(tId);
      // assert
      expect(result, testTvSeriesModel);
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      // arrange
      when(mockHttpClient.get(Uri.parse('${Urls.baseUrl}/tv/$tId')
              .replace(queryParameters: {'api_key': Urls.apiKey})))
          .thenAnswer((_) async => http.Response('Not Found', 404));
      // act
      final call = dataSource.getTvSeriesDetail(tId);
      // assert
      expect(() => call, throwsA(isA<Exception>()));
    });
  });

  group('Get TV Series Recommendations', () {
    const tId = 1;

    test('should return list of TV Series Model when the response code is 200',
        () async {
      // arrange
      when(mockHttpClient.get(
              Uri.parse('${Urls.baseUrl}/tv/$tId/recommendations')
                  .replace(queryParameters: {'api_key': Urls.apiKey})))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'results': [testTvSeriesMap]
              }),
              200));
      // act
      final result = await dataSource.getTvSeriesRecommendations(tId);
      // assert
      expect(result, [testTvSeriesModel]);
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      // arrange
      when(mockHttpClient.get(
              Uri.parse('${Urls.baseUrl}/tv/$tId/recommendations')
                  .replace(queryParameters: {'api_key': Urls.apiKey})))
          .thenAnswer((_) async => http.Response('Not Found', 404));
      // act
      final call = dataSource.getTvSeriesRecommendations(tId);
      // assert
      expect(() => call, throwsA(isA<Exception>()));
    });
  });

  group('Search TV Series', () {
    const tQuery = 'Test Series';

    test('should return list of TV Series Model when the response code is 200',
        () async {
      // arrange
      when(mockHttpClient
          .get(Uri.parse('${Urls.baseUrl}/search/tv').replace(queryParameters: {
        'api_key': Urls.apiKey,
        'query': tQuery,
      }))).thenAnswer((_) async => http.Response(
          jsonEncode({
            'results': [testTvSeriesMap]
          }),
          200));
      // act
      final result = await dataSource.searchTvSeries(tQuery);
      // assert
      expect(result, [testTvSeriesModel]);
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      // arrange
      when(mockHttpClient
          .get(Uri.parse('${Urls.baseUrl}/search/tv').replace(queryParameters: {
        'api_key': Urls.apiKey,
        'query': tQuery,
      }))).thenAnswer((_) async => http.Response('Not Found', 404));
      // act
      final call = dataSource.searchTvSeries(tQuery);
      // assert
      expect(() => call, throwsA(isA<Exception>()));
    });
  });
}
