import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/package_model.dart';

class PackageService {
  final _api = ApiClient.instance;

  Future<PackageModel> createPackage({
    required String pickupAddress,
    required String deliveryAddress,
    required String packageType,
    double? weight,
    String scheduleType = 'IMMEDIATE',
    DateTime? scheduledAt,
    Map<String, dynamic>? recipientDetails,
  }) async {
    final response = await _api.post(ApiEndpoints.packages, data: {
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'package_type': packageType,
      if (weight != null) 'weight': weight,
      'schedule_type': scheduleType,
      if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
      if (recipientDetails != null) ...recipientDetails,
    });
    final packageData = response['package'] ?? response['data'] ?? response;
    return PackageModel.fromJson(packageData as Map<String, dynamic>);
  }

  Future<PackageModel> trackPackage(String trackingNumber) async {
    final response =
        await _api.get(ApiEndpoints.trackPackage(trackingNumber));
    final packageData = response['package'] ?? response['data'] ?? response;
    return PackageModel.fromJson(packageData as Map<String, dynamic>);
  }

  Future<List<PackageModel>> getMyPackages({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
    };
    try {
      final response = await _api.get(
        ApiEndpoints.packages,
        queryParameters: queryParams,
      );
      final list = response['packages'] ??
          response['data'] ??
          (response is List ? response : []);
      return (list as List)
          .map((e) => PackageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> cancelPackage(String packageId, {String? reason}) async {
    await _api.post(ApiEndpoints.cancelPackage(packageId), data: {
      if (reason != null) 'reason': reason,
    });
  }

  Future<PackageModel> claimPackage(String trackingNumber) async {
    final response =
        await _api.post(ApiEndpoints.claimPackage(trackingNumber));
    final packageData = response['package'] ?? response['data'] ?? response;
    return PackageModel.fromJson(packageData as Map<String, dynamic>);
  }

  Future<PackageModel> getPackageById(String packageId) async {
    final response = await _api.get('${ApiEndpoints.packages}/$packageId');
    final packageData = response['package'] ?? response['data'] ?? response;
    return PackageModel.fromJson(packageData as Map<String, dynamic>);
  }
}
