// File: lib\theme\app_colors.dart

import 'package:flutter/material.dart';

/// Centralized and simplified color tokens for the application.
class AppColors {
  // Private constructor to prevent instantiation.
  AppColors._();

  // --- Primary Brand Colors ---
  static const Color primary = Color(0xFF009639);
  static const Color secondary = Color(0xFF2C5F7A);

  // --- Ethiopian Flag Colors ---
  static const Color ethiopianGreen = Color(0xFF009639);
  static const Color ethiopianYellow = Color(0xFFFBC02D);
  static const Color ethiopianRed = Color(0xFFD32F2F);

  // --- Neutral Colors ---
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // --- Background Colors ---
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // --- System Status Colors (Changed all orange â†’ green) ---
  static const Color success = Color(0xFF009639);
  static const Color error = Color(0xFF009639);
  static const Color warning = Color(0xFF009639);
  static const Color info = Color(0xFF009639);
}







