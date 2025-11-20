// File: lib/core/services/auth/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../../models/auth/user_model.dart';
import '../../models/auth/auth_models.dart';
import '../../constants/api_constants.dart';
import '../../utils/app_logger.dart'; // ✅ Added Import

/// Service responsible for local authentication state (Tokens)
/// and delegating specific auth actions.
class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null;

  /// Load tokens from storage on app startup
  Future<void> initialize() async {
    try {
      AppLogger.auth('📂 Initializing AuthService storage...');
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(ApiConstants.tokenKey);
      // If you have a refresh token logic, load it here too

      if (_accessToken != null) {
        AppLogger.auth('✅ Local session found (Token loaded)');
      } else {
        AppLogger.auth('ℹ️ No local session found');
      }
    } catch (e) {
      AppLogger.error('❌ Failed to initialize AuthService', error: e);
    }
  }

  /// Save tokens after login/register
  Future<void> storeTokens(String access, String refresh) async {
    try {
      AppLogger.auth('💾 Storing new authentication tokens...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConstants.tokenKey, access);
      _accessToken = access;
      _refreshToken = refresh;
      AppLogger.auth('✅ Tokens stored successfully');
    } catch (e) {
      AppLogger.error('❌ Failed to store tokens', error: e);
    }
  }

  /// Clear tokens on logout
  Future<void> logout() async {
    try {
      AppLogger.auth('🧹 Clearing local tokens (Logout)...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConstants.tokenKey);
      await prefs.remove(ApiConstants.userKey);
      _accessToken = null;
      _refreshToken = null;
      AppLogger.auth('✅ Local session cleared');
    } catch (e) {
      AppLogger.error('❌ Failed to clear tokens', error: e);
    }
  }

  // --- Role & Permission Checks ---

  bool hasPermission(String permission) {
    // Implement complex permission logic here if needed
    return true;
  }

  bool hasRole(UserRole role) {
    // This is usually checked against the current user model in AuthProvider
    return true;
  }

  bool hasAnyRole(List<UserRole> roles) {
    return true;
  }

  // --- Feature Stubs (Placeholders) ---
  // These methods are called by AuthProvider. In a full implementation,
  // they would call specific API endpoints or Local Authentication.

  Future<AuthResult> verifyOTP(OTPVerificationRequest request) async {
    AppLogger.warning('⚠️ Verify OTP called (Stub)');
    // Logic to call API would go here
    return AuthResult(
      success: false,
      message: "OTP verification feature pending integration",
    );
  }

  Future<AuthResult> requestOTP(String identifier, String type) async {
    AppLogger.auth('📨 Requesting OTP for $identifier (Stub)');
    return AuthResult(success: true, message: "OTP requested (Simulation)");
  }

  Future<AuthResult> resetPassword(PasswordResetRequest request) async {
    AppLogger.warning('⚠️ Reset Password called (Stub)');
    return AuthResult(
      success: false,
      message: "Password reset not available yet",
    );
  }

  Future<AuthResult> changePassword(ChangePasswordRequest request) async {
    AppLogger.warning('⚠️ Change Password called (Stub)');
    return AuthResult(
      success: false,
      message: "Change password not available yet",
    );
  }

  Future<AuthResult> authenticateWithBiometric() async {
    AppLogger.auth('👆 Biometric auth requested (Stub)');
    // Requires 'local_auth' package implementation
    return AuthResult(
      success: false,
      message: "Biometrics not configured on this device",
    );
  }
}

/// Helper class for Auth Service results
class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;

  AuthResult({required this.success, required this.message, this.user});

  bool get isAuthenticated => success;
}
