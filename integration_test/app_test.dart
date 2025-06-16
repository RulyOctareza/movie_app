import 'package:expert_flutter_dicoding/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TV Series App End-to-End Test', () {
    testWidgets(
      'Verify Season information is displayed in TV Series detail page',
      (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Find and tap first TV series in Now Playing
        final tvSeriesFinder = find.byType(Card).first;
        await tester.tap(tvSeriesFinder);
        await tester.pumpAndSettle();

        // Verify if season information is displayed
        expect(find.text('Seasons:'), findsOneWidget);
        expect(find.text('Season List'), findsOneWidget);

        // Go back to home page
        final backButton = find.byType(IconButton).first;
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Verify we're back at home page
        expect(find.text('TV Series'), findsOneWidget);
      },
    );

    testWidgets(
      'Can add and remove TV series from watchlist',
      (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to detail page
        final tvSeriesFinder = find.byType(Card).first;
        await tester.tap(tvSeriesFinder);
        await tester.pumpAndSettle();

        // Add to watchlist
        final watchlistButton = find.byType(ElevatedButton);
        await tester.tap(watchlistButton);
        await tester.pumpAndSettle();

        // Verify snackbar shows up
        expect(find.text('Added to Watchlist'), findsOneWidget);

        // Remove from watchlist
        await tester.tap(watchlistButton);
        await tester.pumpAndSettle();

        // Verify snackbar shows up
        expect(find.text('Removed from Watchlist'), findsOneWidget);
      },
    );
  });
}
