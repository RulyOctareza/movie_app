import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'core/database_helper.dart';
import 'data/datasources/tv_series_local_data_source.dart';
import 'data/datasources/tv_series_remote_data_source.dart';
import 'data/repositories/tv_series_repository_impl.dart';
import 'domain/repositories/tv_series_repository.dart';
import 'domain/usecases/get_now_playing_tv_series.dart';
import 'domain/usecases/get_popular_tv_series.dart';
import 'domain/usecases/get_top_rated_tv_series.dart';
import 'domain/usecases/get_tv_series_detail.dart';
import 'domain/usecases/get_watchlist_tv_series.dart';
import 'domain/usecases/search_tv_series.dart';
import 'presentation/providers/tv_series_list_notifier.dart';
import 'presentation/providers/tv_series_detail_notifier.dart';
import 'presentation/providers/tv_series_search_notifier.dart';
import 'presentation/providers/watchlist_tv_series_notifier.dart';

final locator = GetIt.instance;

Future<void> init() async {
  // Database Helper
  locator.registerLazySingleton(() => DatabaseHelper.instance);

  // Data Sources
  locator.registerLazySingleton<TvSeriesRemoteDataSource>(
    () => TvSeriesRemoteDataSourceImpl(client: locator()),
  );
  locator.registerLazySingleton<TvSeriesLocalDataSource>(
    () => TvSeriesLocalDataSourceImpl(databaseHelper: locator()),
  );

  // Repository
  locator.registerLazySingleton<TvSeriesRepository>(
    () => TvSeriesRepositoryImpl(
      remoteDataSource: locator(),
      localDataSource: locator(),
    ),
  );

  // Use Cases
  locator.registerLazySingleton(() => GetNowPlayingTvSeries(locator()));
  locator.registerLazySingleton(() => GetPopularTvSeries(locator()));
  locator.registerLazySingleton(() => GetTopRatedTvSeries(locator()));
  locator.registerLazySingleton(() => GetTvSeriesDetail(locator()));
  locator.registerLazySingleton(() => SearchTvSeries(locator()));
  locator.registerLazySingleton(() => GetWatchlistTvSeries(locator()));

  // Providers
  locator.registerFactory(
    () => TvSeriesListNotifier(
      getNowPlayingTvSeries: locator(),
      getPopularTvSeries: locator(),
      getTopRatedTvSeries: locator(),
    ),
  );
  locator.registerFactory(
    () => TvSeriesDetailNotifier(
      getTvSeriesDetail: locator(),
      getWatchlistTvSeries: locator(),
    ),
  );
  locator.registerFactory(
    () => TvSeriesSearchNotifier(
      searchTvSeries: locator(),
    ),
  );
  locator.registerFactory(
    () => WatchlistTvSeriesNotifier(
      getWatchlistTvSeries: locator(),
    ),
  );

  // External
  locator.registerLazySingleton(() => http.Client());
}
