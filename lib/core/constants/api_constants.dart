// File: lib/core/constants/api_constants.dart

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://appointment.shebabingo.com/api';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // --- Auth ---
  static const String login = '/customers/login';
  static const String register = '/customers/register';
  static const String profile = '/customers/profile';

  // --- Services ---
  static const String services = '/services';
  static const String packages = '/packages';

  // --- Appointments ---
  static const String appointments = '/appointments'; // This was missing!

  // --- Orders ---
  static const String orders = '/orders';
  static const String myOrders = '/orders/my-orders';

  // --- Reservations ---
  static const String reservations = '/reservations';
  static const String myReservations = '/reservations/customer/my-reservations';

  // --- Payments ---
  static const String payments = '/payments';
  static const String verifyPayment = '/payments/verify';

  // --- Storage Keys ---
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';

  static const String authHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
}
