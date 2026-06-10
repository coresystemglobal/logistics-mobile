class ReferralCodeModel {
  final String code;
  final String userId;
  final int usageCount;
  final DateTime? createdAt;

  const ReferralCodeModel({
    required this.code,
    required this.userId,
    required this.usageCount,
    this.createdAt,
  });

  factory ReferralCodeModel.fromJson(Map<String, dynamic> json) =>
      ReferralCodeModel(
        code: json['code']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
        usageCount: (json['usage_count'] ?? json['usageCount'] as num?)?.toInt() ?? 0,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );
}

class ReferralStats {
  final int totalReferrals;
  final int successfulReferrals;
  final double totalBonusEarned;

  const ReferralStats({
    required this.totalReferrals,
    required this.successfulReferrals,
    required this.totalBonusEarned,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) => ReferralStats(
        totalReferrals:
            (json['total_referrals'] ?? json['totalReferrals'] as num?)
                    ?.toInt() ??
                0,
        successfulReferrals: (json['successful_referrals'] ??
                    json['successfulReferrals'] as num?)
                ?.toInt() ??
            0,
        totalBonusEarned: (json['total_bonus_earned'] ??
                    json['totalBonusEarned'] as num?)
                ?.toDouble() ??
            0.0,
      );
}
