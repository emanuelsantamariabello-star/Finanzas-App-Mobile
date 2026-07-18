import 'package:flutter/material.dart';

class AppTheme {
  static const Color corporateGreen = Color(0xFF00C853);
  static const Color corporateBlue = Color(0xFF2979FF);
  static const Color corporateRed = Color(0xFFD32F2F);

  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF0D1117),

    primaryColor: corporateGreen,

    colorScheme: const ColorScheme.dark(
      primary: corporateGreen,
      secondary: corporateBlue,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF161B22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: corporateGreen,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    primaryColor: corporateGreen,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: corporateGreen,
      secondary: corporateBlue,
      error: corporateRed,
      surface: Colors.white,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Color(0xFF0D1117),
      onError: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: corporateGreen, width: 1.4),
      ),
      labelStyle: const TextStyle(color: Color(0xFF475569)),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: corporateGreen,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
