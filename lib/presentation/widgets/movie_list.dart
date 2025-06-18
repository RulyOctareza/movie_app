import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/movie_list_notifier.dart';
import '../../core/state_enum.dart';
import '../../domain/entities/movie.dart';

class NowPlayingMovieList extends StatelessWidget {
  const NowPlayingMovieList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieListNotifier>(
      builder: (context, data, child) {
        final state = data.nowPlayingState;
        if (state == RequestState.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state == RequestState.loaded) {
          return MovieListView(movies: data.nowPlayingMovies);
        } else {
          return const Text('Failed');
        }
      },
    );
  }
}

class PopularMovieList extends StatelessWidget {
  const PopularMovieList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieListNotifier>(
      builder: (context, data, child) {
        final state = data.popularMoviesState;
        if (state == RequestState.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state == RequestState.loaded) {
          return MovieListView(movies: data.popularMovies);
        } else {
          return const Text('Failed');
        }
      },
    );
  }
}

class TopRatedMovieList extends StatelessWidget {
  const TopRatedMovieList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieListNotifier>(
      builder: (context, data, child) {
        final state = data.topRatedMoviesState;
        if (state == RequestState.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state == RequestState.loaded) {
          return MovieListView(movies: data.topRatedMovies);
        } else {
          return const Text('Failed');
        }
      },
    );
  }
}

class MovieListView extends StatelessWidget {
  final List<Movie> movies;

  const MovieListView({
    super.key,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Container(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detail-movie',
                  arguments: movie.id,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          );
        },
        itemCount: movies.length,
      ),
    );
  }
}
