import 'package:expert_flutter_dicoding/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_list_notifier.dart';
import '../providers/tv_series_list_notifier.dart';
import '../widgets/movie_list.dart';
import '../widgets/tv_series_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      // Initialize both movie and TV series data
      Provider.of<MovieListNotifier>(context, listen: false)
        ..fetchNowPlayingMovies()
        ..fetchPopularMovies()
        ..fetchTopRatedMovies();
      Provider.of<TvSeriesListNotifier>(context, listen: false)
        ..fetchNowPlayingTvSeries()
        ..fetchPopularTvSeries()
        ..fetchTopRatedTvSeries();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ditonton'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/watchlist');
            },
            icon: const Icon(Icons.bookmark),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Movies',
              icon: Icon(Icons.movie),
            ),
            Tab(
              text: 'TV Series',
              icon: Icon(Icons.tv),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Movies Tab
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Now Playing',
                    style: kHeading6,
                  ),
                  const NowPlayingMovieList(),
                  const SizedBox(height: 8),
                  Text(
                    'Popular',
                    style: kHeading6,
                  ),
                  const PopularMovieList(),
                  const SizedBox(height: 8),
                  Text(
                    'Top Rated',
                    style: kHeading6,
                  ),
                  const TopRatedMovieList(),
                ],
              ),
            ),
          ),
          // TV Series Tab
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Now Playing',
                    style: kHeading6,
                  ),
                  const NowPlayingTvSeriesList(),
                  const SizedBox(height: 8),
                  Text(
                    'Popular',
                    style: kHeading6,
                  ),
                  const PopularTvSeriesList(),
                  const SizedBox(height: 8),
                  Text(
                    'Top Rated',
                    style: kHeading6,
                  ),
                  const TopRatedTvSeriesList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
