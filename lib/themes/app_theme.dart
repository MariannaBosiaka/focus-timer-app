//this file focuses on defining the app's dark and light themes

import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightAppBackground,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: darkAppBackground,
        fontSize: 72,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(color: Colors.black),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightAppBackground,
        backgroundColor: darkAppBackground,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkAppBackground,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Color(0xFFF8FAF9),
        fontSize: 72,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(color: Color(0xFFF8FAF9)),
    ),
      textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkAppBackground,
        backgroundColor: lightAppBackground,
      ),
    ),
  );
}
