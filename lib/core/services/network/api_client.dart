import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/api_constants.dart';
import '../../utils/app_logger.dart';
import 'dio_logger_interceptor.dart'; // Import the new logger file

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;
  bool _isInitialized = false;

  factory ApiClient() => _instance;

  ApiClient._internal();

  void initialize() {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        headers: {ApiConstants.contentType: ApiConstants.applicationJson},
      ),
    );

    // 1. Add Authentication Interceptor (Logic Only)
    _dio.interceptors.add(_authInterceptor());

    // 2. Add Logger Interceptor (Visuals Only)
    // Added SECOND so it sees the token injected by the auth interceptor
    _dio.interceptors.add(DioLoggerInterceptor());

    _isInitialized = true;
    AppLogger.startup('🚀 ApiClient Initialized & Ready');
  }

  /// Separated Auth Logic for cleaner code
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(ApiConstants.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers[ApiConstants.authHeader] =
                '${ApiConstants.bearerPrefix}$token';
          }
        } catch (e) {
          AppLogger.error('Failed to get token: $e');
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // 🔥 AUTO-FIX: If 401 Unauthorized, clear the bad token
        if (e.response?.statusCode == 401) {
          AppLogger.error(
            '⚠️ 401 Unauthorized: Token expired. Clearing session.',
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(ApiConstants.tokenKey);
          await prefs.remove(ApiConstants.userKey);
        }
        return handler.next(e);
      },
    );
  }

  // --- HTTP Methods ---

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    final response = await _dio.post(path, data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    final response = await _dio.put(path, data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> delete(String path, {dynamic data}) async {
    final response = await _dio.delete(path, data: data);
    return response.data as Map<String, dynamic>;
  }
}
