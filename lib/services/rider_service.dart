import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/rider_model.dart';

class RiderService {
  final _api = ApiClient.instance;

  Future<RiderModel> getProfile() async {
    final response = await _api.get(ApiEndpoints.riderProfile);
    final data = response['rider'] ?? response['data'] ?? response;
    return RiderModel.fromJson(data as Map<String, dynamic>);
  }

  Future<RiderModel> updateProfile(Map<String, dynamic> updates) async {
    final response =
        await _api.put(ApiEndpoints.riderProfile, data: updates);
    final data = response['rider'] ?? response['data'] ?? response;
    return RiderModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    await _api.put(ApiEndpoints.riderLocation, data: {
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<void> updateStatus(String status) async {
    await _api.put(ApiEndpoints.riderStatus, data: {'status': status});
  }

  Future<void> updateAvailability(bool isAvailable) async {
    await _api.put(
        ApiEndpoints.riderAvailability, data: {'is_available': isAvailable});
  }

  Future<bool> checkEligibility() async {
    try {
      final response = await _api.get(ApiEndpoints.riderEligibility);
      return response['eligible'] ?? true;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateCourierLocation({
    required String courierId,
    required double latitude,
    required double longitude,
    String? vehicleType,
  }) async {
    await _api.put(ApiEndpoints.courierLocation(courierId), data: {
      'latitude': latitude,
      'longitude': longitude,
      if (vehicleType != null) 'vehicle_type': vehicleType,
    });
  }

  Future<void> updateCourierStatus({
    required String courierId,
    required String status,
  }) async {
    await _api.put(ApiEndpoints.courierStatus(courierId), data: {
      'status': status,
    });
  }

  Future<List<Map<String, dynamic>>> getAvailableJobs() async {
    try {
      final response = await _api.get(ApiEndpoints.riderJobs);
      final jobs = response['jobs'] ?? response['data'] ?? [];
      return (jobs as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
