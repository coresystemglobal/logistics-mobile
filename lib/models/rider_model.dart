class RiderModel {
  final String id;
  final String userId;
  final String uniqueId;  // TRK-XXXX
  final String vehicleType; // BICYCLE, MOTORCYCLE, VAN
  final String status;     // AVAILABLE, BUSY, OFFLINE
  final bool isAvailable;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final int? totalDeliveries;
  final String? licenseNumber;
  final String? businessId;
  final Map<String, dynamic>? user;
  final DateTime? createdAt;

  const RiderModel({
    required this.id,
    required this.userId,
    required this.uniqueId,
    required this.vehicleType,
    required this.status,
    required this.isAvailable,
    this.latitude,
    this.longitude,
    this.rating,
    this.totalDeliveries,
    this.licenseNumber,
    this.businessId,
    this.user,
    this.createdAt,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) => RiderModel(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
        uniqueId: json['rider_id'] ?? json['unique_id'] ?? json['uniqueId'] ?? '',
        vehicleType: json['vehicle_type'] ?? json['vehicleType'] ?? 'MOTORCYCLE',
        status: json['status'] ?? 'OFFLINE',
        isAvailable: json['is_available'] ?? json['isAvailable'] ?? false,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        rating: (json['rating'] as num?)?.toDouble(),
        totalDeliveries: json['total_deliveries'] ?? json['totalDeliveries'],
        licenseNumber: json['license_number'] ?? json['licenseNumber'],
        businessId: json['business_id']?.toString() ?? json['businessId']?.toString(),
        user: json['user'] as Map<String, dynamic>?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );
}
