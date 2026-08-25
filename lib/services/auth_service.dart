import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/api/token_storage.dart';
import '../core/constants/api_endpoints.dart';
import '../models/user_model.dart';

class AuthService {
  final _api = ApiClient.instance;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(ApiEndpoints.login, data: {
      'email': email,
      'password': password,
    });
    final accessToken = response['access_token'] ?? response['token'];
    final refreshToken = response['refresh_token'];
    if (accessToken == null) {
      throw ApiException('No token returned from server');
    }
    await TokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken ?? '',
    );
    return response;
  }

  Future<Map<String, dynamic>> registerCustomer({
    required String firstName,
    required String surname,
    required String email,
    required String phone,
    required String password,
    String? referralCode,
  }) async {
    final response = await _api.post(ApiEndpoints.registerCustomer, data: {
      'first_name': firstName,
      'surname': surname,
      'email': email,
      'phone': phone,
      'password': password,
      'terms_accepted': true,
      if (referralCode != null && referralCode.isNotEmpty)
        'referral_code': referralCode,
    });
    final accessToken = response['access_token'] ?? response['token'];
    final refreshToken = response['refresh_token'];
    if (accessToken != null) {
      await TokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken ?? '',
      );
    }
    return response;
  }

  Future<Map<String, dynamic>> registerRider({
    required String firstName,
    required String surname,
    required String email,
    required String phone,
    required String password,
    required String vehicleType,
    String? referralCode,
    String? licenseNumber,
    String? vehiclePlate,
  }) async {
    final data = {
      'first_name': firstName,
      'surname': surname,
      'email': email,
      'phone': phone,
      'password': password,
      'vehicle_type': vehicleType,
      'terms_accepted': true,
      if (referralCode != null && referralCode.isNotEmpty)
        'referral_code': referralCode,
      if (licenseNumber != null && licenseNumber.isNotEmpty)
        'license_number': licenseNumber,
      if (vehiclePlate != null && vehiclePlate.isNotEmpty)
        'vehicle_plate': vehiclePlate,
    };
    final response = await _api.post(ApiEndpoints.registerRider, data: data);
    final accessToken = response['access_token'] ?? response['token'];
    final refreshToken = response['refresh_token'];
    if (accessToken != null) {
      await TokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken ?? '',
      );
    }
    return response;
  }

  Future<Map<String, dynamic>> registerBusiness({
    required String businessName,
    required String contactPerson,
    required String email,
    required String phone,
    required String password,
    required String address,
  }) async {
    final response = await _api.post(ApiEndpoints.registerBusiness, data: {
      'business_name': businessName,
      'contact_person': contactPerson,
      'email': email,
      'phone': phone,
      'password': password,
      'business_address': address,
      'terms_accepted': true,
    });
    final accessToken = response['access_token'] ?? response['token'];
    final refreshToken = response['refresh_token'];
    if (accessToken != null) {
      await TokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken ?? '',
      );
    }
    return response;
  }

  Future<UserModel> getMe() async {
    final response = await _api.get(ApiEndpoints.getMe);
    final userData = response['user'] ?? response['data'] ?? response;
    return UserModel.fromJson(userData as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiEndpoints.logout);
    } catch (_) {}
    await TokenStorage.clearTokens();
  }

  Future<void> requestPasswordReset(String email) async {
    await _api.post(ApiEndpoints.passwordResetRequest, data: {'email': email});
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _api.post(ApiEndpoints.passwordResetConfirm, data: {
      'email': email,
      'code': code,
      'new_password': newPassword,
    });
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.put(ApiEndpoints.updatePassword, data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  Future<void> updateProfile({
    String? firstName,
    String? surname,
    String? phone,
  }) async {
    final data = <String, dynamic>{};
    if (firstName != null && firstName.isNotEmpty) data['first_name'] = firstName;
    if (surname != null && surname.isNotEmpty) data['surname'] = surname;
    if (phone != null && phone.isNotEmpty) data['phone'] = phone;
    await _api.patch(ApiEndpoints.updateMe, data: data);
  }
}
