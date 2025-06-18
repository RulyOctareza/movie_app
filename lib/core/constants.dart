import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Urls {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey = '2174d146bb9c0eab47529b2e77d6b526';
  static const String baseImageUrl = 'https://image.tmdb.org/t/p/w500';
}

class DBConstants {
  static const String databaseName = 'ditonton.db';
  static const int databaseVersion = 2;

  static const String watchlistMoviesTable = 'watchlist_movies';
  static const String watchlistTvSeriesTable = 'watchlist_tv_series';
  static const String watchlistTable =
      'watchlist'; // Keep for backward compatibility during migration

  static const tableMovieWatchlistCreateQuery = '''
    CREATE TABLE $watchlistMoviesTable (
      id INTEGER PRIMARY KEY,
      title TEXT,
      overview TEXT,
      poster_path TEXT,
      vote_average REAL
    );
  ''';

  static const tableTvSeriesWatchlistCreateQuery = '''
    CREATE TABLE $watchlistTvSeriesTable (
      id INTEGER PRIMARY KEY,
      name TEXT,
      overview TEXT,
      poster_path TEXT,
      vote_average REAL,
      number_of_seasons INTEGER,
      number_of_episodes INTEGER,
      seasons TEXT
    );
  ''';
}

const kColorScheme = ColorScheme(
  primary: Color(0xFF032541),
  secondary: Color(0xFF01B4E4),
  surface: Color(0xFF181818),
  error: Color(0xFFB00020),
  onPrimary: Color(0xFFFFFFFF),
  onSecondary: Color(0xFF000000),
  onSurface: Color(0xFFFFFFFF),
  onError: Color(0xFFFFFFFF),
  brightness: Brightness.dark,
);

const Color kRichBlack = Color(0xFF000814);
final TextTheme kTextTheme = TextTheme(
  headlineSmall: GoogleFonts.poppins(
    fontSize: 23,
    fontWeight: FontWeight.w400,
  ),
  titleLarge: GoogleFonts.poppins(
    fontSize: 19,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  ),
  titleMedium: GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
  ),
  titleSmall: GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ),
  bodyLarge: GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  ),
  bodyMedium: GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  ),
  bodySmall: GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  ),
);

final TextStyle kHeading5 = GoogleFonts.poppins(
  fontSize: 23,
  fontWeight: FontWeight.w400,
);
final TextStyle kHeading6 = GoogleFonts.poppins(
  fontSize: 19,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.15,
);
final TextStyle kBodyText = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.25,
);
