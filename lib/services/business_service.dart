import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';

class BusinessService {
  final _api = ApiClient.instance;

  Future<Map<String, dynamic>> createBusiness({
    required String name,
    required String email,
    required String phone,
    String? address,
    String? cacNumber,
  }) async {
    final response = await _api.post(ApiEndpoints.businesses, data: {
      'name': name,
      'email': email,
      'phone': phone,
      if (address != null) 'address': address,
      if (cacNumber != null) 'cac_number': cacNumber,
    });
    return response['business'] ?? response['data'] ?? response;
  }

  Future<List<Map<String, dynamic>>> listBusinesses() async {
    final response = await _api.get(ApiEndpoints.businesses);
    final list = response['businesses'] ?? response['data'] ?? [];
    return (list as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> updateBusiness(
      String businessId, Map<String, dynamic> updates) async {
    final response = await _api.patch(
        ApiEndpoints.businessById(businessId), data: updates);
    return response['business'] ?? response['data'] ?? response;
  }

  Future<Map<String, dynamic>> getManagerDashboard() async {
    final response = await _api.get(ApiEndpoints.dashboardManager);
    return response['dashboard'] ?? response['data'] ?? response;
  }

  Future<List<Map<String, dynamic>>> getManagerRiders() async {
    final response = await _api.get(ApiEndpoints.dashboardManagerRiders);
    final list = response['riders'] ?? response['data'] ?? [];
    return (list as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getManagerPackages({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final response = await _api.get(
      ApiEndpoints.dashboardManagerPackages,
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      },
    );
    final list = response['packages'] ?? response['data'] ?? [];
    return (list as List).cast<Map<String, dynamic>>();
  }
}
