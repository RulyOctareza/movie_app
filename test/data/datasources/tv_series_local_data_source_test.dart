import 'package:expert_flutter_dicoding/core/constants.dart';
import 'package:expert_flutter_dicoding/core/database_helper.dart';
import 'package:expert_flutter_dicoding/data/datasources/tv_series_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

import '../../dummy_data/dummy_objects.dart';
import 'tv_series_local_data_source_test.mocks.dart';

// Mock class for Database
class MockDatabase extends Mock implements Database {
  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (table == DBConstants.watchlistTable) {
      if (where == null) {
        // getWatchlistTvSeries()
        return [testTvSeriesModel.toJson()];
      } else if (where == 'id = ?') {
        // getTvSeriesById()
        final id = whereArgs?.first as int;
        if (id == 1) {
          return [testTvSeriesModel.toJson()];
        }
      }
    }
    return [];
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return 1;
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return 1;
  }
}

@GenerateMocks([DatabaseHelper])
void main() {
  late TvSeriesLocalDataSourceImpl dataSource;
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    dataSource =
        TvSeriesLocalDataSourceImpl(databaseHelper: mockDatabaseHelper);
  });

  group('Save Watchlist', () {
    test('should return success message when insert to database is success',
        () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => MockDatabase());
      // act
      final result = await dataSource.insertWatchlist(testTvSeriesModel);
      // assert
      expect(result, 'Added to Watchlist');
    });

    test('should throw DatabaseException when insert to database is failed',
        () async {
      // arrange
      when(mockDatabaseHelper.database).thenThrow(Exception());
      // act
      final call = dataSource.insertWatchlist(testTvSeriesModel);
      // assert
      expect(() => call, throwsA(isA<Exception>()));
    });
  });

  group('Remove Watchlist', () {
    test('should return success message when remove from database is success',
        () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => MockDatabase());
      // act
      final result = await dataSource.removeWatchlist(testTvSeriesModel);
      // assert
      expect(result, 'Removed from Watchlist');
    });

    test('should throw DatabaseException when remove from database is failed',
        () async {
      // arrange
      when(mockDatabaseHelper.database).thenThrow(Exception());
      // act
      final call = dataSource.removeWatchlist(testTvSeriesModel);
      // assert
      expect(() => call, throwsA(isA<Exception>()));
    });
  });

  group('Get TV Series Detail By Id', () {
    const tId = 1;

    test('should return TV Series Detail Table when data is found', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => MockDatabase());
      // act
      final result = await dataSource.getTvSeriesById(tId);
      // assert
      expect(result, testTvSeriesModel);
    });

    test('should return null when data is not found', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => MockDatabase());
      // act
      final result = await dataSource.getTvSeriesById(2); // Use different ID to test not found case
      // assert
      expect(result, isNull);
    });
  });

  group('Get Watchlist TV Series', () {
    test('should return list of TvSeriesTable from database', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => MockDatabase());
      // act
      final result = await dataSource.getWatchlistTvSeries();
      // assert
      expect(result, [testTvSeriesModel]);
    });
  });
}
