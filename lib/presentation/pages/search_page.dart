import 'package:expert_flutter_dicoding/core/state_enum.dart';
import 'package:expert_flutter_dicoding/presentation/providers/tv_series_search_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/movie_search_notifier.dart';

import '../widgets/movie_card.dart';
import '../widgets/tv_series_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    Provider.of<MovieSearchNotifier>(context, listen: false)
        .fetchMovieSearch(query);
    Provider.of<TvSeriesSearchNotifier>(context, listen: false)
        .fetchTvSeriesSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Movies'),
            Tab(text: 'TV Series'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Movies tab
                  Consumer<MovieSearchNotifier>(
                    builder: (context, data, child) {
                      if (data.state == RequestState.loading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (data.state == RequestState.loaded) {
                        final result = data.searchResult;
                        return ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            final movie = result[index];
                            return MovieCard(movie);
                          },
                          itemCount: result.length,
                        );
                      } else if (data.state == RequestState.error) {
                        return Center(
                          child: Text(data.message),
                        );
                      } else {
                        return const Center(
                          child: Text('Search for movies'),
                        );
                      }
                    },
                  ),
                  // TV Series tab
                  Consumer<TvSeriesSearchNotifier>(
                    builder: (context, data, child) {
                      if (data.state == RequestState.loading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (data.state == RequestState.loaded) {
                        final result = data.searchResult;
                        return ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            final tvSeries = result[index];
                            return TvSeriesCard(tvSeries);
                          },
                          itemCount: result.length,
                        );
                      } else if (data.state == RequestState.error) {
                        return Center(
                          child: Text(data.message),
                        );
                      } else {
                        return const Center(
                          child: Text('Search for TV series'),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
