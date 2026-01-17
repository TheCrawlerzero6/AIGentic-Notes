import 'package:flutter/material.dart';

class CustomAppTheme {
  CustomAppTheme._();

  static const Color primary = Color.fromARGB(255, 171, 120, 218);
  static const Color secondary = Color.fromARGB(255, 98, 71, 122);
  static const Color background = Color.fromARGB(255, 247, 243, 243);
  static const Color primaryText = Color.fromARGB(255, 48, 45, 51);
  static const Color surface = Color.fromARGB(255, 245, 245, 245);
  static const Color error = Color(0xFFDC2626);

  static const Color primaryDark = Color.fromARGB(255, 98, 71, 122);
  static const Color secondaryDark = Color.fromARGB(255, 171, 120, 218);
  static const Color backgroundDark = Color.fromARGB(255, 0, 2, 7);
  static const Color primaryTextDark = Color(0xFFF3F3F3);
  static const Color surfaceDark = Color(0xFF020617);
  static const Color errorDark = Color(0xFFDC2626);

  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(8));

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: secondaryDark,
      surface: surfaceDark,
      error: errorDark,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: const CircleBorder(),
    ),
    scaffoldBackgroundColor: backgroundDark,

    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,

      centerTitle: false,
      foregroundColor: primaryTextDark,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryTextDark,
      ),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontSize: 14),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: primaryTextDark,
        side: BorderSide(color: secondaryDark.withAlpha(60), width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: primaryTextDark,
        ),
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
      fillColor: surfaceDark,
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: primaryTextDark.withAlpha(120)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: errorDark),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
    ),

    dividerTheme: DividerThemeData(
      color: primaryTextDark.withAlpha(60),
      thickness: 1,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: error,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: const CircleBorder(),
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
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primaryText,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: primaryText),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: primaryText,
        side: BorderSide(color: secondary.withAlpha(60), width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: secondary,
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
        borderSide: BorderSide(color: primaryText.withAlpha(120)),
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

    dividerTheme: DividerThemeData(
      color: primaryText.withAlpha(60),
      thickness: 1,
    ),
  );
}
