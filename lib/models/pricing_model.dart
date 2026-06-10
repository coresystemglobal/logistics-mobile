class PriceCalculationModel {
  final double basePrice;
  final double distanceFee;
  final double weightFee;
  final double platformFee;
  final double totalPrice;
  final String currency;
  final double? estimatedDistanceKm;
  final int? estimatedDurationMins;

  const PriceCalculationModel({
    required this.basePrice,
    required this.distanceFee,
    required this.weightFee,
    required this.platformFee,
    required this.totalPrice,
    required this.currency,
    this.estimatedDistanceKm,
    this.estimatedDurationMins,
  });

  factory PriceCalculationModel.fromJson(Map<String, dynamic> json) {
    final data = json['pricing'] ?? json['price'] ?? json['data'] ?? json;
    return PriceCalculationModel(
      basePrice:
          (data['base_price'] ?? data['basePrice'] as num?)?.toDouble() ?? 0.0,
      distanceFee:
          (data['distance_fee'] ?? data['distanceFee'] as num?)?.toDouble() ??
              0.0,
      weightFee:
          (data['weight_fee'] ?? data['weightFee'] as num?)?.toDouble() ?? 0.0,
      platformFee:
          (data['platform_fee'] ?? data['platformFee'] as num?)?.toDouble() ??
              0.0,
      totalPrice:
          (data['total_price'] ?? data['totalPrice'] ?? data['total'] as num?)
                  ?.toDouble() ??
              0.0,
      currency: data['currency']?.toString() ?? 'NGN',
      estimatedDistanceKm:
          (data['estimated_distance_km'] ?? data['distanceKm'] as num?)
              ?.toDouble(),
      estimatedDurationMins:
          (data['estimated_duration_mins'] ?? data['durationMins'] as num?)
              ?.toInt(),
    );
  }
}
