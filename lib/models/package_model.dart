class PackageModel {
  final String id;
  final String trackingNumber;
  final String status;
  final String? senderId;
  final String? riderId;
  final String? senderName;
  final String pickupAddress;
  final String deliveryAddress;
  final String? packageType;
  final double? weight;
  final double? estimatedCost;
  final String? scheduleType;    // IMMEDIATE, SCHEDULED, SAME_DAY, NEXT_DAY
  final DateTime? scheduledAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? createdAt;
  final Map<String, dynamic>? rider;

  const PackageModel({
    required this.id,
    required this.trackingNumber,
    required this.status,
    this.senderId,
    this.riderId,
    this.senderName,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.packageType,
    this.weight,
    this.estimatedCost,
    this.scheduleType,
    this.scheduledAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.createdAt,
    this.rider,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
        id: json['id']?.toString() ?? '',
        trackingNumber: json['tracking_number'] ?? json['trackingNumber'] ?? '',
        status: json['status'] ?? 'PENDING',
        senderId: json['sender_id']?.toString() ?? json['senderId']?.toString(),
        riderId: json['rider_id']?.toString() ?? json['riderId']?.toString(),
        senderName: json['sender_name'] ?? json['senderName'],
        pickupAddress: json['pickup_address'] ?? json['pickupAddress'] ?? '',
        deliveryAddress: json['delivery_address'] ?? json['deliveryAddress'] ?? '',
        packageType: json['package_type'] ?? json['packageType'],
        weight: (json['weight'] as num?)?.toDouble(),
        estimatedCost: (json['estimated_cost'] ?? json['estimatedCost'] as num?)
            ?.toDouble(),
        scheduleType: json['schedule_type'] ?? json['scheduleType'],
        scheduledAt: json['scheduled_at'] != null
            ? DateTime.tryParse(json['scheduled_at'])
            : null,
        pickedUpAt: json['picked_up_at'] != null
            ? DateTime.tryParse(json['picked_up_at'])
            : null,
        deliveredAt: json['delivered_at'] != null
            ? DateTime.tryParse(json['delivered_at'])
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
        rider: json['rider'] as Map<String, dynamic>?,
      );

  bool get isActive =>
      status == 'PENDING' || status == 'PICKED_UP' || status == 'IN_TRANSIT';

  bool get isDelivered => status == 'DELIVERED';
  bool get isCancelled => status == 'CANCELLED';
}
