import 'package:dartz/dartz.dart';
import 'package:expert_flutter_dicoding/core/failure.dart';
import 'package:expert_flutter_dicoding/core/state_enum.dart';
import 'package:expert_flutter_dicoding/domain/entities/tv_series.dart';
import 'package:expert_flutter_dicoding/domain/usecases/get_watchlist_tv_series.dart';
import 'package:expert_flutter_dicoding/presentation/providers/watchlist_tv_series_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'watchlist_tv_series_notifier_test.mocks.dart';

@GenerateMocks([GetWatchlistTvSeries])
void main() {
  late WatchlistTvSeriesNotifier provider;
  late GetWatchlistTvSeries mockGetWatchlistTvSeries;
  late int listenerCallCount;

  setUp(() {
    listenerCallCount = 0;
    mockGetWatchlistTvSeries = MockGetWatchlistTvSeries();
    provider = WatchlistTvSeriesNotifier(
      getWatchlistTvSeries: mockGetWatchlistTvSeries,
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

  test('should get watchlist tv series data from usecase', () async {
    // arrange
    when(mockGetWatchlistTvSeries.execute())
        .thenAnswer((_) async => Right(tTvSeriesList));

    // act
    await provider.fetchWatchlistTvSeries();

    // assert
    verify(mockGetWatchlistTvSeries.execute());
    expect(provider.watchlistTvSeries, tTvSeriesList);
    expect(provider.watchlistState, RequestState.loaded);
    expect(listenerCallCount, 2);
  });

  test('should return error when data is unsuccessful', () async {
    // arrange
    when(mockGetWatchlistTvSeries.execute()).thenAnswer(
        (_) async => const Left(DatabaseFailure('Database Failure')));

    // act
    await provider.fetchWatchlistTvSeries();

    // assert
    verify(mockGetWatchlistTvSeries.execute());
    expect(provider.watchlistState, RequestState.error);
    expect(provider.message, 'Database Failure');
    expect(listenerCallCount, 2);
  });
}
