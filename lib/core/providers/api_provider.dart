// File: lib/core/providers/api_provider.dart

import 'package:flutter/material.dart';
import '../services/network/api_client.dart';
import '../utils/app_logger.dart';
import '../services/api/customer_service.dart';
import '../services/api/medical_service.dart';
import '../services/api/order_service.dart';
import '../services/api/appointment_service.dart';
import '../services/api/payment_service.dart';
import '../services/api/reservation_service.dart';

class ApiProvider extends ChangeNotifier {
  static final ApiProvider instance = ApiProvider._internal();

  final ApiClient _apiClient = ApiClient();

  // Services
  late final CustomerService customers;
  late final MedicalService medical;
  late final OrderService orders;
  late final AppointmentService appointments;
  late final PaymentService payments;
  late final ReservationService reservations;

  bool _isInitialized = false;
  // Fixed: Added getter for UI to check status
  bool get isInitialized => _isInitialized;

  String? _lastError;
  String? get lastError => _lastError;

  factory ApiProvider() => instance;

  ApiProvider._internal() {
    // Initialize services synchronously with the client instance
    customers = CustomerService(_apiClient);
    medical = MedicalService(_apiClient);
    orders = OrderService(_apiClient);
    appointments = AppointmentService(_apiClient);
    payments = PaymentService(_apiClient);
    reservations = ReservationService(_apiClient);
  }

  Future<bool> initialize() async {
    try {
      AppLogger.api('🚀 Initializing API Provider');
      _apiClient.initialize();
      _isInitialized = true;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      AppLogger.error('❌ Failed to initialize API', error: e);
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    return await customers.login(email, password);
  }

  Future<Map<String, dynamic>?> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? address,
  }) async {
    return await customers.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      address: address,
    );
  }
}
