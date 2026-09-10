import 'package:flutter/material.dart';

class AppTheme {
  static const Color lime = Color(0xFFC6FF00);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFB923C);
  static const Color danger = Color(0xFFEF4444);

  static const Color darkBg = Color(0xFF0B0D12);
  static const Color darkCard = Color(0xFF1A1E27);
  static const Color darkText = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  static const Color lightBg = Color(0xFFF7F8FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF14161C);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  static const Color primaryColor = lime;
  static const Color accentColor = cyan;
  static const Color dangerColor = danger;

  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  static Color bg(BuildContext context) => isDark(context) ? darkBg : lightBg;
  static Color card(BuildContext context) => isDark(context) ? darkCard : lightCard;
  static Color textPrimary(BuildContext context) => isDark(context) ? darkText : lightText;
  static Color textSecondary(BuildContext context) => isDark(context) ? darkTextSecondary : lightTextSecondary;
  static Color divider(BuildContext context) => isDark(context) ? Colors.white12 : Colors.black12;
  static Color surfaceTint(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04);

  // Darker variants for chart lines so they stay visible on white backgrounds
  static Color chartLime(BuildContext context) => isDark(context) ? lime : const Color(0xFF7CA300);
  static Color chartCyan(BuildContext context) => isDark(context) ? cyan : const Color(0xFF0E7C93);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    primaryColor: lime,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: darkText),
      titleTextStyle: TextStyle(color: darkText, fontSize: 16, fontWeight: FontWeight.w600),
    ),
    colorScheme: const ColorScheme.dark(
      primary: lime,
      secondary: cyan,
      surface: darkCard,
      error: danger,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: darkText,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lime,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkText,
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: lime, width: 1.5)),
      hintStyle: const TextStyle(color: darkTextSecondary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: lime,
      unselectedItemColor: darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardColor: darkCard,
    dividerColor: Colors.white12,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(color: darkText, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: darkText, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: darkText),
      bodySmall: TextStyle(color: darkTextSecondary),
    ), dialogTheme: DialogThemeData(backgroundColor: darkCard),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    primaryColor: lime,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: lightText),
      titleTextStyle: TextStyle(color: lightText, fontSize: 16, fontWeight: FontWeight.w600),
    ),
    colorScheme: const ColorScheme.light(
      primary: lime,
      secondary: cyan,
      surface: lightCard,
      error: danger,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: lightText,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lime,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightText,
        side: const BorderSide(color: Colors.black12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFEFF0F3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: lime, width: 1.5)),
      hintStyle: const TextStyle(color: lightTextSecondary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightCard,
      selectedItemColor: Color(0xFF7CA300),
      unselectedItemColor: lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 4,
    ),
    cardColor: lightCard,
    dividerColor: Colors.black12,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(color: lightText, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: lightText, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: lightText),
      bodySmall: TextStyle(color: lightTextSecondary),
    ), dialogTheme: DialogThemeData(backgroundColor: lightCard),
  );
}