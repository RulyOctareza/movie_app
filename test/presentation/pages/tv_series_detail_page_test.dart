import 'package:expert_flutter_dicoding/core/state_enum.dart';
import 'package:expert_flutter_dicoding/domain/entities/tv_series.dart';
import 'package:expert_flutter_dicoding/presentation/pages/tv_series_detail_page.dart';
import 'package:expert_flutter_dicoding/presentation/providers/tv_series_detail_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'tv_series_detail_page_test.mocks.dart';

@GenerateMocks([TvSeriesDetailNotifier])
void main() {
  late MockTvSeriesDetailNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockTvSeriesDetailNotifier();
  });

  Widget makeTestableWidget(Widget body) {
    return ChangeNotifierProvider<TvSeriesDetailNotifier>.value(
      value: mockNotifier,
      child: MaterialApp(
        home: body,
      ),
    );
  }

  const testTvSeries = TvSeries(
    id: 1,
    name: 'name',
    posterPath: 'posterPath',
    overview: 'overview',
    voteAverage: 1.0,
  );

  testWidgets(
    'should show progress indicator when loading',
    (WidgetTester tester) async {
      when(mockNotifier.tvSeriesState).thenReturn(RequestState.loading);

      await tester
          .pumpWidget(makeTestableWidget(const TvSeriesDetailPage(id: 1)));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'should show error message when error',
    (WidgetTester tester) async {
      when(mockNotifier.tvSeriesState).thenReturn(RequestState.error);
      when(mockNotifier.message).thenReturn('Error message');

      await tester
          .pumpWidget(makeTestableWidget(const TvSeriesDetailPage(id: 1)));

      expect(find.text('Error message'), findsOneWidget);
    },
  );

  testWidgets(
    'should show TV Series detail when data is loaded',
    (WidgetTester tester) async {
      when(mockNotifier.tvSeriesState).thenReturn(RequestState.loaded);
      when(mockNotifier.tvSeries).thenReturn(testTvSeries);
      when(mockNotifier.isAddedToWatchlist).thenReturn(false);
      when(mockNotifier.recommendationState).thenReturn(RequestState.loaded);
      when(mockNotifier.tvSeriesRecommendations).thenReturn([]);

      await tester
          .pumpWidget(makeTestableWidget(const TvSeriesDetailPage(id: 1)));

      expect(find.byType(DetailContent), findsOneWidget);
    },
  );
}
