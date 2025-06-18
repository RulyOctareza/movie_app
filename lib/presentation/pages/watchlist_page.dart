import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/watchlist_movie_notifier.dart';
import '../providers/watchlist_tv_series_notifier.dart';
import '../widgets/movie_card.dart';
import '../widgets/tv_series_card.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    Future.microtask(() {
      Provider.of<WatchlistMovieNotifier>(context, listen: false)
          .fetchWatchlistMovies();
      Provider.of<WatchlistTvSeriesNotifier>(context, listen: false)
          .fetchWatchlistTvSeries();
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
        title: const Text('Watchlist'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Movies'),
            Tab(text: 'TV Series'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Movies tab
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<WatchlistMovieNotifier>(
              builder: (context, data, child) {
                if (data.watchlistState == RequestState.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (data.watchlistState == RequestState.error) {
                  return Center(
                    key: const Key('error_message'),
                    child: Text(data.message),
                  );
                } else if (data.watchlistState == RequestState.loaded) {
                  if (data.watchlistMovies.isEmpty) {
                    return const Center(
                      child: Text('No watchlist movies added yet'),
                    );
                  }
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      final movie = data.watchlistMovies[index];
                      return MovieCard(movie);
                    },
                    itemCount: data.watchlistMovies.length,
                  );
                } else {
                  // For the empty state or any other unexpected state
                  return const Center(
                    child: Text('No watchlist movies added yet'),
                  );
                }
              },
            ),
          ),
          // TV Series tab
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<WatchlistTvSeriesNotifier>(
              builder: (context, data, child) {
                if (data.watchlistState == RequestState.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (data.watchlistState == RequestState.error) {
                  return Center(
                    key: const Key('error_message'),
                    child: Text(data.message),
                  );
                } else if (data.watchlistState == RequestState.loaded) {
                  if (data.watchlistTvSeries.isEmpty) {
                    return const Center(
                      child: Text('No watchlist TV series added yet'),
                    );
                  }
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      final tvSeries = data.watchlistTvSeries[index];
                      return TvSeriesCard(tvSeries);
                    },
                    itemCount: data.watchlistTvSeries.length,
                  );
                } else {
                  // For the empty state or any other unexpected state
                  return const Center(
                    child: Text('No watchlist TV series added yet'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
