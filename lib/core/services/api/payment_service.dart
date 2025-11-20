import '../network/api_client.dart';
import '../../constants/api_constants.dart';
import '../../utils/app_logger.dart';

class PaymentService {
  final ApiClient _apiClient;

  PaymentService(this._apiClient);

  /// Create a new payment
  Future<Map<String, dynamic>> createPayment({
    required int orderId,
    required double amount,
    required String paymentOption, // e.g., 'telebirr', 'santimpay'
    Map<String, dynamic>? json,
  }) async {
    AppLogger.payment(
      'Initiating payment: $amount via $paymentOption for Order #$orderId',
    );

    final response = await _apiClient.post(
      ApiConstants.payments,
      data: {
        'orderId': orderId,
        'amount': amount,
        'paymentMethod': paymentOption, // Postman expects 'paymentMethod'
        if (json != null) 'json': json,
      },
    );
    AppLogger.success('Payment initiated successfully');
    return response;
  }

  /// Get all payments
  Future<Map<String, dynamic>> getAllPayments({
    int page = 1,
    int limit = 10,
  }) async {
    AppLogger.api('Fetching payment history');
    return await _apiClient.get(
      ApiConstants.payments,
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  /// Get a specific payment by ID
  Future<Map<String, dynamic>> getPaymentById(String id) async {
    AppLogger.api('Fetching payment details: $id');
    return await _apiClient.get('${ApiConstants.payments}/$id');
  }

  /// Verify a payment transaction
  /// Endpoint: /payments/verify/{transactionId}
  Future<Map<String, dynamic>> verifyPayment(String transactionId) async {
    AppLogger.payment('Verifying transaction: $transactionId');
    final response = await _apiClient.get(
      '${ApiConstants.verifyPayment}/$transactionId',
    );
    AppLogger.success('Payment verification complete');
    return response;
  }

  /// Get payment history/report by date range
  Future<Map<String, dynamic>> getPaymentReport({
    required String startDate,
    required String endDate,
    String? status,
  }) async {
    AppLogger.api('Generating payment report: $startDate to $endDate');
    return await _apiClient.post(
      '${ApiConstants.payments}/filter/date-range',
      data: {
        'startDate': startDate,
        'endDate': endDate,
        if (status != null) 'status': status,
      },
    );
  }
}
