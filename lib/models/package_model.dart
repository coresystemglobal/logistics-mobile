class PackageModel {
  final String id;
  final String? trackingNumber;
  final String status;
  final String? senderId;
  final String? riderId;
  final String pickupAddress;
  final String deliveryAddress;
  final String? description;
  final String? deliveryNotes;
  final String? packageSize;
  final double? packageWeight;
  final String? deliverySpeed;
  final String? category;
  final bool isFragile;
  final String? recipientName;
  final String? recipientPhone;
  final String? recipientEmail;
  final double? totalAmount;
  final String? cancellationReason;
  final String? cancellationNote;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? createdAt;
  final double? estimatedCost;
  final Map<String, dynamic>? rider;
  final String? pickupPin;

  const PackageModel({
    required this.id,
    this.trackingNumber,
    required this.status,
    this.senderId,
    this.riderId,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.description,
    this.deliveryNotes,
    this.packageSize,
    this.packageWeight,
    this.deliverySpeed,
    this.category,
    this.isFragile = false,
    this.recipientName,
    this.recipientPhone,
    this.recipientEmail,
    this.totalAmount,
    this.cancellationReason,
    this.cancellationNote,
    this.pickedUpAt,
    this.deliveredAt,
    this.createdAt,
    this.estimatedCost,
    this.rider,
    this.pickupPin,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
        id: json['id']?.toString() ?? '',
        trackingNumber: json['tracking_number'] ?? json['trackingNumber'],
        status: json['status'] ?? 'PENDING',
        senderId: json['sender_id']?.toString() ?? json['senderId']?.toString(),
        riderId: json['rider_id']?.toString() ?? json['riderId']?.toString(),
        pickupAddress: json['pickup_address'] ?? json['pickupAddress'] ?? '',
        deliveryAddress: json['delivery_address'] ?? json['deliveryAddress'] ?? '',
        description: json['description'],
        deliveryNotes: json['delivery_notes'] ?? json['deliveryNotes'],
        packageSize: json['package_size'] ?? json['packageSize'],
        packageWeight: num.tryParse(json['package_weight']?.toString() ?? json['packageWeight']?.toString() ?? '')?.toDouble(),
        deliverySpeed: json['delivery_speed'] ?? json['deliverySpeed'],
        category: json['category'],
        isFragile: json['is_fragile'] ?? json['isFragile'] ?? false,
        recipientName: json['recipient_name'] ?? json['recipientName'],
        recipientPhone: json['recipient_phone'] ?? json['recipientPhone'],
        recipientEmail: json['recipient_email'] ?? json['recipientEmail'],
        totalAmount: num.tryParse((json['total_amount'] ?? json['totalAmount'])?.toString() ?? '')?.toDouble(),
        cancellationReason: json['cancellation_reason'] ?? json['cancellationReason'],
        cancellationNote: json['cancellation_note'] ?? json['cancellationNote'],
        pickedUpAt: json['picked_up_at'] != null ? DateTime.tryParse(json['picked_up_at']) : null,
        deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at']) : null,
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
        estimatedCost: num.tryParse((json['estimated_cost'] ?? json['total_amount'] ?? json['totalAmount'])?.toString() ?? '')?.toDouble(),
        rider: json['rider'] as Map<String, dynamic>?,
        pickupPin: json['pickup_pin']?.toString() ?? json['pickupPin']?.toString(),
      );

  bool get isActive =>
      status == 'PENDING' || status == 'IN_TRANSIT' || status == 'OUT_FOR_DELIVERY';
  bool get isDelivered => status == 'DELIVERED';
  bool get isCancelled => status == 'CANCELLED';
}
