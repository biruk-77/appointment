// File: lib/core/providers/language_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app language/localization
/// Allows switching between English and Amharic
class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  static const String _defaultLanguage = 'en';

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  String get languageCode => _currentLocale.languageCode;

  bool get isEnglish => _currentLocale.languageCode == 'en';

  bool get isAmharic => _currentLocale.languageCode == 'am';

  /// Initialize language from SharedPreferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
      _currentLocale = Locale(savedLanguage);
      notifyListeners();
    } catch (e) {
      // Default to English if error occurs
      _currentLocale = const Locale('en');
    }
  }

  /// Change app language
  Future<void> setLanguage(String languageCode) async {
    if (languageCode == _currentLocale.languageCode) return;

    try {
      _currentLocale = Locale(languageCode);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Toggle between English and Amharic
  Future<void> toggleLanguage() async {
    final newLanguage = isEnglish ? 'am' : 'en';
    await setLanguage(newLanguage);
  }
}

