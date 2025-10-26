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
}
