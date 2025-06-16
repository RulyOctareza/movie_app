import 'package:dartz/dartz.dart';
import 'package:expert_flutter_dicoding/domain/entities/tv_series.dart';
import 'package:expert_flutter_dicoding/domain/usecases/get_watchlist_tv_series.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late GetWatchlistTvSeries usecase;
  late MockTvSeriesRepository mockTvSeriesRepository;

  setUp(() {
    mockTvSeriesRepository = MockTvSeriesRepository();
    usecase = GetWatchlistTvSeries(mockTvSeriesRepository);
  });

  final tTvSeries = <TvSeries>[
    const TvSeries(
      id: 1,
      name: 'Test Series',
      posterPath: '/path.jpg',
      overview: 'Overview',
      voteAverage: 8.0,
    ),
  ];

  const tTvSeriesDetail = TvSeries(
    id: 1,
    name: 'Test Series',
    posterPath: '/path.jpg',
    overview: 'Overview',
    voteAverage: 8.0,
  );

  test('should get list of watchlist tv series from the repository', () async {
    // arrange
    when(mockTvSeriesRepository.getWatchlistTvSeries())
        .thenAnswer((_) async => Right(tTvSeries));

    // act
    final result = await usecase.execute();

    // assert
    expect(result, Right(tTvSeries));
    verify(mockTvSeriesRepository.getWatchlistTvSeries());
    verifyNoMoreInteractions(mockTvSeriesRepository);
  });

  test('should save watchlist tv series to the repository', () async {
    // arrange
    when(mockTvSeriesRepository.saveWatchlist(tTvSeriesDetail))
        .thenAnswer((_) async => const Right('Added to Watchlist'));

    // act
    final result = await usecase.saveWatchlist(tTvSeriesDetail);

    // assert
    verify(mockTvSeriesRepository.saveWatchlist(tTvSeriesDetail));
    expect(result, const Right('Added to Watchlist'));
  });

  test('should remove watchlist tv series from the repository', () async {
    // arrange
    when(mockTvSeriesRepository.removeWatchlist(tTvSeriesDetail))
        .thenAnswer((_) async => const Right('Removed from Watchlist'));

    // act
    final result = await usecase.removeWatchlist(tTvSeriesDetail);

    // assert
    verify(mockTvSeriesRepository.removeWatchlist(tTvSeriesDetail));
    expect(result, const Right('Removed from Watchlist'));
  });

  test('should check if tv series is in watchlist', () async {
    // arrange
    when(mockTvSeriesRepository.isAddedToWatchlist(1))
        .thenAnswer((_) async => true);

    // act
    final result = await usecase.isAddedToWatchlist(1);

    // assert
    expect(result, true);
    verify(mockTvSeriesRepository.isAddedToWatchlist(1));
    verifyNoMoreInteractions(mockTvSeriesRepository);
  });
}
