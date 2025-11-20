import '../network/api_client.dart';
import '../../utils/app_logger.dart';
import 'customer_service.dart';
import 'appointment_service.dart';
import 'medical_service.dart';
import 'order_service.dart';
import 'payment_service.dart';
import 'reservation_service.dart';

class ApiManager {
  static ApiManager? _instance;
  static ApiManager get instance => _instance ??= ApiManager._internal();

  ApiManager._internal();

  late ApiClient _apiClient;
  late CustomerService _customerService;
  late AppointmentService _appointmentService;
  late MedicalService _medicalService;
  late OrderService _orderService;
  late PaymentService _paymentService;
  late ReservationService _reservationService;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.startup('🚀 Initializing API Manager...');

      // 1. Setup Client
      _apiClient = ApiClient();
      _apiClient.initialize();

      // 2. Setup Services
      _customerService = CustomerService(_apiClient);
      _appointmentService = AppointmentService(_apiClient);
      _medicalService = MedicalService(_apiClient);
      _orderService = OrderService(_apiClient);
      _paymentService = PaymentService(_apiClient);
      _reservationService = ReservationService(_apiClient);

      _isInitialized = true;
      AppLogger.success('✅ API Manager initialized');
      AppLogger.info('🌐 Connected to: https://appointment.shebabingo.com/api');
    } catch (e) {
      AppLogger.error('❌ Failed to initialize API Manager', error: e);
      rethrow;
    }
  }

  // Getters
  CustomerService get customers => _customerService;
  AppointmentService get appointments => _appointmentService;
  MedicalService get medical => _medicalService;
  OrderService get orders => _orderService;
  PaymentService get payments => _paymentService;
  ReservationService get reservations => _reservationService;
  ApiClient get apiClient => _apiClient;
}
