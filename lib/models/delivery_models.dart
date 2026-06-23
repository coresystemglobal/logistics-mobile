class DeliveryOffer {
  final String requestId;
  final String packageId;
  final String trackingNumber;
  final String pickupAddress;
  final String deliveryAddress;
  final double? estimatedDistance;
  final double? estimatedEarnings;
  final String? packageType;
  final double? weight;
  final DateTime? expiresAt;

  const DeliveryOffer({
    required this.requestId,
    required this.packageId,
    required this.trackingNumber,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.estimatedDistance,
    this.estimatedEarnings,
    this.packageType,
    this.weight,
    this.expiresAt,
  });

  factory DeliveryOffer.fromJson(Map<String, dynamic> json) => DeliveryOffer(
        requestId: json['request_id']?.toString() ?? json['requestId']?.toString() ?? '',
        packageId: json['package_id']?.toString() ?? json['packageId']?.toString() ?? '',
        trackingNumber: json['tracking_number'] ?? json['trackingNumber'] ?? '',
        pickupAddress: json['pickup_address'] ?? json['pickupAddress'] ?? '',
        deliveryAddress: json['delivery_address'] ?? json['deliveryAddress'] ?? '',
        estimatedDistance: (json['estimated_distance'] ?? json['estimatedDistance'] as num?)
            ?.toDouble(),
        estimatedEarnings: (json['estimated_earnings'] ?? json['estimatedEarnings'] as num?)
            ?.toDouble(),
        packageType: json['package_type'] ?? json['packageType'],
        weight: (json['weight'] as num?)?.toDouble(),
        expiresAt: json['expires_at'] != null
            ? DateTime.tryParse(json['expires_at'])
            : null,
      );
}

class QuoteModel {
  final String? id;
  final String? quoteCode;
  final double estimatedCost;
  final double? distanceKm;
  final String? currency;
  final String? deliveryEta;
  final double? baseFee;
  final double? distanceFee;
  final double? sizeFee;
  final double? speedFee;
  final double? fuelAdjustment;
  final double? platformFee;

  const QuoteModel({
    this.id,
    this.quoteCode,
    required this.estimatedCost,
    this.distanceKm,
    this.currency,
    this.deliveryEta,
    this.baseFee,
    this.distanceFee,
    this.sizeFee,
    this.speedFee,
    this.fuelAdjustment,
    this.platformFee,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    final breakdown = json['breakdown'] as Map<String, dynamic>?;
    return QuoteModel(
      id: json['id']?.toString(),
      quoteCode: json['quote_code'] ?? json['quoteCode'],
      estimatedCost: (json['estimated_price'] ??
                  json['estimated_cost'] ??
                  json['estimatedCost'] ??
                  json['cost'] as num?)
              ?.toDouble() ??
          0.0,
      distanceKm: (json['estimated_distance_km'] ?? json['distance_km'] ?? json['distanceKm'] as num?)?.toDouble(),
      currency: json['currency'],
      deliveryEta: json['delivery_eta'] ?? json['deliveryEta'],
      baseFee: (breakdown?['base_fee'] as num?)?.toDouble(),
      distanceFee: (breakdown?['distance_fee'] as num?)?.toDouble(),
      sizeFee: (breakdown?['size_fee'] as num?)?.toDouble(),
      speedFee: (breakdown?['speed_fee'] as num?)?.toDouble(),
      fuelAdjustment: (breakdown?['fuel_adjustment'] as num?)?.toDouble(),
      platformFee: (breakdown?['platform_fee'] as num?)?.toDouble(),
    );
  }
}
