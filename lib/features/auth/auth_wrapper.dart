// File: lib/features/auth/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/app_logger.dart';
import '../home/home_screen.dart';
import '../splash/splash_screen.dart';
import 'login_screen.dart';

/// AuthWrapper decides what the user sees when the app opens.
/// Since Home is a Landing Page, we allow access even if unauthenticated.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        // 1. Show Splash while checking for stored token (Auto Login)
        if (authProvider.isLoading) {
          return const SplashScreen();
        }

        // 2. Always show Home Screen (Landing Page)
        // The HomeScreen handles showing "Guest" or "User Name" in the header.
        return const HomeScreen();
      },
    );
  }
}

/// Helper function to force login for restricted actions
/// Usage:
/// if (await requireAuthentication(context)) {
///    // Do restricted action
/// }
Future<bool> requireAuthentication(BuildContext context) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  // If already logged in, allow action
  if (authProvider.isAuthenticated) {
    return true;
  }

  AppLogger.auth('🔒 Action requires authentication. Redirecting to Login.');

  // Navigate to login and wait for result
  // LoginScreen should pop(true) on success, or we check authProvider state
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );

  // Check again after returning from login screen
  return authProvider.isAuthenticated;
}
