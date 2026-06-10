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
  final double estimatedCost;
  final double? distanceKm;
  final String? vehicleType;
  final String? estimatedDuration;
  final double? platformFee;

  const QuoteModel({
    this.id,
    required this.estimatedCost,
    this.distanceKm,
    this.vehicleType,
    this.estimatedDuration,
    this.platformFee,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) => QuoteModel(
        id: json['id']?.toString(),
        estimatedCost: (json['estimated_cost'] ?? json['estimatedCost'] ?? json['cost'] as num?)
                ?.toDouble() ??
            0.0,
        distanceKm: (json['distance_km'] ?? json['distanceKm'] as num?)?.toDouble(),
        vehicleType: json['vehicle_type'] ?? json['vehicleType'],
        estimatedDuration: json['estimated_duration'] ?? json['estimatedDuration'],
        platformFee: (json['platform_fee'] ?? json['platformFee'] as num?)?.toDouble(),
      );
}
