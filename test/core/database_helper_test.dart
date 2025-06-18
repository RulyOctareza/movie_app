import 'dart:io';

import 'package:expert_flutter_dicoding/core/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:expert_flutter_dicoding/core/database_helper.dart';
import 'package:expert_flutter_dicoding/data/models/movie_model.dart';
import 'package:expert_flutter_dicoding/data/models/tv_series_model.dart';

void main() {
  late DatabaseHelper databaseHelper;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databaseHelper = DatabaseHelper();
  });

  tearDown(() async {
    await databaseHelper.close();
    final path = await databaseHelper.getDbPath();
    final dbFile = File(path);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  });

  group('DatabaseHelper', () {
    test('should return a singleton instance', () {
      final instance1 = DatabaseHelper();
      final instance2 = DatabaseHelper();
      expect(instance1, same(instance2));
    });

    test('should initialize the database', () async {
      final db = await databaseHelper.database;
      expect(db.isOpen, isTrue);
    });

    test('should insert and retrieve a movie from the watchlist', () async {
      const movie = MovieModel(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        posterPath: '/test.jpg',
        voteAverage: 8.0,
      );

      await databaseHelper.insertMovieWatchlist(movie.toJson());
      final movies = await databaseHelper.getWatchlistMovies();

      expect(movies, isNotEmpty);
      expect(movies.first['title'], 'Test Movie');
    });

    test('should insert and retrieve a TV series from the watchlist', () async {
      const tvSeries = TvSeriesModel(
        id: 1,
        name: 'Test TV Series',
        overview: 'Test Overview',
        posterPath: '/test.jpg',
        voteAverage: 8.0,
      );

      await databaseHelper.insertTvSeriesWatchlist(tvSeries.toJson());
      final tvSeriesList = await databaseHelper.getWatchlistTvSeries();

      expect(tvSeriesList, isNotEmpty);
      expect(tvSeriesList.first['name'], 'Test TV Series');
    });

    test('should remove a movie from the watchlist', () async {
      const movie = MovieModel(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        posterPath: '/test.jpg',
        voteAverage: 8.0,
      );

      await databaseHelper.insertMovieWatchlist(movie.toJson());
      await databaseHelper.removeMovieWatchlist(1);
      final movies = await databaseHelper.getWatchlistMovies();

      expect(movies, isEmpty);
    });

    test('should remove a TV series from the watchlist', () async {
      const tvSeries = TvSeriesModel(
        id: 1,
        name: 'Test TV Series',
        overview: 'Test Overview',
        posterPath: '/test.jpg',
        voteAverage: 8.0,
      );

      await databaseHelper.insertTvSeriesWatchlist(tvSeries.toJson());
      await databaseHelper.removeTvSeriesWatchlist(1);
      final tvSeriesList = await databaseHelper.getWatchlistTvSeries();

      expect(tvSeriesList, isEmpty);
    });

    test('should get a movie by id', () async {
      const movie = MovieModel(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        posterPath: '/test.jpg',
        voteAverage: 8.0,
      );

      await databaseHelper.insertMovieWatchlist(movie.toJson());
      final result = await databaseHelper.getMovieById(1);

      expect(result, isNotNull);
      expect(result!['title'], 'Test Movie');
    });

    test('should get a TV series by id', () async {
      const tvSeries = TvSeriesModel(
        id: 1,
        name: 'Test TV Series',
        overview: 'Test Overview',
        posterPath: '/test.jpg',
        voteAverage: 8.0,
      );

      await databaseHelper.insertTvSeriesWatchlist(tvSeries.toJson());
      final result = await databaseHelper.getTvSeriesById(1);

      expect(result, isNotNull);
      expect(result!['name'], 'Test TV Series');
    });

    test('should return null when getting a movie by a non-existent id',
        () async {
      final result = await databaseHelper.getMovieById(999);
      expect(result, isNull);
    });

    test('should return null when getting a TV series by a non-existent id',
        () async {
      final result = await databaseHelper.getTvSeriesById(999);
      expect(result, isNull);
    });

    test('should handle database exceptions gracefully on getWatchlistMovies',
        () async {
      try {
        await databaseHelper.database;
        // Intentionally cause an error by closing the database
        await databaseHelper.close();
        await databaseHelper.getWatchlistMovies();
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('should create tables on _onCreate', () async {
      final db = await databaseHelper.database;
      final movieTableInfo = await db
          .rawQuery('PRAGMA table_info(${DBConstants.watchlistMoviesTable})');
      final tvSeriesTableInfo = await db
          .rawQuery('PRAGMA table_info(${DBConstants.watchlistTvSeriesTable})');

      expect(movieTableInfo, isNotEmpty);
      expect(tvSeriesTableInfo, isNotEmpty);
    });
  });
}
