import '../network/api_client.dart';
import '../../constants/api_constants.dart';
import '../../utils/app_logger.dart';

class CustomerService {
  final ApiClient _apiClient;

  CustomerService(this._apiClient);

  /// Login a customer
  Future<Map<String, dynamic>> login(String email, String password) async {
    AppLogger.auth('Attempting login for $email');
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    AppLogger.success('User logged in successfully');
    return response;
  }

  /// Register a new customer
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? address,
  }) async {
    AppLogger.auth('Registering new user: $email');
    final response = await _apiClient.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        if (address != null) 'address': address,
      },
    );
    AppLogger.success('User registered successfully');
    return response;
  }

  /// Get the logged-in customer's profile
  Future<Map<String, dynamic>> getCustomerProfile() async {
    AppLogger.user('Fetching profile');
    return await _apiClient.get(ApiConstants.profile);
  }

  /// Update the customer's profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    AppLogger.user('Updating profile');
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;

    final response = await _apiClient.put(ApiConstants.profile, data: data);
    AppLogger.success('Profile updated');
    return response;
  }

  // --- Admin Methods (if needed based on Postman) ---

  /// Get all customers (Admin only)
  Future<Map<String, dynamic>> getAllCustomers({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    AppLogger.api('Admin: Fetching customers list');
    final queryParams = {
      'page': page,
      'limit': limit,
      if (search != null) 'search': search,
    };

    // Note: This endpoint usually requires Admin privileges
    return await _apiClient.get('/customers', queryParameters: queryParams);
  }
}
