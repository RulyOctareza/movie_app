import 'package:dartz/dartz.dart';
import 'package:expert_flutter_dicoding/core/failure.dart';
import 'package:expert_flutter_dicoding/core/state_enum.dart';
import 'package:expert_flutter_dicoding/domain/entities/tv_series.dart';
import 'package:expert_flutter_dicoding/domain/usecases/get_tv_series_detail.dart';
import 'package:expert_flutter_dicoding/domain/usecases/get_watchlist_tv_series.dart';
import 'package:expert_flutter_dicoding/domain/usecases/get_tv_series_recommendations.dart';
import 'package:expert_flutter_dicoding/presentation/providers/tv_series_detail_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'tv_series_detail_notifier_test.mocks.dart';

@GenerateMocks([
  GetTvSeriesDetail,
  GetWatchlistTvSeries,
  GetTvSeriesRecommendations,
])
void main() {
  late TvSeriesDetailNotifier provider;
  late GetTvSeriesDetail mockGetTvSeriesDetail;
  late GetWatchlistTvSeries mockGetWatchlistTvSeries;
  late GetTvSeriesRecommendations mockGetTvSeriesRecommendations;
  late int listenerCallCount;

  const tId = 1;
  const tTvSeries = TvSeries(
    id: 1,
    name: 'Test Series',
    posterPath: '/path.jpg',
    overview: 'Overview',
    voteAverage: 8.0,
  );

  setUp(() {
    listenerCallCount = 0;
    mockGetTvSeriesDetail = MockGetTvSeriesDetail();
    mockGetWatchlistTvSeries = MockGetWatchlistTvSeries();
    mockGetTvSeriesRecommendations = MockGetTvSeriesRecommendations();
    when(mockGetTvSeriesRecommendations.execute(tId))
        .thenAnswer((_) async => const Right(<TvSeries>[]));
    provider = TvSeriesDetailNotifier(
      getTvSeriesDetail: mockGetTvSeriesDetail,
      getWatchlistTvSeries: mockGetWatchlistTvSeries,
      getTvSeriesRecommendations: mockGetTvSeriesRecommendations,
    )..addListener(() {
        listenerCallCount++;
      });
  });

  group('Get TV Series Detail', () {
    test('should get data from the usecase', () async {
      // arrange
      when(mockGetTvSeriesDetail.execute(tId))
          .thenAnswer((_) async => const Right(tTvSeries));
      when(mockGetWatchlistTvSeries.isAddedToWatchlist(tId))
          .thenAnswer((_) async => false);

      // act
      await provider.fetchTvSeriesDetail(tId);

      // assert
      verify(mockGetTvSeriesDetail.execute(tId));
      expect(provider.tvSeriesState, RequestState.loaded);
      expect(provider.tvSeries, tTvSeries);
      expect(listenerCallCount, 3); // 2 (detail) + 3 (rekomendasi)
    });

    test('should return error when data is unsuccessful', () async {
      // arrange
      when(mockGetTvSeriesDetail.execute(tId))
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      when(mockGetWatchlistTvSeries.isAddedToWatchlist(tId))
          .thenAnswer((_) async => false);

      // act
      await provider.fetchTvSeriesDetail(tId);

      // assert
      verify(mockGetTvSeriesDetail.execute(tId));
      expect(provider.tvSeriesState, RequestState.error);
      expect(provider.message, 'Server Failure');
      expect(listenerCallCount, 2);
    });
  });

  group('Watchlist', () {
    test('should get the watchlist status', () async {
      // arrange
      when(mockGetWatchlistTvSeries.isAddedToWatchlist(tId))
          .thenAnswer((_) async => true);

      // act
      await provider.loadWatchlistStatus(tId);

      // assert
      verify(mockGetWatchlistTvSeries.isAddedToWatchlist(tId));
      expect(provider.isAddedToWatchlist, true);
      expect(listenerCallCount, 1);
    });

    test('should execute save watchlist when function called', () async {
      // arrange
      when(mockGetWatchlistTvSeries.saveWatchlist(tTvSeries))
          .thenAnswer((_) async => const Right('Added to Watchlist'));
      when(mockGetWatchlistTvSeries.isAddedToWatchlist(tTvSeries.id))
          .thenAnswer((_) async => true);

      // act
      await provider.addWatchlist(tTvSeries);

      // assert
      verify(mockGetWatchlistTvSeries.saveWatchlist(tTvSeries));
      expect(provider.watchlistMessage, 'Added to Watchlist');
      expect(provider.isAddedToWatchlist, true);
      expect(listenerCallCount, 1);
    });

    test('should execute remove watchlist when function called', () async {
      // arrange
      when(mockGetWatchlistTvSeries.removeWatchlist(tTvSeries))
          .thenAnswer((_) async => const Right('Removed from Watchlist'));
      when(mockGetWatchlistTvSeries.isAddedToWatchlist(tTvSeries.id))
          .thenAnswer((_) async => false);

      // act
      await provider.removeFromWatchlist(tTvSeries);

      // assert
      verify(mockGetWatchlistTvSeries.removeWatchlist(tTvSeries));
      expect(provider.watchlistMessage, 'Removed from Watchlist');
      expect(provider.isAddedToWatchlist, false);
      expect(listenerCallCount, 1);
    });

    test('should update watchlist status when add watchlist success', () async {
      // arrange
      when(mockGetWatchlistTvSeries.saveWatchlist(tTvSeries))
          .thenAnswer((_) async => const Right('Added to Watchlist'));
      when(mockGetWatchlistTvSeries.isAddedToWatchlist(tTvSeries.id))
          .thenAnswer((_) async => true);

      // act
      await provider.addWatchlist(tTvSeries);

      // assert
      verify(mockGetWatchlistTvSeries.isAddedToWatchlist(tTvSeries.id));
      expect(provider.isAddedToWatchlist, true);
      expect(provider.watchlistMessage, 'Added to Watchlist');
      expect(listenerCallCount, 1);
    });

    test('should update watchlist status when remove watchlist success',
        () async {
      // arrange
      when(mockGetWatchlistTvSeries.removeWatchlist(tTvSeries))
          .thenAnswer((_) async => const Right('Removed from Watchlist'));
      when(mockGetWatchlistTvSeries.isAddedToWatchlist(tTvSeries.id))
          .thenAnswer((_) async => false);

      // act
      await provider.removeFromWatchlist(tTvSeries);

      // assert
      verify(mockGetWatchlistTvSeries.isAddedToWatchlist(tTvSeries.id));
      expect(provider.isAddedToWatchlist, false);
      expect(provider.watchlistMessage, 'Removed from Watchlist');
      expect(listenerCallCount, 1);
    });

    test('should handle failure when saving watchlist fails', () async {
      // arrange
      when(mockGetWatchlistTvSeries.saveWatchlist(tTvSeries)).thenAnswer(
          (_) async => const Left(DatabaseFailure('Database Failure')));
      when(mockGetWatchlistTvSeries.isAddedToWatchlist(tTvSeries.id))
          .thenAnswer((_) async => false);

      // act
      await provider.addWatchlist(tTvSeries);

      // assert
      verify(mockGetWatchlistTvSeries.saveWatchlist(tTvSeries));
      expect(provider.watchlistMessage, 'Database Failure');
      expect(provider.isAddedToWatchlist, false);
      expect(listenerCallCount, 1);
    });

    test('should handle failure when removing from watchlist fails', () async {
      // arrange
      when(mockGetWatchlistTvSeries.removeWatchlist(tTvSeries)).thenAnswer(
          (_) async => const Left(DatabaseFailure('Database Failure')));
      when(mockGetWatchlistTvSeries.isAddedToWatchlist(tTvSeries.id))
          .thenAnswer((_) async => true);

      // act
      await provider.removeFromWatchlist(tTvSeries);

      // assert
      verify(mockGetWatchlistTvSeries.removeWatchlist(tTvSeries));
      expect(provider.watchlistMessage, 'Database Failure');
      expect(provider.isAddedToWatchlist, true);
      expect(listenerCallCount, 1);
    });
  });
}
