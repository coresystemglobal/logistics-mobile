import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/rating_model.dart';

class RatingService {
  final _api = ApiClient.instance;

  Future<RatingModel> createRating({
    required String packageId,
    required String riderId,
    required int score,
    String? comment,
  }) async {
    final response = await _api.post(ApiEndpoints.ratings, data: {
      'package_id': packageId,
      'rider_id': riderId,
      'score': score,
      if (comment != null) 'comment': comment,
    });
    final data = response['rating'] ?? response['data'] ?? response;
    return RatingModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<RatingModel>> getRiderRatings(String riderId,
      {int page = 1, int limit = 20}) async {
    final response = await _api.get(
      ApiEndpoints.riderRatings(riderId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    final list = response['ratings'] ?? response['data'] ?? [];
    return (list as List)
        .map((e) => RatingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RiderRatingStats> getRiderStats(String riderId) async {
    final response =
        await _api.get(ApiEndpoints.riderRatingStats(riderId));
    final data = response['stats'] ?? response['data'] ?? response;
    return RiderRatingStats.fromJson(data as Map<String, dynamic>);
  }
}
