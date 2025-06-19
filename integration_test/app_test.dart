import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:expert_flutter_dicoding/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simple End-to-End Test -', () {
    testWidgets('Add movie to watchlist and verify it exists',
        (WidgetTester tester) async {
      app.main();

      debugPrint("App starting... Waiting for initial data to load.");
      await tester.pumpAndSettle(const Duration(seconds: 10));
      debugPrint("App is ready.");

      final firstMovieCard = find.byType(Card).first;

      expect(firstMovieCard, findsOneWidget,
          reason: 'Should find at least one movie card on screen');
      debugPrint("Found the first movie in the 'Now Playing' list.");

      await tester.tap(firstMovieCard);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugPrint("Navigated to Movie Detail page.");

      final addToWatchlistButton = find.byIcon(Icons.add);
      expect(addToWatchlistButton, findsOneWidget,
          reason: 'Add to Watchlist button should be visible');

      await tester.tap(addToWatchlistButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      debugPrint("Tapped 'Add to Watchlist'.");

      expect(find.text('Added to Watchlist'), findsOneWidget,
          reason: 'Snackbar "Added to Watchlist" should appear');
      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugPrint("Verified movie was added.");

      await tester.pageBack();
      await tester.pumpAndSettle();
      debugPrint("Navigated back to Home page.");

      final drawerIcon = find.byIcon(Icons.menu);
      expect(drawerIcon, findsOneWidget);
      await tester.tap(drawerIcon);
      await tester.pumpAndSettle();

      final watchlistMenuItem = find.text('Watchlist');
      expect(watchlistMenuItem, findsOneWidget);
      await tester.tap(watchlistMenuItem);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      debugPrint("Navigated to Watchlist page.");

      final movieInWatchlist = find.byType(Card).first;
      expect(movieInWatchlist, findsOneWidget,
          reason: 'Movie card should exist in the watchlist');
      debugPrint("SUCCESS: Verified the movie is in the watchlist.");
      debugPrint("Test finished.");
    });
  });
}
