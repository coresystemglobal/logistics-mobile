class RatingModel {
  final String id;
  final String packageId;
  final String riderId;
  final String raterId;
  final int score; // 1–5
  final String? comment;
  final DateTime? createdAt;

  const RatingModel({
    required this.id,
    required this.packageId,
    required this.riderId,
    required this.raterId,
    required this.score,
    this.comment,
    this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) => RatingModel(
        id: json['id']?.toString() ?? '',
        packageId: json['package_id']?.toString() ?? json['packageId']?.toString() ?? '',
        riderId: json['rider_id']?.toString() ?? json['riderId']?.toString() ?? '',
        raterId: json['rater_id']?.toString() ?? json['raterId']?.toString() ?? '',
        score: (json['score'] as num?)?.toInt() ?? 0,
        comment: json['comment'],
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );
}

class RiderRatingStats {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> distribution; // score → count

  const RiderRatingStats({
    required this.averageRating,
    required this.totalRatings,
    required this.distribution,
  });

  factory RiderRatingStats.fromJson(Map<String, dynamic> json) {
    final dist = <int, int>{};
    final raw = json['distribution'];
    if (raw is Map) {
      raw.forEach((k, v) {
        final key = int.tryParse(k.toString());
        final val = (v as num?)?.toInt();
        if (key != null && val != null) dist[key] = val;
      });
    }
    return RiderRatingStats(
      averageRating: (json['average_rating'] ?? json['averageRating'] as num?)
              ?.toDouble() ??
          0.0,
      totalRatings:
          (json['total_ratings'] ?? json['totalRatings'] as num?)?.toInt() ?? 0,
      distribution: dist,
    );
  }
}
