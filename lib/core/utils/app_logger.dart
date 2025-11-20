//lib/app_logger.dart
import 'package:flutter/foundation.dart';

class AppLogger {
  // Log Info
  static void info(String message) {
    debugPrint('ℹ️ INFO: $message');
  }

  // Log Success
  static void success(String message) {
    debugPrint('✅ SUCCESS: $message');
  }

  // Log Warning
  static void warning(String message) {
    debugPrint('⚠️ WARNING: $message');
  }

  // Log Error
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint('❌ ERROR: $message');
    if (error != null) {
      debugPrint('   Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('   StackTrace: $stackTrace');
    }
  }

  // Log API Calls
  static void api(String message) {
    debugPrint('🌐 API: $message');
  }

  // Log Authentication
  static void auth(String message) {
    debugPrint('🔐 AUTH: $message');
  }

  // Log Navigation
  static void navigation(String message) {
    debugPrint('🧭 NAV: $message');
  }

  // Log User Actions
  static void user(String message) {
    debugPrint('👤 USER: $message');
  }

  // Log Hospital/Service Actions
  static void hospital(String message) {
    debugPrint('🏥 HOSPITAL: $message');
  }

  // Log Phone/Contact Actions
  static void phone(String message) {
    debugPrint('📞 PHONE: $message');
  }

  // Log Startup
  static void startup(String message) {
    debugPrint('🚀 STARTUP: $message');
  }

  // Log Celebration/Milestone
  static void celebrate(String message) {
    debugPrint('🎉 CELEBRATE: $message');
  }

  static void payment(String message) =>
      debugPrint('💳 PAYMENT: $message');
  static void restart(String message) {
    debugPrint('🔄 RESTART: $message');
  }

  static void log(String message) {
    debugPrint('📝 LOG: $message');
  }
}
