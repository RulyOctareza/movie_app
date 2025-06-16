import 'package:dartz/dartz.dart';
import 'package:expert_flutter_dicoding/core/failure.dart';
import 'package:expert_flutter_dicoding/domain/entities/tv_series.dart';
import 'package:expert_flutter_dicoding/domain/usecases/search_tv_series.dart';
import 'package:expert_flutter_dicoding/presentation/providers/tv_series_search_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'tv_series_search_notifier_test.mocks.dart';

@GenerateMocks([SearchTvSeries])
void main() {
  late TvSeriesSearchNotifier provider;
  late SearchTvSeries mockSearchTvSeries;
  late int listenerCallCount;

  setUp(() {
    listenerCallCount = 0;
    mockSearchTvSeries = MockSearchTvSeries();
    provider = TvSeriesSearchNotifier(
      searchTvSeries: mockSearchTvSeries,
    )..addListener(() {
        listenerCallCount++;
      });
  });

  const tTvSeriesModel = TvSeries(
    id: 1,
    name: 'Test Series',
    posterPath: '/path.jpg',
    overview: 'Overview',
    voteAverage: 8.0,
  );

  final tTvSeriesList = <TvSeries>[tTvSeriesModel];
  const tQuery = 'Test Series';

  group('search tv series', () {
    test('should change state to loading when usecase is called', () async {
      // arrange
      when(mockSearchTvSeries.execute(tQuery))
          .thenAnswer((_) async => Right(tTvSeriesList));

      // act
      await provider.fetchTvSeriesSearch(tQuery);

      // assert
      expect(provider.state, RequestState.loading);
    });

    test('should change search result data when data is gotten successfully',
        () async {
      // arrange
      when(mockSearchTvSeries.execute(tQuery))
          .thenAnswer((_) async => Right(tTvSeriesList));

      // act
      await provider.fetchTvSeriesSearch(tQuery);

      // assert
      expect(provider.state, RequestState.loaded);
      expect(provider.searchResult, tTvSeriesList);
      expect(listenerCallCount, 2);
    });

    test('should return error when data is unsuccessful', () async {
      // arrange
      when(mockSearchTvSeries.execute(tQuery))
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));

      // act
      await provider.fetchTvSeriesSearch(tQuery);

      // assert
      expect(provider.state, RequestState.error);
      expect(provider.message, 'Server Failure');
      expect(listenerCallCount, 2);
    });
  });
}
