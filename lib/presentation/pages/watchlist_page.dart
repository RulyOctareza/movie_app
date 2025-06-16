import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/watchlist_tv_series_notifier.dart';
import '../widgets/tv_series_card.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
   
}

class _WatchlistPageState extends State<WatchlistPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
    
        Provider.of<WatchlistTvSeriesNotifier>(context, listen: false)
            .fetchWatchlistTvSeries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<WatchlistTvSeriesNotifier>(
          builder: (context, data, child) {
            if (data.watchlistState == RequestState.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (data.watchlistState == RequestState.loaded) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  final tvSeries = data.watchlistTvSeries[index];
                  return TvSeriesCard(tvSeries);
                },
                itemCount: data.watchlistTvSeries.length,
              );
            } else if (data.watchlistState == RequestState.error) {
              return Center(
                key: const Key('error_message'),
                child: Text(data.message),
              );
            } else {
              return const Center(
                child: Text('No watchlist added yet'),
              );
            }
          },
        ),
      ),
    );
  }
}
