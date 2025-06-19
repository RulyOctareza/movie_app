import 'package:cached_network_image/cached_network_image.dart';
import 'package:expert_flutter_dicoding/core/state_enum.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart' hide kRichBlack, kTextTheme;
import '../../core/styles.dart';
import '../../domain/entities/movie.dart';
import '../providers/movie_detail_notifier.dart';

class MovieDetailPage extends StatefulWidget {
  static const routeName = '/detail-movie';

  final int id;
  const MovieDetailPage({required this.id, super.key});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MovieDetailNotifier>(context, listen: false)
        ..fetchMovieDetail(widget.id)
        ..loadWatchlistStatus(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MovieDetailNotifier>(
        builder: (context, provider, child) {
          if (provider.movieState == RequestState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (provider.movieState == RequestState.loaded) {
            final movie = provider.movie;
            return DetailContent(
              movie,
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
  final Movie movie;
  final bool isAddedWatchlist;

  const DetailContent(this.movie, this.isAddedWatchlist, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: '${Urls.baseImageUrl}${movie.posterPath}',
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
                  color: kRichBlack,
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
                              movie.title,
                              style: kTextTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: kMikadoYellow,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (!isAddedWatchlist) {
                                  await Provider.of<MovieDetailNotifier>(
                                    context,
                                    listen: false,
                                  ).addWatchlist(movie);
                                } else {
                                  await Provider.of<MovieDetailNotifier>(
                                    context,
                                    listen: false,
                                  ).removeFromWatchlist(movie);
                                }

                                final message =
                                    Provider.of<MovieDetailNotifier>(
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrussianBlue,
                                foregroundColor: Colors.white,
                              ),
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
                              'Overview',
                              style: kTextTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: kMikadoYellow,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              movie.overview,
                              style: kTextTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Rating: ${movie.voteAverage}',
                              style: kTextTheme.bodyMedium?.copyWith(
                                color: kMikadoYellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          child: CircleAvatar(
            backgroundColor: kRichBlack,
            foregroundColor: Colors.white,
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
