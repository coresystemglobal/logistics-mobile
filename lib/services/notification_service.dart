import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _api = ApiClient.instance;

  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get(
      ApiEndpoints.notifications,
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    final list = response['notifications'] ?? response['data'] ?? [];
    return (list as List)
        .map((e) =>
            NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _api.get(ApiEndpoints.notificationsUnreadCount);
    return response['count'] ?? response['unread_count'] ?? 0;
  }

  Future<void> markAsRead(String notificationId) async {
    await _api.put(ApiEndpoints.markNotificationRead(notificationId));
  }

  Future<void> markAllAsRead() async {
    await _api.put(ApiEndpoints.markAllNotificationsRead);
  }
}
