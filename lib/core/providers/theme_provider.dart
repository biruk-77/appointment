// File: lib/core/providers/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  ColorScheme get colorScheme => themeData.colorScheme;

  // Accessor for custom accent colors used in your UI
  // This fixes the errors in home_screen.dart
  Map<String, Color> get accentColors => {
    'primary': const Color(0xFF009639),
    'secondary': const Color(0xFF2C5F7A),
    'tertiary': const Color(0xFF009639).withOpacity(0.5),
    'medical': const Color(0xFF2196F3), // Blue for medical
    'error': const Color(0xFFD32F2F), // Ethiopian Red
    'success': const Color(0xFF009639), // Ethiopian Green
    'warning': const Color(0xFFFBC02D), // Ethiopian Yellow
    'info': const Color(0xFF039BE5),
    'diaspora': const Color(0xFF9C27B0), // Purple
    'ethiopianGreen': const Color(0xFF009639),
    'ethiopianYellow': const Color(0xFFFBC02D),
    'ethiopianRed': const Color(0xFFD32F2F),
  };

  // Helper to get color for service grid items
  Color getServiceItemColor({bool isSpecial = false}) {
    if (isSpecial) return const Color(0xFF00695C); // Dark Teal
    return const Color(0xFF009639); // Primary Green
  }

  // --- Theme Definitions ---

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF009639),
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF009639),
      secondary: Color(0xFF2C5F7A),
      surface: Colors.white,
      onSurface: Colors.black87,
      error: Color(0xFFD32F2F),
      tertiary: Color(0xFFFBC02D),
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF009639),
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF009639),
      secondary: Color(0xFF81D4FA),
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,
      error: Color(0xFFCF6679),
      tertiary: Color(0xFFFBC02D),
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
