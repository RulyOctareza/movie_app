import 'package:dartz/dartz.dart';
import 'package:expert_flutter_dicoding/core/failure.dart';
import 'package:expert_flutter_dicoding/domain/entities/tv_series.dart';
import 'package:expert_flutter_dicoding/domain/usecases/get_now_playing_tv_series.dart';
import 'package:expert_flutter_dicoding/domain/usecases/get_popular_tv_series.dart';
import 'package:expert_flutter_dicoding/domain/usecases/get_top_rated_tv_series.dart';
import 'package:expert_flutter_dicoding/presentation/providers/tv_series_list_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'tv_series_list_notifier_test.mocks.dart';

@GenerateMocks([
  GetNowPlayingTvSeries,
  GetPopularTvSeries,
  GetTopRatedTvSeries,
])
void main() {
  late TvSeriesListNotifier provider;
  late GetNowPlayingTvSeries mockGetNowPlayingTvSeries;
  late GetPopularTvSeries mockGetPopularTvSeries;
  late GetTopRatedTvSeries mockGetTopRatedTvSeries;
  late int listenerCallCount;

  setUp(() {
    listenerCallCount = 0;
    mockGetNowPlayingTvSeries = MockGetNowPlayingTvSeries();
    mockGetPopularTvSeries = MockGetPopularTvSeries();
    mockGetTopRatedTvSeries = MockGetTopRatedTvSeries();
    provider = TvSeriesListNotifier(
      getNowPlayingTvSeries: mockGetNowPlayingTvSeries,
      getPopularTvSeries: mockGetPopularTvSeries,
      getTopRatedTvSeries: mockGetTopRatedTvSeries,
    )..addListener(() {
        listenerCallCount++;
      });
  });

  const tTvSeries = TvSeries(
    id: 1,
    name: 'Test Series',
    posterPath: '/path.jpg',
    overview: 'Overview',
    voteAverage: 8.0,
  );

  final tTvSeriesList = <TvSeries>[tTvSeries];

  group('now playing tv series', () {
    test('initialState should be empty', () {
      expect(provider.nowPlayingTvSeries, []);
      expect(provider.nowPlayingState, RequestState.Empty);
    });

    test('should get data from the usecase', () async {
      // arrange
      when(mockGetNowPlayingTvSeries.execute())
          .thenAnswer((_) async => Right(tTvSeriesList));

      // act
      await provider.fetchNowPlayingTvSeries();

      // assert
      verify(mockGetNowPlayingTvSeries.execute());
      expect(provider.nowPlayingTvSeries, tTvSeriesList);
      expect(provider.nowPlayingState, RequestState.Loaded);
      expect(listenerCallCount, 2);
    });

    test('should return error when data is unsuccessful', () async {
      // arrange
      when(mockGetNowPlayingTvSeries.execute())
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));

      // act
      await provider.fetchNowPlayingTvSeries();

      // assert
      verify(mockGetNowPlayingTvSeries.execute());
      expect(provider.nowPlayingState, RequestState.Error);
      expect(provider.message, 'Server Failure');
      expect(listenerCallCount, 2);
    });
  });

  group('popular tv series', () {
    test('initialState should be empty', () {
      expect(provider.popularTvSeries, []);
      expect(provider.popularState, RequestState.Empty);
    });

    test('should get data from the usecase', () async {
      // arrange
      when(mockGetPopularTvSeries.execute())
          .thenAnswer((_) async => Right(tTvSeriesList));

      // act
      await provider.fetchPopularTvSeries();

      // assert
      verify(mockGetPopularTvSeries.execute());
      expect(provider.popularTvSeries, tTvSeriesList);
      expect(provider.popularState, RequestState.Loaded);
      expect(listenerCallCount, 2);
    });

    test('should return error when data is unsuccessful', () async {
      // arrange
      when(mockGetPopularTvSeries.execute())
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));

      // act
      await provider.fetchPopularTvSeries();

      // assert
      verify(mockGetPopularTvSeries.execute());
      expect(provider.popularState, RequestState.Error);
      expect(provider.message, 'Server Failure');
      expect(listenerCallCount, 2);
    });
  });

  group('top rated tv series', () {
    test('initialState should be empty', () {
      expect(provider.topRatedTvSeries, []);
      expect(provider.topRatedState, RequestState.Empty);
    });

    test('should get data from the usecase', () async {
      // arrange
      when(mockGetTopRatedTvSeries.execute())
          .thenAnswer((_) async => Right(tTvSeriesList));

      // act
      await provider.fetchTopRatedTvSeries();

      // assert
      verify(mockGetTopRatedTvSeries.execute());
      expect(provider.topRatedTvSeries, tTvSeriesList);
      expect(provider.topRatedState, RequestState.Loaded);
      expect(listenerCallCount, 2);
    });

    test('should return error when data is unsuccessful', () async {
      // arrange
      when(mockGetTopRatedTvSeries.execute())
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));

      // act
      await provider.fetchTopRatedTvSeries();

      // assert
      verify(mockGetTopRatedTvSeries.execute());
      expect(provider.topRatedState, RequestState.Error);
      expect(provider.message, 'Server Failure');
      expect(listenerCallCount, 2);
    });
  });
}
