import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.highlight,
    required this.secondaryHighlight,
    required this.navbarBg,
    required this.searchBarBg,
    required this.logoColor,
  });

  final Color highlight;
  final Color secondaryHighlight;
  final Color navbarBg;
  final Color searchBarBg;
  final Color logoColor;

  static const sunset = AppColors(
    highlight: Color(0xffe85d4a),
    secondaryHighlight: Color(0xffe85d4a),
    navbarBg: Color(0xfffff9ef),
    searchBarBg: Color(0x8CFFFFFF),
    logoColor: Color(0xffe85d4a),
  );

  static const mint = AppColors(
    highlight: Color(0xff06d6a0),
    secondaryHighlight: Color(0xff118ab2),
    navbarBg: Color(0xffffffff),
    searchBarBg: Color(0x8CFFFFFF),
    logoColor: Color(0xff06d6a0),
  );

  @override
  AppColors copyWith({
    Color? highlight,
    Color? secondaryHighlight,
    Color? navbarBg,
    Color? searchBarBg,
    Color? logoColor,
  }) {
    return AppColors(
      highlight: highlight ?? this.highlight,
      secondaryHighlight: secondaryHighlight ?? this.secondaryHighlight,
      navbarBg: navbarBg ?? this.navbarBg,
      searchBarBg: searchBarBg ?? this.searchBarBg,
      logoColor: logoColor ?? this.logoColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      highlight: Color.lerp(highlight, other.highlight, t)!,
      secondaryHighlight: Color.lerp(
        secondaryHighlight,
        other.secondaryHighlight,
        t,
      )!,
      navbarBg: Color.lerp(navbarBg, other.navbarBg, t)!,
      searchBarBg: Color.lerp(searchBarBg, other.searchBarBg, t)!,
      logoColor: Color.lerp(logoColor, other.logoColor, t)!,
    );
  }
}
