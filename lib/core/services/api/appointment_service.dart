import '../network/api_client.dart';
import '../../constants/api_constants.dart';
import '../../utils/app_logger.dart';

class AppointmentService {
  final ApiClient _apiClient;

  AppointmentService(this._apiClient);

  /// Create a new appointment
  Future<Map<String, dynamic>> createAppointment({
    required int customerId,
    required String dateTime,
    required String hospitalName,
  }) async {
    AppLogger.hospital('Creating appointment at $hospitalName for $dateTime');
    final response = await _apiClient.post(
      ApiConstants.appointments,
      data: {
        'customerId': customerId,
        'dateTime': dateTime,
        'hospitalName': hospitalName,
      },
    );
    AppLogger.success('Appointment created successfully');
    return response;
  }

  /// Get all appointments (Admin/General use)
  Future<Map<String, dynamic>> getAllAppointments({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    AppLogger.api('Fetching all appointments (Page: $page, Status: $status)');
    final queryParams = {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
    };

    return await _apiClient.get(
      ApiConstants.appointments,
      queryParameters: queryParams,
    );
  }

  /// Get a specific appointment by ID
  Future<Map<String, dynamic>> getAppointmentById(String id) async {
    AppLogger.api('Fetching appointment details: $id');
    return await _apiClient.get('${ApiConstants.appointments}/$id');
  }

  /// Update an appointment
  Future<Map<String, dynamic>> updateAppointment(
    String id, {
    String? dateTime,
    String? hospitalName,
    String? status,
  }) async {
    AppLogger.info('Updating appointment $id');
    final data = <String, dynamic>{};
    if (dateTime != null) data['dateTime'] = dateTime;
    if (hospitalName != null) data['hospitalName'] = hospitalName;
    if (status != null) data['status'] = status;

    final response = await _apiClient.put(
      '${ApiConstants.appointments}/$id',
      data: data,
    );
    AppLogger.success('Appointment $id updated');
    return response;
  }

  /// Delete an appointment
  Future<Map<String, dynamic>> deleteAppointment(String id) async {
    AppLogger.warning('Deleting appointment $id');
    return await _apiClient.delete('${ApiConstants.appointments}/$id');
  }

  /// Get appointments for the logged-in user
  Future<Map<String, dynamic>> getMyAppointments() async {
    AppLogger.user('Fetching my appointments');
    // Endpoint: /appointments/my-appointments
    return await _apiClient.get('${ApiConstants.appointments}/my-appointments');
  }
}
