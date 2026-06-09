import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  static const _seed = Colors.deepOrange;
  static const _orange = Color(0xFFE64A19);
  static const _orangeDark = Color(0xFFBF360C);

  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF0F0F0),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: _orangeDark,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((_) => Colors.transparent),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14, horizontal: 24)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        elevation: WidgetStateProperty.all(0),
        backgroundBuilder: (_, __, child) => Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFFF6D00), Color(0xFFBF360C)]),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: child,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _orange,
        side: const BorderSide(color: _orange, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _orange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _orange,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: StadiumBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _orange, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white60,
      indicatorColor: Colors.white,
    ),
    dividerTheme: DividerThemeData(color: Colors.grey.shade200),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFF1E1212),
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      color: const Color(0xFF1E1E1E),
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((_) => Colors.transparent),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14, horizontal: 24)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        elevation: WidgetStateProperty.all(0),
        backgroundBuilder: (_, __, child) => Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFFF6D00), Color(0xFFBF360C)]),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: child,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.deepOrange.shade300,
        side: BorderSide(color: Colors.deepOrange.shade300, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.deepOrange.shade300,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _orange,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: StadiumBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade700)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _orange, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white60,
      indicatorColor: Colors.deepOrange,
    ),
    dividerTheme: DividerThemeData(color: Colors.grey.shade800),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
