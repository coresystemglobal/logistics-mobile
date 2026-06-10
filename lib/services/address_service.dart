import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';

class AddressService {
  final _api = ApiClient.instance;

  Future<List<Map<String, dynamic>>> getSavedAddresses() async {
    final response = await _api.get(ApiEndpoints.addresses);
    final list = response['addresses'] ?? response['data'] ?? [];
    return (list as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getDefaultAddress() async {
    final response =
        await _api.get(ApiEndpoints.defaultAddress);
    return response['address'] ?? response['data'] ?? response;
  }

  Future<Map<String, dynamic>> addAddress({
    required String label,
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    final response = await _api.post(ApiEndpoints.addresses, data: {
      'label': label,
      'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'is_default': isDefault,
    });
    return response['address'] ?? response['data'] ?? response;
  }

  Future<Map<String, dynamic>> updateAddress(
      String id, Map<String, dynamic> updates) async {
    final response =
        await _api.put(ApiEndpoints.updateAddress(id), data: updates);
    return response['address'] ?? response['data'] ?? response;
  }

  Future<void> setDefaultAddress(String id) async {
    await _api.put(ApiEndpoints.setDefaultAddress(id));
  }

  Future<void> deleteAddress(String id) async {
    await _api.delete(ApiEndpoints.deleteAddress(id));
  }
}
