import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:expert_flutter_dicoding/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simple End-to-End Test -', () {
    testWidgets('Add movie to watchlist and verify it exists',
        (WidgetTester tester) async {
      // 1. Jalankan Aplikasi
      app.main();

      // Beri waktu 10 detik agar aplikasi benar-benar stabil dan selesai memuat
      // semua data dari internet. Ini adalah kunci utama agar tes tidak gagal.
      debugPrint("App starting... Waiting for initial data to load.");
      await tester.pumpAndSettle(const Duration(seconds: 10));
      debugPrint("App is ready.");

      // 2. Temukan Film Pertama di Daftar "Now Playing"
      // "Now Playing" adalah list paling atas, jadi kita tidak perlu scroll.
      // Kita cukup cari widget Card pertama yang muncul di layar.
      final firstMovieCard = find.byType(Card).first;

      // Pastikan widget tersebut ada di layar.
      expect(firstMovieCard, findsOneWidget,
          reason: 'Should find at least one movie card on screen');
      debugPrint("Found the first movie in the 'Now Playing' list.");

      // 3. Tap Film tersebut untuk masuk ke Halaman Detail
      await tester.tap(firstMovieCard);
      await tester.pumpAndSettle(
          const Duration(seconds: 3)); // Tunggu halaman detail dimuat
      debugPrint("Navigated to Movie Detail page.");

      // 4. Tap Tombol "Add to Watchlist"
      // Tombol ini bisa kita temukan dengan icon-nya.
      final addToWatchlistButton = find.byIcon(Icons.add);
      expect(addToWatchlistButton, findsOneWidget,
          reason: 'Add to Watchlist button should be visible');

      await tester.tap(addToWatchlistButton);
      await tester.pumpAndSettle(
          const Duration(seconds: 2)); // Tunggu proses simpan ke database
      debugPrint("Tapped 'Add to Watchlist'.");

      // Verifikasi bahwa snackbar konfirmasi muncul
      expect(find.text('Added to Watchlist'), findsOneWidget,
          reason: 'Snackbar "Added to Watchlist" should appear');
      await tester
          .pumpAndSettle(const Duration(seconds: 3)); // Tunggu snackbar hilang
      debugPrint("Verified movie was added.");

      // 5. Kembali ke Halaman Utama
      await tester.pageBack();
      await tester.pumpAndSettle();
      debugPrint("Navigated back to Home page.");

      // 6. Buka Drawer dan masuk ke Halaman Watchlist
      final drawerIcon = find.byIcon(Icons.menu);
      expect(drawerIcon, findsOneWidget);
      await tester.tap(drawerIcon);
      await tester.pumpAndSettle();

      final watchlistMenuItem = find.text('Watchlist');
      expect(watchlistMenuItem, findsOneWidget);
      await tester.tap(watchlistMenuItem);
      await tester.pumpAndSettle(
          const Duration(seconds: 2)); // Tunggu halaman watchlist dimuat
      debugPrint("Navigated to Watchlist page.");

      // 7. Verifikasi bahwa film yang ditambahkan ada di Halaman Watchlist
      // Halaman watchlist memiliki tab "Movies" dan "TV Series", defaultnya adalah "Movies".
      // Jadi kita hanya perlu memastikan ada Card film di sana.
      final movieInWatchlist = find.byType(Card).first;
      expect(movieInWatchlist, findsOneWidget,
          reason: 'Movie card should exist in the watchlist');
      debugPrint("SUCCESS: Verified the movie is in the watchlist.");
      debugPrint("Test finished.");
    });
  });
}
