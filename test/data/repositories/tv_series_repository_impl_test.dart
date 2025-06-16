import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:expert_flutter_dicoding/core/failure.dart';
import 'package:expert_flutter_dicoding/data/datasources/tv_series_local_data_source.dart';
import 'package:expert_flutter_dicoding/data/datasources/tv_series_remote_data_source.dart';
import 'package:expert_flutter_dicoding/data/models/tv_series_model.dart';
import 'package:expert_flutter_dicoding/data/repositories/tv_series_repository_impl.dart';
import 'package:expert_flutter_dicoding/domain/entities/tv_series.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'tv_series_repository_impl_test.mocks.dart';

@GenerateMocks([
  TvSeriesRemoteDataSource,
  TvSeriesLocalDataSource,
])
void main() {
  late TvSeriesRepositoryImpl repository;
  late MockTvSeriesRemoteDataSource mockRemoteDataSource;
  late MockTvSeriesLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockTvSeriesRemoteDataSource();
    mockLocalDataSource = MockTvSeriesLocalDataSource();
    repository = TvSeriesRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const tTvSeriesModel = TvSeriesModel(
    id: 1,
    name: 'Test Series',
    posterPath: '/path.jpg',
    overview: 'Overview',
    voteAverage: 8.0,
  );

  const tTvSeries = TvSeries(
    id: 1,
    name: 'Test Series',
    posterPath: '/path.jpg',
    overview: 'Overview',
    voteAverage: 8.0,
  );

  final tTvSeriesList = [tTvSeriesModel];

  group('Now Playing TV Series', () {
    test(
      'should return remote data when the call to remote data source is successful',
      () async {
        // arrange
        when(mockRemoteDataSource.getNowPlayingTvSeries())
            .thenAnswer((_) async => tTvSeriesList);
        // act
        final result = await repository.getNowPlayingTvSeries();
        // assert
        verify(mockRemoteDataSource.getNowPlayingTvSeries());
        final resultList = result.getOrElse(() => []);
        expect(resultList, [tTvSeries]);
      },
    );

    test(
      'should return server failure when the call to remote data source is unsuccessful',
      () async {
        // arrange
        when(mockRemoteDataSource.getNowPlayingTvSeries())
            .thenThrow(Exception());
        // act
        final result = await repository.getNowPlayingTvSeries();
        // assert
        verify(mockRemoteDataSource.getNowPlayingTvSeries());
        expect(result.isLeft(), true);
        expect(result, equals(const Left(ServerFailure('Exception'))));
      },
    );

    test(
      'should return connection failure when device has no internet',
      () async {
        // arrange
        when(mockRemoteDataSource.getNowPlayingTvSeries()).thenThrow(
            const SocketException('Failed to connect to the network'));
        // act
        final result = await repository.getNowPlayingTvSeries();
        // assert
        verify(mockRemoteDataSource.getNowPlayingTvSeries());
        expect(
          result,
          equals(const Left(
              ConnectionFailure('Failed to connect to the network'))),
        );
      },
    );
  });

  group('Popular TV Series', () {
    test(
      'should return remote data when call to data source is successful',
      () async {
        // arrange
        when(mockRemoteDataSource.getPopularTvSeries())
            .thenAnswer((_) async => tTvSeriesList);
        // act
        final result = await repository.getPopularTvSeries();
        // assert
        verify(mockRemoteDataSource.getPopularTvSeries());
        final resultList = result.getOrElse(() => []);
        expect(resultList, [tTvSeries]);
      },
    );

    test(
      'should return server failure when call to data source is unsuccessful',
      () async {
        // arrange
        when(mockRemoteDataSource.getPopularTvSeries()).thenThrow(Exception());
        // act
        final result = await repository.getPopularTvSeries();
        // assert
        verify(mockRemoteDataSource.getPopularTvSeries());
        expect(result.isLeft(), true);
        expect(result, equals(const Left(ServerFailure('Exception'))));
      },
    );

    test(
      'should return connection failure when device has no internet',
      () async {
        // arrange
        when(mockRemoteDataSource.getPopularTvSeries()).thenThrow(
            const SocketException('Failed to connect to the network'));
        // act
        final result = await repository.getPopularTvSeries();
        // assert
        verify(mockRemoteDataSource.getPopularTvSeries());
        expect(
          result,
          equals(const Left(
              ConnectionFailure('Failed to connect to the network'))),
        );
      },
    );
  });

  group('Top Rated TV Series', () {
    test(
      'should return remote data when call to data source is successful',
      () async {
        // arrange
        when(mockRemoteDataSource.getTopRatedTvSeries())
            .thenAnswer((_) async => tTvSeriesList);
        // act
        final result = await repository.getTopRatedTvSeries();
        // assert
        verify(mockRemoteDataSource.getTopRatedTvSeries());
        final resultList = result.getOrElse(() => []);
        expect(resultList, [tTvSeries]);
      },
    );

    test(
      'should return server failure when call to data source is unsuccessful',
      () async {
        // arrange
        when(mockRemoteDataSource.getTopRatedTvSeries()).thenThrow(Exception());
        // act
        final result = await repository.getTopRatedTvSeries();
        // assert
        verify(mockRemoteDataSource.getTopRatedTvSeries());
        expect(result.isLeft(), true);
        expect(result, equals(const Left(ServerFailure('Exception'))));
      },
    );

    test(
      'should return connection failure when device has no internet',
      () async {
        // arrange
        when(mockRemoteDataSource.getTopRatedTvSeries()).thenThrow(
            const SocketException('Failed to connect to the network'));
        // act
        final result = await repository.getTopRatedTvSeries();
        // assert
        verify(mockRemoteDataSource.getTopRatedTvSeries());
        expect(
          result,
          equals(const Left(
              ConnectionFailure('Failed to connect to the network'))),
        );
      },
    );
  });

  group('Get TV Series Detail', () {
    test(
      'should return TV Series data when call to remote data source is successful',
      () async {
        // arrange
        when(mockRemoteDataSource.getTvSeriesDetail(1))
            .thenAnswer((_) async => tTvSeriesModel);
        // act
        final result = await repository.getTvSeriesDetail(1);
        // assert
        verify(mockRemoteDataSource.getTvSeriesDetail(1));
        expect(result, equals(const Right(tTvSeries)));
      },
    );

    test(
      'should return Server Failure when call to remote data source is unsuccessful',
      () async {
        // arrange
        when(mockRemoteDataSource.getTvSeriesDetail(1)).thenThrow(Exception());
        // act
        final result = await repository.getTvSeriesDetail(1);
        // assert
        verify(mockRemoteDataSource.getTvSeriesDetail(1));
        expect(result, equals(const Left(ServerFailure('Exception'))));
      },
    );

    test(
      'should return Connection Failure when device has no internet',
      () async {
        // arrange
        when(mockRemoteDataSource.getTvSeriesDetail(1)).thenThrow(
            const SocketException('Failed to connect to the network'));
        // act
        final result = await repository.getTvSeriesDetail(1);
        // assert
        verify(mockRemoteDataSource.getTvSeriesDetail(1));
        expect(
          result,
          equals(const Left(
              ConnectionFailure('Failed to connect to the network'))),
        );
      },
    );
  });

  group('Get TV Series Recommendations', () {
    test(
      'should return list of TV Series Model when call to data source is successful',
      () async {
        // arrange
        when(mockRemoteDataSource.getTvSeriesRecommendations(1))
            .thenAnswer((_) async => tTvSeriesList);
        // act
        final result = await repository.getTvSeriesRecommendations(1);
        // assert
        verify(mockRemoteDataSource.getTvSeriesRecommendations(1));
        final resultList = result.getOrElse(() => []);
        expect(resultList, equals([tTvSeries]));
      },
    );

    test(
      'should return server failure when call to data source is unsuccessful',
      () async {
        // arrange
        when(mockRemoteDataSource.getTvSeriesRecommendations(1))
            .thenThrow(Exception());
        // act
        final result = await repository.getTvSeriesRecommendations(1);
        // assert
        verify(mockRemoteDataSource.getTvSeriesRecommendations(1));
        expect(result.isLeft(), true);
        expect(result, equals(const Left(ServerFailure('Exception'))));
      },
    );

    test(
      'should return connection failure when device has no internet',
      () async {
        // arrange
        when(mockRemoteDataSource.getTvSeriesRecommendations(1)).thenThrow(
            const SocketException('Failed to connect to the network'));
        // act
        final result = await repository.getTvSeriesRecommendations(1);
        // assert
        verify(mockRemoteDataSource.getTvSeriesRecommendations(1));
        expect(
          result,
          equals(const Left(
              ConnectionFailure('Failed to connect to the network'))),
        );
      },
    );
  });

  group('Search TV Series', () {
    const tQuery = 'game of thrones';

    test(
      'should return TV Series list when call to data source is successful',
      () async {
        // arrange
        when(mockRemoteDataSource.searchTvSeries(tQuery))
            .thenAnswer((_) async => tTvSeriesList);
        // act
        final result = await repository.searchTvSeries(tQuery);
        // assert
        verify(mockRemoteDataSource.searchTvSeries(tQuery));
        final resultList = result.getOrElse(() => []);
        expect(resultList, equals([tTvSeries]));
      },
    );

    test(
      'should return ServerFailure when call to data source is unsuccessful',
      () async {
        // arrange
        when(mockRemoteDataSource.searchTvSeries(tQuery))
            .thenThrow(Exception());
        // act
        final result = await repository.searchTvSeries(tQuery);
        // assert
        verify(mockRemoteDataSource.searchTvSeries(tQuery));
        expect(result.isLeft(), true);
        expect(result, equals(const Left(ServerFailure('Exception'))));
      },
    );

    test(
      'should return ConnectionFailure when device has no internet',
      () async {
        // arrange
        when(mockRemoteDataSource.searchTvSeries(tQuery)).thenThrow(
            const SocketException('Failed to connect to the network'));
        // act
        final result = await repository.searchTvSeries(tQuery);
        // assert
        verify(mockRemoteDataSource.searchTvSeries(tQuery));
        expect(
          result,
          equals(const Left(
              ConnectionFailure('Failed to connect to the network'))),
        );
      },
    );
  });

  group('Save Watchlist', () {
    test('should return success message when saving successful', () async {
      // arrange
      when(mockLocalDataSource.insertWatchlist(tTvSeriesModel))
          .thenAnswer((_) async => 'Added to Watchlist');
      // act
      final result = await repository.saveWatchlist(tTvSeries);
      // assert
      verify(mockLocalDataSource.insertWatchlist(tTvSeriesModel));
      expect(result, const Right('Added to Watchlist'));
    });

    test('should return DatabaseFailure when saving unsuccessful', () async {
      // arrange
      when(mockLocalDataSource.insertWatchlist(tTvSeriesModel))
          .thenThrow(Exception('Failed to add watchlist'));
      // act
      final result = await repository.saveWatchlist(tTvSeries);
      // assert
      verify(mockLocalDataSource.insertWatchlist(tTvSeriesModel));
      expect(result,
          equals(const Left(DatabaseFailure('Failed to add watchlist'))));
    });
  });

  group('Remove Watchlist', () {
    test('should return success message when remove successful', () async {
      // arrange
      when(mockLocalDataSource.removeWatchlist(tTvSeriesModel))
          .thenAnswer((_) async => 'Removed from Watchlist');
      // act
      final result = await repository.removeWatchlist(tTvSeries);
      // assert
      verify(mockLocalDataSource.removeWatchlist(tTvSeriesModel));
      expect(result, const Right('Removed from Watchlist'));
    });

    test('should return DatabaseFailure when remove unsuccessful', () async {
      // arrange
      when(mockLocalDataSource.removeWatchlist(tTvSeriesModel))
          .thenThrow(Exception('Failed to remove watchlist'));
      // act
      final result = await repository.removeWatchlist(tTvSeries);
      // assert
      verify(mockLocalDataSource.removeWatchlist(tTvSeriesModel));
      expect(result,
          equals(const Left(DatabaseFailure('Failed to remove watchlist'))));
    });
  });

  group('Get Watchlist Status', () {
    test('should return watch status whether data is found', () async {
      // arrange
      const tId = 1;
      when(mockLocalDataSource.getTvSeriesById(tId))
          .thenAnswer((_) async => null);
      // act
      final result = await repository.isAddedToWatchlist(tId);
      // assert
      verify(mockLocalDataSource.getTvSeriesById(tId));
      expect(result, false);
    });
  });

  group('Get Watchlist TV Series', () {
    test('should return list of TV Series', () async {
      // arrange
      when(mockLocalDataSource.getWatchlistTvSeries())
          .thenAnswer((_) async => [tTvSeriesModel]);
      // act
      final result = await repository.getWatchlistTvSeries();
      // assert
      verify(mockLocalDataSource.getWatchlistTvSeries());
      final resultList = result.getOrElse(() => []);
      expect(resultList, [tTvSeries]);
    });

    test('should return DatabaseFailure when error', () async {
      // arrange
      when(mockLocalDataSource.getWatchlistTvSeries())
          .thenThrow(Exception('Failed to get watchlist'));
      // act
      final result = await repository.getWatchlistTvSeries();
      // assert
      verify(mockLocalDataSource.getWatchlistTvSeries());
      expect(result,
          equals(const Left(DatabaseFailure('Failed to get watchlist'))));
    });
  });
}
