// File: lib/core/constants/environment.dart

class Environment {
  // Private constructor to prevent instantiation
  Environment._();

  // --- App Information ---
  static const String appName = 'Go Hospital';
  static const String version = '1.0.0';

  // --- API Configuration ---

  // 1. Production URL (The real server)
  static const String productionBaseUrl =
      'https://appointment.shebabingo.com/api';

  // 2. Local Development URL (For Android Emulator: 10.0.2.2 = localhost)
  static const String localBaseUrl = 'http://10.0.2.2:5000/api';

  // 👉 CURRENT ACTIVE URL (Change this to switch between Local and Prod)
  static const String baseUrl = productionBaseUrl;

  // --- Feature Flags ---
  static const bool enableLogging = true;
  static const bool enableAnimations = true;

  // --- Timeouts ---
  static const int connectionTimeout = 30000; // 30 seconds
}
