import 'package:cached_network_image/cached_network_image.dart';
import 'package:expert_flutter_dicoding/core/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart' hide kTextTheme, kRichBlack;
import '../../domain/entities/tv_series.dart';
import '../providers/tv_series_detail_notifier.dart';

class TvSeriesDetailPage extends StatefulWidget {
  final int id;
  const TvSeriesDetailPage({required this.id, super.key});

  @override
  State<TvSeriesDetailPage> createState() => _TvSeriesDetailPageState();
}

class _TvSeriesDetailPageState extends State<TvSeriesDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider =
          Provider.of<TvSeriesDetailNotifier>(context, listen: false);
      provider.fetchTvSeriesDetail(widget.id);
      provider.loadWatchlistStatus(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TvSeriesDetailNotifier>(
        builder: (context, provider, child) {
          if (provider.tvSeriesState == RequestState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (provider.tvSeriesState == RequestState.loaded) {
            final tvSeries = provider.tvSeries;
            return DetailContent(
              tvSeries,
              provider.isAddedToWatchlist,
            );
          } else {
            return Text(provider.message);
          }
        },
      ),
    );
  }
}

class DetailContent extends StatelessWidget {
  final TvSeries tvSeries;
  final bool isAddedWatchlist;

  const DetailContent(this.tvSeries, this.isAddedWatchlist, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: '${Urls.baseImageUrl}${tvSeries.posterPath}',
          width: double.infinity,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        Container(
          margin: const EdgeInsets.only(top: 48 + 8),
          child: DraggableScrollableSheet(
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 16,
                  right: 16,
                ),
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tvSeries.name,
                              style: kTextTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: kRichBlack),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (!isAddedWatchlist) {
                                  await Provider.of<TvSeriesDetailNotifier>(
                                    context,
                                    listen: false,
                                  ).addWatchlist(tvSeries);
                                } else {
                                  await Provider.of<TvSeriesDetailNotifier>(
                                    context,
                                    listen: false,
                                  ).removeFromWatchlist(tvSeries);
                                }

                                final message =
                                    Provider.of<TvSeriesDetailNotifier>(
                                  context,
                                  listen: false,
                                ).watchlistMessage;

                                if (message == 'Added to Watchlist' ||
                                    message == 'Removed from Watchlist') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)));
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Text(message),
                                        );
                                      });
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  isAddedWatchlist
                                      ? const Icon(Icons.check)
                                      : const Icon(Icons.add),
                                  const Text('Watchlist'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Rating: ${tvSeries.voteAverage}',
                              style: kTextTheme.bodyMedium?.copyWith(
                                color: kRichBlack,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Add Seasons info
                            if (tvSeries.numberOfSeasons != null)
                              Text(
                                'Seasons: ${tvSeries.numberOfSeasons}',
                                style: kTextTheme.bodyMedium?.copyWith(
                                  color: kRichBlack,
                                ),
                              ),
                            if (tvSeries.numberOfEpisodes != null)
                              Text(
                                '${tvSeries.numberOfEpisodes} Episodes',
                                style: kTextTheme.bodyMedium?.copyWith(
                                  color: kRichBlack,
                                ),
                              ),
                            if (tvSeries.seasons?.isNotEmpty == true) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Season List',
                                style: kTextTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: kRichBlack,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: tvSeries.seasons?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final season = tvSeries.seasons![index];
                                  return Card(
                                    child: ListTile(
                                      leading: season.posterPath != null
                                          ? CachedNetworkImage(
                                              width: 50,
                                              imageUrl:
                                                  '${Urls.baseImageUrl}${season.posterPath}',
                                              placeholder: (context, url) =>
                                                  const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            )
                                          : null,
                                      title: Text(season.name),
                                      subtitle: Text(
                                          '${season.episodeCount} Episodes • ${season.airDate}'),
                                    ),
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: 16),
                            Text(
                              'Overview',
                              style: kTextTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: kRichBlack),
                            ),
                            Text(
                              tvSeries.overview,
                              style: kTextTheme.bodyMedium?.copyWith(
                                color: kRichBlack,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            minChildSize: 0.25,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          child: CircleAvatar(
            backgroundColor: Colors.white10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        )
      ],
    );
  }
}
