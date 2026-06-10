class PromotionModel {
  final String id;
  final String code;
  final String type; // PERCENTAGE | FIXED
  final double value;
  final double? minOrderAmount;
  final double? maxDiscount;
  final int? usageLimit;
  final int usageCount;
  final bool isActive;
  final DateTime? expiresAt;

  const PromotionModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.minOrderAmount,
    this.maxDiscount,
    this.usageLimit,
    required this.usageCount,
    required this.isActive,
    this.expiresAt,
  });

  bool get isPercentage => type == 'PERCENTAGE';

  factory PromotionModel.fromJson(Map<String, dynamic> json) => PromotionModel(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        type: json['type'] ?? 'FIXED',
        value: (json['value'] as num?)?.toDouble() ?? 0.0,
        minOrderAmount: (json['min_order_amount'] ?? json['minOrderAmount'] as num?)?.toDouble(),
        maxDiscount: (json['max_discount'] ?? json['maxDiscount'] as num?)?.toDouble(),
        usageLimit: (json['usage_limit'] ?? json['usageLimit'] as num?)?.toInt(),
        usageCount: (json['usage_count'] ?? json['usageCount'] as num?)?.toInt() ?? 0,
        isActive: json['is_active'] ?? json['isActive'] ?? true,
        expiresAt: json['expires_at'] != null
            ? DateTime.tryParse(json['expires_at'])
            : null,
      );
}
