import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/referral_model.dart';

class ReferralService {
  final _api = ApiClient.instance;

  Future<ReferralCodeModel> getMyCode() async {
    final response = await _api.get(ApiEndpoints.referralCode);
    final data = response['referral'] ?? response['data'] ?? response;
    return ReferralCodeModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> applyCode(String code) async {
    await _api.post(ApiEndpoints.applyReferral, data: {'code': code});
  }

  Future<ReferralCodeModel> updateCode(String newCode) async {
    final response = await _api.put(
        ApiEndpoints.updateReferralCode, data: {'code': newCode});
    final data = response['referral'] ?? response['data'] ?? response;
    return ReferralCodeModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ReferralStats> getStats() async {
    final response = await _api.get(ApiEndpoints.referralStats);
    final data = response['stats'] ?? response['data'] ?? response;
    return ReferralStats.fromJson(data as Map<String, dynamic>);
  }
}
