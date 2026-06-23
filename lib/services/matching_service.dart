import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/delivery_models.dart';

class MatchingService {
  final _api = ApiClient.instance;

  Future<List<Map<String, dynamic>>> findCouriers({
    required String pickupAddress,
    required String deliveryAddress,
    double? weight,
  }) async {
    final response = await _api.post(ApiEndpoints.findCouriers, data: {
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      if (weight != null) 'weight': weight,
    });
    final list = response['matches'] ?? response['data'] ?? [];
    return (list as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> requestDelivery({
    required String pickupAddress,
    required String deliveryAddress,
    double? weight,
    String? vehicleType,
  }) async {
    final response =
        await _api.post(ApiEndpoints.requestDelivery, data: {
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      if (weight != null) 'weight': weight,
      if (vehicleType != null) 'vehicle_type': vehicleType,
    });
    return response;
  }

  Future<void> acceptOffer({
    required String courierId,
    required String requestId,
  }) async {
    await _api.post(ApiEndpoints.acceptOffer(courierId, requestId));
  }

  Future<void> rejectOffer({
    required String courierId,
    required String requestId,
  }) async {
    await _api.post(ApiEndpoints.rejectOffer(courierId, requestId));
  }

  Future<QuoteModel> getQuote({
    required String pickupAddress,
    required String deliveryAddress,
    String packageSize = 'SMALL',
    String deliverySpeed = 'STANDARD',
    double? weight,
  }) async {
    final response = await _api.post(ApiEndpoints.quotes, data: {
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'package_size': packageSize,
      'delivery_speed': deliverySpeed,
      if (weight != null) 'weight': weight,
    });
    final data = response['quote'] ?? response['data'] ?? response;
    return QuoteModel.fromJson(data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> scheduleDelivery({
    required String pickupAddress,
    required String deliveryAddress,
    required String scheduleType,
    DateTime? scheduledAt,
    double? weight,
    String? packageType,
    Map<String, dynamic>? recipientDetails,
  }) async {
    final response =
        await _api.post(ApiEndpoints.scheduleDelivery, data: {
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'schedule_type': scheduleType,
      if (scheduledAt != null)
        'scheduled_at': scheduledAt.toIso8601String(),
      if (weight != null) 'weight': weight,
      if (packageType != null) 'package_type': packageType,
      if (recipientDetails != null) ...recipientDetails,
    });
    return response;
  }
}
