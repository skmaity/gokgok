import 'package:flutter/material.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_theme.dart';
import 'package:riverpod/legacy.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppTheme.sunSetBgColor,
    textTheme: AppTheme.sunSetTextTheme,
    extensions: const [AppColors.sunset],
  ));

  void switchToSunsetTheme() {
    state = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppTheme.sunSetBgColor,
      textTheme: AppTheme.sunSetTextTheme,
      extensions: const [AppColors.sunset],
    );
  }

  void switchToMintTheme() {
    state = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppTheme.mintBgColor,
      textTheme: AppTheme.mintTextTheme,
      extensions: const [AppColors.mint],
    );
  }
}
