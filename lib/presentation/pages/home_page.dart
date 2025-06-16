import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tv_series_list_notifier.dart';
import '../widgets/tv_series_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TvSeriesListNotifier>(context, listen: false)
        ..fetchNowPlayingTvSeries()
        ..fetchPopularTvSeries()
        ..fetchTopRatedTvSeries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TV Series'),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Now Playing',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Consumer<TvSeriesListNotifier>(
                builder: (context, data, child) {
                  if (data.nowPlayingState == RequestState.Loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (data.nowPlayingState == RequestState.Loaded) {
                    return TvSeriesList(data.nowPlayingTvSeries);
                  } else {
                    return const Text('Failed');
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Popular',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Consumer<TvSeriesListNotifier>(
                builder: (context, data, child) {
                  if (data.popularState == RequestState.Loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (data.popularState == RequestState.Loaded) {
                    return TvSeriesList(data.popularTvSeries);
                  } else {
                    return const Text('Failed');
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Top Rated',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Consumer<TvSeriesListNotifier>(
                builder: (context, data, child) {
                  if (data.topRatedState == RequestState.Loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (data.topRatedState == RequestState.Loaded) {
                    return TvSeriesList(data.topRatedTvSeries);
                  } else {
                    return const Text('Failed');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
