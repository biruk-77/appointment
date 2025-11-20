import '../network/api_client.dart';
import '../../constants/api_constants.dart';
import '../../utils/app_logger.dart';

class MedicalService {
  final ApiClient _apiClient;

  MedicalService(this._apiClient);

  // ==================== SERVICES ====================

  /// Get all medical services
  Future<Map<String, dynamic>> getAllServices({
    int page = 1,
    int limit = 10,
    String? type, // 'perDate' or 'fixed'
    String? status, // 'active'
  }) async {
    AppLogger.api('Fetching services (Type: $type)');
    final queryParams = {
      'page': page,
      'limit': limit,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
    };

    return await _apiClient.get(
      ApiConstants.services,
      queryParameters: queryParams,
    );
  }

  /// Get a specific service by ID
  Future<Map<String, dynamic>> getServiceById(String id) async {
    AppLogger.api('Fetching service details: $id');
    return await _apiClient.get('${ApiConstants.services}/$id');
  }

  // ==================== PACKAGES ====================

  /// Get all health packages
  Future<Map<String, dynamic>> getAllPackages({
    int page = 1,
    int limit = 10,
  }) async {
    AppLogger.api('Fetching health packages');
    final queryParams = {'page': page, 'limit': limit};

    return await _apiClient.get(
      ApiConstants.packages,
      queryParameters: queryParams,
    );
  }

  /// Get a specific package by ID
  Future<Map<String, dynamic>> getPackageById(String id) async {
    AppLogger.api('Fetching package details: $id');
    return await _apiClient.get('${ApiConstants.packages}/$id');
  }
}
