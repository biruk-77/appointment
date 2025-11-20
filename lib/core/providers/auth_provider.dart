// File: lib/core/providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/user_model.dart';
import '../models/auth/auth_models.dart';
import '../services/auth/auth_service.dart';
import '../utils/app_logger.dart';
import 'api_provider.dart';

/// Authentication state enumeration
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  verificationRequired,
  error,
}

/// Authentication provider following WINDSURF AI Rules
/// Provider-first state management for authentication with real API integration
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiProvider _apiProvider = ApiProvider.instance;

  // Private state variables
  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;
  bool _requiresVerification = false;
  String? _verificationMethod;

  // Getters
  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated =>
      _state == AuthState.authenticated && _user != null;
  bool get requiresVerification => _requiresVerification;
  String? get verificationMethod => _verificationMethod;

  // Role-based getters
  bool get isAdmin => _user?.hasAdminAccess ?? false;
  bool get canManageFinances => _user?.hasFinanceAccess ?? false;
  bool get canManageAppointments => _user?.canManageAppointments ?? false;
  bool get canProvideServices => _user?.canProvideServices ?? false;
  bool get canProvideSupport => _user?.canProvideSupport ?? false;

  /// Initialize authentication provider with real API
  Future<void> initialize() async {
    AppLogger.auth('🚀 Initializing AuthProvider with real API');
    _setState(AuthState.loading);

    try {
      // Initialize API provider first
      final apiInitialized = await _apiProvider.initialize();
      if (!apiInitialized) {
        throw Exception('Failed to initialize API connection');
      }
      AppLogger.auth('✅ API Provider initialized successfully');

      // Initialize legacy auth service for compatibility
      await _authService.initialize();
      AppLogger.auth('✅ Auth Service initialized successfully');

      // Check for stored user data and tokens
      await _loadStoredUserData();
      AppLogger.auth(
        '🔍 Checking authentication state: user=${_user != null}, authService=${_authService.isAuthenticated}',
      );

      // If we have a token (even if profile load failed), trust it and mark as authenticated
      if (_authService.accessToken != null) {
        // If we don't have user data but have a token, create a minimal user object
        if (_user == null) {
          AppLogger.auth(
            '⚠️ Token exists but no user data - using minimal user object',
          );
          _user = UserModel(
            id: 'unknown',
            email: 'unknown@example.com',
            phone: '',
            firstName: 'User',
            lastName: '',
            role: UserRole.customer,
            status: UserStatus.active,
            verificationStatus: VerificationStatus.verified,
            createdAt: DateTime.now(),
          );
        }
        _setState(AuthState.authenticated);
        AppLogger.auth(
          '✅ User session restored with token: ${_user?.displayName}',
        );
      } else if (_user != null) {
        // User data exists but no token - not authenticated
        _setState(AuthState.unauthenticated);
        AppLogger.auth('ℹ️ User data exists but no token - unauthenticated');
      } else {
        _setState(AuthState.unauthenticated);
        AppLogger.auth(
          'ℹ️ No existing session found - user: ${_user != null}, token: ${_authService.accessToken != null}',
        );
      }
    } catch (e) {
      AppLogger.error('❌ AuthProvider initialization failed', error: e);
      _setError('Initialization failed: ${e.toString()}');
    }
  }

  /// Login with credentials using real API
  Future<bool> loginWithApi({
    required String email,
    required String password,
  }) async {
    AppLogger.auth('🔍 Starting real API login for: $email');
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiProvider.loginUser(
        email: email,
        password: password,
      );

      if (result != null && result['success'] == true) {
        // Extract user data and token from API response
        final userData = result['data']['customer'];
        final token = result['data']['token'];

        AppLogger.auth('🔍 LOGIN RESPONSE: Token received from API');
        AppLogger.auth('📦 Token length: ${token.length} chars');
        AppLogger.auth(
          '📦 Token (first 50 chars): ${token.substring(0, (token.length > 50 ? 50 : token.length))}...',
        );

        // Store tokens using AuthService
        AppLogger.auth('💾 Storing token in AuthService...');
        await _authService.storeTokens(
          token,
          token,
        ); // Using same token for access and refresh
        AppLogger.auth('✅ Token stored successfully');

        // Create UserModel from successful API response
        _user = UserModel(
          id: userData['id']?.toString() ?? 'unknown',
          email: email,
          phone: userData['phone'] ?? '',
          firstName: userData['name'] ?? email.split('@')[0],
          lastName: '',
          role: UserRole.customer,
          status: UserStatus.active,
          verificationStatus: VerificationStatus.verified,
          createdAt: DateTime.now(),
        );

        // Store user data for persistence
        await _storeUserData(_user!);

        _setState(AuthState.authenticated);
        AppLogger.auth('✅ Real API login successful and tokens stored: $email');
        return true;
      } else {
        // Handle failed login
        final errorMessage =
            result?['message'] ?? _apiProvider.lastError ?? 'Login failed';
        _setError(errorMessage);
        AppLogger.auth('❌ Login failed: $errorMessage');
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login with credentials (legacy method)
  Future<bool> login(LoginRequest request) async {
    // Use the new API-based login
    return await loginWithApi(
      email: request.identifier,
      password: request.password,
    );
  }

  /// Register new user using real API
  Future<bool> registerWithApi({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? address,
  }) async {
    AppLogger.auth('📝 Starting real API registration for: $email');
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiProvider.registerUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
        address: address,
      );

      if (result != null && result['success'] == true) {
        // Extract user data and token from API response
        final userData = result['data']['customer'];
        final token = result['data']['token'];

        // Store tokens using AuthService
        await _authService.storeTokens(
          token,
          token,
        ); // Using same token for access and refresh

        // Create user model from successful API response
        _user = UserModel(
          id: userData['id']?.toString() ?? 'unknown',
          email: email,
          phone: phone,
          firstName: name.split(' ').first,
          lastName: name.split(' ').skip(1).join(' '),
          role: UserRole.customer,
          status: UserStatus.active,
          verificationStatus: VerificationStatus.verified,
          createdAt: DateTime.now(),
          address: address,
        );

        // Store user data for persistence
        await _storeUserData(_user!);

        _setState(AuthState.authenticated);
        AppLogger.auth(
          '✅ Real API registration successful and tokens stored: $email',
        );
        return true;
      } else {
        // Handle failed registration
        final errorMessage =
            result?['message'] ??
            _apiProvider.lastError ??
            'Registration failed';
        _setError(errorMessage);
        AppLogger.auth('❌ Registration failed: $errorMessage');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register new user (legacy method)
  Future<bool> register(RegisterRequest request) async {
    return await registerWithApi(
      name: '${request.firstName} ${request.lastName}',
      email: request.email,
      phone: request.phone,
      password: request.password,
      address: request.address,
    );
  }

  /// Verify OTP
  Future<bool> verifyOTP(OTPVerificationRequest request) async {
    AppLogger.auth('AuthProvider: Verifying OTP');
    _setLoading(true);

    try {
      final result = await _authService.verifyOTP(request);

      if (result.isAuthenticated) {
        _user = result.user;
        _requiresVerification = false;
        _verificationMethod = null;
        _setState(AuthState.authenticated);
        AppLogger.auth('OTP verification successful via provider');
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('OTP verification failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Request OTP
  Future<bool> requestOTP(String identifier, String type) async {
    AppLogger.auth('AuthProvider: Requesting OTP');
    _setLoading(true);

    try {
      final result = await _authService.requestOTP(identifier, type);

      if (result.success) {
        AppLogger.auth('OTP request successful');
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('OTP request failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset password
  Future<bool> resetPassword(PasswordResetRequest request) async {
    AppLogger.auth('AuthProvider: Requesting password reset');
    _setLoading(true);

    try {
      final result = await _authService.resetPassword(request);

      if (result.success) {
        AppLogger.auth('Password reset request successful');
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Change password for logged-in user
  Future<bool> changePassword(ChangePasswordRequest request) async {
    AppLogger.auth('AuthProvider: Changing password');
    _setLoading(true);

    try {
      final result = await _authService.changePassword(request);

      if (result.success) {
        AppLogger.auth('Password change successful');
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Password change failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Authenticate with biometric
  Future<bool> authenticateWithBiometric() async {
    AppLogger.auth('AuthProvider: Starting biometric authentication');
    _setLoading(true);

    try {
      final result = await _authService.authenticateWithBiometric();

      if (result.isAuthenticated) {
        _user = result.user;
        _setState(AuthState.authenticated);
        AppLogger.auth('Biometric authentication successful via provider');
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Biometric authentication failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if user has specific permission
  bool hasPermission(String permission) {
    return _authService.hasPermission(permission);
  }

  /// Check if user has specific role
  bool hasRole(UserRole role) {
    return _authService.hasRole(role);
  }

  /// Check if user has any of the specified roles
  bool hasAnyRole(List<UserRole> roles) {
    return _authService.hasAnyRole(roles);
  }

  /// Refresh user profile from API
  Future<bool> refreshProfile() async {
    if (!isAuthenticated) {
      AppLogger.auth('⚠️ Cannot refresh profile: user not authenticated');
      return false;
    }

    try {
      AppLogger.auth('🔄 Refreshing user profile from API');
      final result = await _apiProvider.customers.getCustomerProfile();

      if (result['success'] == true) {
        final profileData = result['data'];

        // Update user model with fresh data from API
        _user = UserModel(
          id: profileData['id']?.toString() ?? _user!.id,
          email: profileData['email'] ?? _user!.email,
          phone: profileData['phone'] ?? _user!.phone,
          firstName: profileData['name'] ?? _user!.firstName,
          lastName: profileData['lastName'] ?? _user!.lastName,
          role: UserRole.fromString(profileData['type'] ?? 'customer'),
          status: UserStatus.active,
          verificationStatus: VerificationStatus.verified,
          createdAt: _user!.createdAt,
          address: profileData['address'] ?? _user!.address,
        );

        // Store updated user data
        await _storeUserData(_user!);

        AppLogger.auth(
          '✅ Profile refreshed successfully: ${_user!.displayName}',
        );
        notifyListeners();
        return true;
      } else {
        AppLogger.error('❌ Failed to refresh profile: ${result['message']}');
        return false;
      }
    } catch (e) {
      AppLogger.error('❌ Error refreshing profile', error: e);
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    AppLogger.auth('AuthProvider: Logging out user');
    _setLoading(true);

    try {
      await _authService.logout();
      _user = null;
      _requiresVerification = false;
      _verificationMethod = null;
      _setState(AuthState.unauthenticated);
      AppLogger.auth('User logged out successfully via provider');
    } catch (e) {
      AppLogger.error('Logout failed', error: e);
      // Force logout locally even if API fails
      _user = null;
      _setState(AuthState.unauthenticated);
    } finally {
      _setLoading(false);
    }
  }

  /// Clear error message
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Clear verification state
  void clearVerificationState() {
    _requiresVerification = false;
    _verificationMethod = null;
    notifyListeners();
  }

  /// Update user profile
  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    AppLogger.user('User profile updated: ${updatedUser.displayName}');
    notifyListeners();
  }

  /// Private helper methods

  void _setState(AuthState newState) {
    if (_state != newState) {
      _state = newState;
      _errorMessage = null; // Clear error when state changes
      AppLogger.auth('Auth state changed to: $newState');
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(AuthState.error);
    AppLogger.error('Auth error: $error');
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get user display data for UI
  Map<String, String> getUserDisplayData() {
    if (_user == null) return {};

    return {
      'name': _user!.displayName,
      'email': _user!.email,
      'phone': _user!.phone,
      'role': _user!.role.value.toUpperCase(),
      'status': _user!.status.value.toUpperCase(),
      'region': _user!.region ?? 'N/A',
    };
  }

  /// Get authentication status for UI
  Map<String, dynamic> getAuthStatus() {
    return {
      'isAuthenticated': isAuthenticated,
      'isLoading': isLoading,
      'hasError': _errorMessage != null,
      'errorMessage': _errorMessage,
      'requiresVerification': _requiresVerification,
      'verificationMethod': _verificationMethod,
      'state': _state.toString(),
    };
  }

  /// Store user data for persistence
  Future<void> _storeUserData(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = {
        'id': user.id,
        'email': user.email,
        'phone': user.phone,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'role': user.role.value,
        'status': user.status.value,
        'verificationStatus': user.verificationStatus.value,
        'createdAt': user.createdAt.toIso8601String(),
        'address': user.address,
      };
      await prefs.setString('user_data', jsonEncode(userData));
      AppLogger.auth('✅ User data stored for persistence');
    } catch (e) {
      AppLogger.error('Failed to store user data', error: e);
    }
  }

  /// Load stored user data from SharedPreferences
  Future<void> _loadStoredUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      AppLogger.auth(
        '🔍 Loading stored user data: ${userDataString != null ? 'Found' : 'Not found'}',
      );

      if (userDataString != null) {
        AppLogger.auth('📦 Raw user data: $userDataString');
        final userData = jsonDecode(userDataString) as Map<String, dynamic>;
        _user = UserModel(
          id: userData['id'] ?? 'unknown',
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? '',
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          role: UserRole.values.firstWhere(
            (role) => role.value == userData['role'],
            orElse: () => UserRole.customer,
          ),
          status: UserStatus.values.firstWhere(
            (status) => status.value == userData['status'],
            orElse: () => UserStatus.active,
          ),
          verificationStatus: VerificationStatus.values.firstWhere(
            (status) => status.value == userData['verificationStatus'],
            orElse: () => VerificationStatus.verified,
          ),
          createdAt:
              DateTime.tryParse(userData['createdAt'] ?? '') ?? DateTime.now(),
          address: userData['address'],
        );
        AppLogger.auth(
          '✅ User data loaded from storage: ${_user?.displayName}',
        );
      } else {
        AppLogger.auth('ℹ️ No stored user data found in SharedPreferences');
      }
    } catch (e) {
      AppLogger.error('❌ Failed to load stored user data', error: e);
    }
  }
}