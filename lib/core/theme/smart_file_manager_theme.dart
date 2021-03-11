import 'package:flutter/material.dart';

class SmartFileManagerTheme {
  //colors
  static const Color PRIMARY_COLOR = Color(0xFF012C61);
  static const Color SECONDARY_COLOR_01 = Color(0xFFFD1960);
  static const Color SECONDARY_COLOR_02 = Color(0xFF29D3E8);
  static const Color SECONDARY_COLOR_03 = Color(0xFF18C737);
  static const Color SECONDARY_COLOR_04 = Color(0xFFFFCC05);
  static const Color FONT_DARK_COLOR = Color(0xFF282828);
  static const Color FONT_LIGHT_COLOR = Color(0XFF939AA4);

  static ThemeData smartFileManagerThemeData = ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: PRIMARY_COLOR,
    accentColor: SECONDARY_COLOR_01,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Poppins',
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w700,
        color: PRIMARY_COLOR,
      ),
      headline3: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: FONT_DARK_COLOR,
      ),
      headline6: TextStyle(
        fontSize: 9.0,
        fontWeight: FontWeight.w300,
        color: FONT_LIGHT_COLOR,
      ),
    ),
  );
}
