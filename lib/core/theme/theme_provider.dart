import 'package:flutter/material.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riverpod/legacy.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

enum AppTheme { sunset, mint }

class ThemeNotifier extends StateNotifier<ThemeData> {
  AppTheme currentTheme = AppTheme.sunset;

  ThemeNotifier()
    : super(
        ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Color(0xfffff9ef),
          textTheme: GoogleFonts.fredokaTextTheme(),
          extensions: const [AppColors.sunset],
        ),
      );

  void switchToSunsetTheme() {
    currentTheme = AppTheme.sunset;
    state = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Color(0xfffff9ef),
      textTheme: GoogleFonts.fredokaTextTheme(),
      extensions: const [AppColors.sunset],
    );
  }

  void switchToMintTheme() {
    currentTheme = AppTheme.mint;
    state = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Color(0xffffffff),
      textTheme: GoogleFonts.fredokaTextTheme(),
      extensions: const [AppColors.mint],
    );
  }
}
