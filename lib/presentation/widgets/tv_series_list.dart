import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../domain/entities/tv_series.dart';
import '../providers/tv_series_list_notifier.dart';

// Base list widget
class TvSeriesList extends StatelessWidget {
  final List<TvSeries> tvSeries;

  const TvSeriesList(this.tvSeries, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final series = tvSeries[index];
          return Container(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detail-tv',
                  arguments: series.id,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: '${Urls.baseImageUrl}${series.posterPath}',
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          );
        },
        itemCount: tvSeries.length,
      ),
    );
  }
}

// Now Playing TV Series List
class NowPlayingTvSeriesList extends StatelessWidget {
  const NowPlayingTvSeriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TvSeriesListNotifier>(
      builder: (context, data, child) {
        final state = data.nowPlayingState;
        if (state == RequestState.Loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state == RequestState.Loaded) {
          return TvSeriesList(data.nowPlayingTvSeries);
        } else {
          return const Text('Failed to load now playing TV series');
        }
      },
    );
  }
}

// Popular TV Series List
class PopularTvSeriesList extends StatelessWidget {
  const PopularTvSeriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TvSeriesListNotifier>(
      builder: (context, data, child) {
        final state = data.popularState;
        if (state == RequestState.Loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state == RequestState.Loaded) {
          return TvSeriesList(data.popularTvSeries);
        } else {
          return const Text('Failed to load popular TV series');
        }
      },
    );
  }
}

// Top Rated TV Series List
class TopRatedTvSeriesList extends StatelessWidget {
  const TopRatedTvSeriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TvSeriesListNotifier>(
      builder: (context, data, child) {
        final state = data.topRatedState;
        if (state == RequestState.Loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state == RequestState.Loaded) {
          return TvSeriesList(data.topRatedTvSeries);
        } else {
          return const Text('Failed to load top rated TV series');
        }
      },
    );
  }
}
