import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/pricing_model.dart';

class PricingService {
  final _api = ApiClient.instance;

  Future<PriceCalculationModel> calculatePrice({
    required String pickupAddress,
    required String deliveryAddress,
    required String packageSize,
    required String deliverySpeed,
    double? packageWeight,
  }) async {
    final response = await _api.post(ApiEndpoints.calculatePrice, data: {
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'package_size': packageSize,
      'delivery_speed': deliverySpeed,
      if (packageWeight != null) 'package_weight': packageWeight,
    });
    return PriceCalculationModel.fromJson(response);
  }

  Future<double> getFuelPrice() async {
    try {
      final response = await _api.get(ApiEndpoints.fuelPrice);
      return (response['price'] ?? response['fuel_price'] as num?)
              ?.toDouble() ??
          0.0;
    } catch (_) {
      return 0.0;
    }
  }
}
