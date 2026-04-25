import 'package:flutter/material.dart';
import 'package:gokgok/core/theme/app_theme.dart';
import 'package:riverpod/legacy.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(ThemeData());

  void switchToSunsetTheme() {
    state = ThemeData(
      scaffoldBackgroundColor: AppTheme.sunSetBgColor,
      textTheme: AppTheme.sunSetTextTheme,
    );
  }

  void switchToMintTheme() {
    state = ThemeData(
      scaffoldBackgroundColor: AppTheme.mintBgColor,
      textTheme: AppTheme.mintTextTheme,
    );
  }
}
