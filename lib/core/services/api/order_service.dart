import 'dart:io';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../../constants/api_constants.dart';
import '../../utils/app_logger.dart';

class OrderService {
  final ApiClient _apiClient;

  // Fixed: Use Positional Constructor to match ApiProvider
  OrderService(this._apiClient);

  Future<Map<String, dynamic>> createOrder({
    required int serviceId,
    required int customerId,
    required String description,
    String? date,
    int? dateCount,
    int? packageId,
    File? file,
  }) async {
    AppLogger.user('Creating new order for Service ID: $serviceId');

    final formData = FormData.fromMap({
      'serviceId': serviceId,
      'customerId': customerId,
      'description': description,
      if (date != null) 'date': date,
      if (dateCount != null) 'dateCount': dateCount,
      if (packageId != null) 'packageId': packageId,
    });

    if (file != null) {
      AppLogger.info('Attaching file to order: ${file.path}');
      formData.files.add(
        MapEntry('file', await MultipartFile.fromFile(file.path)),
      );
    }

    // Pass FormData directly. ApiClient needs to handle dynamic data.
    final response = await _apiClient.post(ApiConstants.orders, data: formData);
    AppLogger.success('Order created successfully');
    return response;
  }

  Future<Map<String, dynamic>> getAllOrders({
    int page = 1,
    int limit = 10,
  }) async {
    AppLogger.api('Fetching all orders');
    return await _apiClient.get(
      ApiConstants.orders,
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  // Fixed: Method name matching
  Future<Map<String, dynamic>> getMyOrders() async {
    AppLogger.user('Fetching my orders history');
    return await _apiClient.get(ApiConstants.myOrders);
  }

  Future<Map<String, dynamic>> getOrderById(String id) async {
    AppLogger.api('Fetching order details: $id');
    // Fixed: Use ApiConstants.orders instead of invalid orderById
    return await _apiClient.get('${ApiConstants.orders}/$id');
  }

  Future<Map<String, dynamic>> updateOrder({
    required String orderId,
    String? description,
    int? dateCount,
    String? date,
    File? file,
  }) async {
    AppLogger.api('📝 Updating order: $orderId');

    final formData = FormData.fromMap({
      if (description != null) 'description': description,
      if (dateCount != null) 'dateCount': dateCount,
      if (date != null && date.isNotEmpty) 'date': date,
    });

    if (file != null) {
      AppLogger.info('Attaching file to order update: ${file.path}');
      formData.files.add(
        MapEntry('file', await MultipartFile.fromFile(file.path)),
      );
    }

    final response = await _apiClient.put(
      '${ApiConstants.orders}/$orderId',
      data: formData,
    );
    AppLogger.success('✅ Order updated successfully');
    return response;
  }
}
