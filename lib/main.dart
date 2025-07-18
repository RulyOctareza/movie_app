import 'package:expert_flutter_dicoding/presentation/pages/movie_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/styles.dart';
import 'core/utils.dart';
import 'injection.dart' as di;
import 'presentation/pages/home_page.dart';
import 'presentation/pages/search_page.dart';
import 'presentation/pages/tv_series_detail_page.dart';
import 'presentation/pages/watchlist_page.dart';
import 'presentation/providers/tv_series_list_notifier.dart';
import 'presentation/providers/tv_series_search_notifier.dart';
import 'presentation/providers/tv_series_detail_notifier.dart';
import 'presentation/providers/watchlist_tv_series_notifier.dart';
import 'presentation/providers/movie_list_notifier.dart';
import 'presentation/providers/movie_detail_notifier.dart';
import 'presentation/providers/movie_search_notifier.dart';
import 'presentation/providers/watchlist_movie_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Movie providers
        ChangeNotifierProvider(
          create: (_) => di.locator<MovieListNotifier>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.locator<MovieDetailNotifier>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.locator<MovieSearchNotifier>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.locator<WatchlistMovieNotifier>(),
        ),
        // TV Series providers
        ChangeNotifierProvider(
          create: (_) => di.locator<TvSeriesListNotifier>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.locator<TvSeriesSearchNotifier>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.locator<TvSeriesDetailNotifier>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.locator<WatchlistTvSeriesNotifier>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Movie & TV Series App',
        theme: ThemeData.dark().copyWith(
          colorScheme: kColorScheme,
          primaryColor: kRichBlack,
          scaffoldBackgroundColor: kRichBlack,
          textTheme: kTextTheme,
        ),
        home: const HomePage(),
        navigatorObservers: [routeObserver],
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/home':
              return MaterialPageRoute(builder: (_) => const HomePage());
            case '/search':
              return MaterialPageRoute(builder: (_) => const SearchPage());
            case '/detail-movie':
              final id = settings.arguments as int;
              return MaterialPageRoute(
                builder: (_) => MovieDetailPage(id: id),
                settings: settings,
              );
            case '/detail-tv':
              final id = settings.arguments as int;
              return MaterialPageRoute(
                builder: (_) => TvSeriesDetailPage(id: id),
                settings: settings,
              );
            case '/watchlist':
              return MaterialPageRoute(builder: (_) => const WatchlistPage());
            default:
              return MaterialPageRoute(builder: (_) {
                return const Scaffold(
                  body: Center(
                    child: Text('Page not found :('),
                  ),
                );
              });
          }
        },
      ),
    );
  }
}
