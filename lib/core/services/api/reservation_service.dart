import '../network/api_client.dart';
import '../../constants/api_constants.dart';
import '../../utils/app_logger.dart';

class ReservationService {
  final ApiClient _apiClient;

  ReservationService(this._apiClient);

  /// Create a new reservation
  Future<Map<String, dynamic>> createReservation({
    required int packageId,
    required int orderId,
    required String startDate,
    required String endDate,
  }) async {
    AppLogger.hospital('Creating reservation for Package #$packageId');
    final response = await _apiClient.post(
      ApiConstants.reservations,
      data: {
        'packageId': packageId,
        'orderId': orderId,
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    AppLogger.success('Reservation created successfully');
    return response;
  }

  /// Get all reservations (Admin/General)
  Future<Map<String, dynamic>> getAllReservations({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    AppLogger.api('Fetching all reservations (Status: $status)');
    final queryParams = {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
    };

    return await _apiClient.get(
      ApiConstants.reservations,
      queryParameters: queryParams,
    );
  }

  /// Get a specific reservation by ID
  Future<Map<String, dynamic>> getReservationById(String id) async {
    AppLogger.api('Fetching reservation details: $id');
    return await _apiClient.get('${ApiConstants.reservations}/$id');
  }

  /// Update a reservation
  Future<Map<String, dynamic>> updateReservation(
    String id, {
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    AppLogger.info('Updating reservation $id');
    final data = <String, dynamic>{};
    if (startDate != null) data['startDate'] = startDate;
    if (endDate != null) data['endDate'] = endDate;
    if (status != null) data['status'] = status;

    final response = await _apiClient.put(
      '${ApiConstants.reservations}/$id',
      data: data,
    );
    AppLogger.success('Reservation updated');
    return response;
  }

  /// Delete a reservation
  Future<Map<String, dynamic>> deleteReservation(String id) async {
    AppLogger.warning('Deleting reservation $id');
    return await _apiClient.delete('${ApiConstants.reservations}/$id');
  }

  /// Get reservations for the logged-in user
  /// Endpoint: /reservations/customer/my-reservations
  Future<Map<String, dynamic>> getMyReservations() async {
    AppLogger.user('Fetching my reservations');
    return await _apiClient.get(ApiConstants.myReservations);
  }
}
