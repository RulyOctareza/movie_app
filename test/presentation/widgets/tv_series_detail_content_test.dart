import 'package:expert_flutter_dicoding/core/state_enum.dart';
import 'package:expert_flutter_dicoding/domain/entities/season.dart';
import 'package:expert_flutter_dicoding/domain/entities/tv_series.dart';
import 'package:expert_flutter_dicoding/presentation/pages/tv_series_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expert_flutter_dicoding/presentation/providers/tv_series_detail_notifier.dart';
import 'package:expert_flutter_dicoding/domain/usecases/get_tv_series_detail.dart';
import 'package:expert_flutter_dicoding/domain/usecases/get_watchlist_tv_series.dart';
import 'package:expert_flutter_dicoding/domain/usecases/get_tv_series_recommendations.dart';
import '../../dummy/dummy_tv_series_repository.dart';

const testTvSeries = TvSeries(
  id: 1,
  name: 'name',
  posterPath: 'posterPath',
  overview: 'overview',
  voteAverage: 1.0,
  numberOfSeasons: 2,
  numberOfEpisodes: 24,
  seasons: [
    Season(
      id: 1,
      name: 'Season 1',
      overview: 'First season',
      posterPath: '/path.jpg',
      seasonNumber: 1,
      episodeCount: 12,
      airDate: '2021-01-01',
    ),
    Season(
      id: 2,
      name: 'Season 2',
      overview: 'Second season',
      posterPath: '/path.jpg',
      seasonNumber: 2,
      episodeCount: 12,
      airDate: '2022-01-01',
    ),
  ],
);

class DummyTvSeriesDetailNotifier extends TvSeriesDetailNotifier {
  DummyTvSeriesDetailNotifier()
      : super(
          getTvSeriesDetail: GetTvSeriesDetail(DummyTvSeriesRepository()),
          getWatchlistTvSeries: GetWatchlistTvSeries(DummyTvSeriesRepository()),
          getTvSeriesRecommendations:
              GetTvSeriesRecommendations(DummyTvSeriesRepository()),
        );
  @override
  bool get isAddedToWatchlist => false;
  @override
  String get message => '';
  @override
  String get watchlistMessage => '';
  @override
  TvSeries get tvSeries => testTvSeries;
  @override
  RequestState get tvSeriesState => RequestState.loaded;
  @override
  List<TvSeries> get tvSeriesRecommendations => [];
  @override
  RequestState get recommendationState => RequestState.loaded;
}

Widget makeTestableWidget(Widget body, {TvSeriesDetailNotifier? notifier}) {
  return MaterialApp(
    home: ChangeNotifierProvider<TvSeriesDetailNotifier>.value(
      value: notifier ?? DummyTvSeriesDetailNotifier(),
      child: body,
    ),
  );
}

void main() {
  group('Detail Content Widget Test', () {
    testWidgets(
      'should display season information when available',
      (WidgetTester tester) async {
        final contentFinder = find.byType(DetailContent);
        final seasonTextFinder = find.text('Season List');
        final episodeTextFinder = find.text('24 Episodes');
        final seasonsFinder = find.text('Seasons: 2');

        await tester.pumpWidget(makeTestableWidget(
          const DetailContent(testTvSeries, false),
        ));

        expect(contentFinder, findsOneWidget);
        expect(seasonTextFinder, findsOneWidget);
        expect(episodeTextFinder, findsWidgets);
        expect(seasonsFinder, findsOneWidget);
      },
    );

    testWidgets(
      'should not display season information when not available',
      (WidgetTester tester) async {
        const testTvSeriesWithoutSeasons = TvSeries(
          id: 1,
          name: 'name',
          posterPath: 'posterPath',
          overview: 'overview',
          voteAverage: 1.0,
        );

        final seasonTextFinder = find.text('Season List');
        final episodeTextFinder = find.text('Episodes');
        final seasonsFinder = find.text('Seasons');

        await tester.pumpWidget(makeTestableWidget(
          const DetailContent(testTvSeriesWithoutSeasons, false),
        ));

        expect(seasonTextFinder, findsNothing);
        expect(episodeTextFinder, findsNothing);
        expect(seasonsFinder, findsNothing);
      },
    );

    testWidgets(
      'should show add to watchlist button when not in watchlist',
      (WidgetTester tester) async {
        await tester.pumpWidget(makeTestableWidget(
          const DetailContent(testTvSeries, false),
        ));

        final watchlistButtonFinder = find.byType(ElevatedButton);
        final addIconFinder = find.byIcon(Icons.add);

        expect(watchlistButtonFinder, findsOneWidget);
        expect(addIconFinder, findsOneWidget);
      },
    );

    testWidgets(
      'should show check icon when in watchlist',
      (WidgetTester tester) async {
        await tester.pumpWidget(makeTestableWidget(
          const DetailContent(testTvSeries, true),
        ));

        final watchlistButtonFinder = find.byType(ElevatedButton);
        final checkIconFinder = find.byIcon(Icons.check);

        expect(watchlistButtonFinder, findsOneWidget);
        expect(checkIconFinder, findsOneWidget);
      },
    );

    testWidgets(
      'should display back button and handle navigation',
      (WidgetTester tester) async {
        await tester.pumpWidget(makeTestableWidget(
          const DetailContent(testTvSeries, false),
        ));

        final backButtonFinder = find.byIcon(Icons.arrow_back);
        expect(backButtonFinder, findsOneWidget);

        await tester.tap(backButtonFinder);
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'should show loading indicator when loading image',
      (WidgetTester tester) async {
        await tester.pumpWidget(makeTestableWidget(
          const DetailContent(testTvSeries, false),
        ));

        // Verify that CircularProgressIndicator is shown while loading
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      },
    );
  });
}
