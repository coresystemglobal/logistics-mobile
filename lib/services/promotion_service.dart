import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/promotion_model.dart';

class PromotionService {
  final _api = ApiClient.instance;

  Future<List<PromotionModel>> listPromotions() async {
    final response = await _api.get(ApiEndpoints.promotions);
    final list = response['promotions'] ?? response['data'] ?? [];
    return (list as List)
        .map((e) => PromotionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PromotionModel> getPromotion(String id) async {
    final response = await _api.get(ApiEndpoints.promotionById(id));
    final data = response['promotion'] ?? response['data'] ?? response;
    return PromotionModel.fromJson(data as Map<String, dynamic>);
  }

  /// Redeem a promo code at checkout. Returns discount details.
  Future<Map<String, dynamic>> redeemCode({
    required String code,
    required double orderAmount,
  }) async {
    final response = await _api.post(ApiEndpoints.redeemPromotion, data: {
      'code': code,
      'order_amount': orderAmount,
    });
    return response;
  }
}
