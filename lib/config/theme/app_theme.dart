import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0057FF);
  static const Color background = Color(0xFFF4F6FA);
  static const Color card = Colors.white;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: primary,
      background: background,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
  );
}


/// Sky-blue design tokens + ThemeData. Use in main.dart:
///   MaterialApp(theme: SkyTheme.light(), darkTheme: SkyTheme.dark(), ...)
class SkyColors {
  static const sky = Color(0xFF38BDF8);
  static const skyDeep = Color(0xFF0284C7);
  static const skyLight = Color(0xFFE0F2FE);
  static const skyMist = Color(0xFFF0F9FF);
  static const ink = Color(0xFF0C4A6E);
  static const inkMuted = Color(0xFF64748B);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7DD3FC), sky, skyDeep],
  );
}

class SkyTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: SkyColors.sky,
      brightness: b,
      primary: isDark ? SkyColors.sky : SkyColors.skyDeep,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0B1722) : SkyColors.skyMist,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF12283A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      textTheme: Typography.material2021().black.apply(
            bodyColor: isDark ? Colors.white : SkyColors.ink,
            displayColor: isDark ? Colors.white : SkyColors.ink,
          ),
    );
  }
}