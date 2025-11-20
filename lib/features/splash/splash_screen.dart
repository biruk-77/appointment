// File: lib/features/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          backgroundColor: themeProvider.colorScheme.surface,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeProvider.accentColors['primary']!.withOpacity(
                      0.1,
                    ),
                  ),
                  child: Icon(
                    Icons.health_and_safety,
                    size: 80,
                    color: themeProvider.accentColors['primary'],
                  ),
                ),
                const SizedBox(height: 24),
                // App Title
                Text(
                  'Go Hospital',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: themeProvider.accentColors['primary'],
                  ),
                ),
                const SizedBox(height: 48),
                // Loading Indicator
                CircularProgressIndicator(
                  color: themeProvider.accentColors['secondary'],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
