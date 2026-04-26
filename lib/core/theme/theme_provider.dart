import 'package:flutter/material.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riverpod/legacy.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeData> {
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
    state = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Color(0xfffff9ef),
      textTheme: GoogleFonts.fredokaTextTheme(),
      extensions: const [AppColors.sunset],
    );
  }

  void switchToMintTheme() {
    state = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Color(0xffffffff),
      textTheme: GoogleFonts.playwriteAuQldTextTheme(),
      extensions: const [AppColors.mint],
    );
  }
}
