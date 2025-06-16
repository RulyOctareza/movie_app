import 'package:expert_flutter_dicoding/domain/entities/season.dart';
import 'package:expert_flutter_dicoding/domain/entities/tv_series.dart';
import 'package:expert_flutter_dicoding/presentation/pages/tv_series_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget makeTestableWidget(Widget body) {
    return MaterialApp(
      home: body,
    );
  }

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
  });
}
