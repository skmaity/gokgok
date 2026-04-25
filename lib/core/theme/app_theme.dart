import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Mint theme
  static Color mintBgColor = Color(0xfffdfdf9);
  static Color mintHeightLightColor = Color(0xff06d6a0);
  static Color mintSecendaryHeightLightColor = Color(0xff118ab2);
  static TextTheme? mintTextTheme = GoogleFonts.playwriteAuQldTextTheme();

  // SunSet theme
  static Color sunSetBgColor = Color(0xfffbf3e8);
  static Color sunSetHeightLightColor = Color(0xffe85d4a);
  static Color sunSetSecendaryHeightLightColor = Color(0xff7d6bc4);
  static TextTheme? sunSetTextTheme = GoogleFonts.fredokaTextTheme();
}
