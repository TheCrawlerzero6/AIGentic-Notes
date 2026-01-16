import 'package:flutter/material.dart';

class CustomAppTheme {
  CustomAppTheme._();

  static const Color primary = Color.fromARGB(255, 171, 120, 218);
  static const Color secondary = Color.fromARGB(255, 98, 71, 122);
  static const Color background = Color.fromARGB(255, 247, 243, 243);
  static const Color primaryText = Color.fromARGB(255, 48, 45, 51);
  static const Color surface = Color.fromARGB(255, 180, 192, 132);
  static const Color error = Color(0xFFDC2626);

  static const BorderRadius borderRadius = BorderRadius.all(
    Radius.circular(12),
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: Color(0xFF020617),
      error: error,
    ),

    scaffoldBackgroundColor: const Color(0xFF0F172A),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F172A),
      elevation: 0,
      foregroundColor: Colors.white,
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF020617),
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color.fromARGB(41, 2, 6, 23),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide.none,
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: Color.fromARGB(255, 186, 190, 168),
      error: error,
    ),

    scaffoldBackgroundColor: background,

    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: false,
      foregroundColor: primaryText,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 12),
      bodyMedium: TextStyle(fontSize: 10),
      labelLarge: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        side: const BorderSide(color: primary),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    cardTheme: CardThemeData(
      color: surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E7EB),
      thickness: 1,
    ),
  );
}
