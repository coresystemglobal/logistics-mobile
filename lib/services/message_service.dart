import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/message_model.dart';

class MessageService {
  final _api = ApiClient.instance;

  Future<List<MessageModel>> getMessages(String packageId) async {
    final response =
        await _api.get(ApiEndpoints.packageMessages(packageId));
    final list = response['messages'] ?? response['data'] ?? [];
    return (list as List)
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MessageModel> sendMessage({
    required String packageId,
    required String content,
  }) async {
    final response = await _api.post(
      ApiEndpoints.packageMessages(packageId),
      data: {'content': content},
    );
    final data = response['message'] ?? response['data'] ?? response;
    return MessageModel.fromJson(data as Map<String, dynamic>);
  }

  Future<int> getUnreadCount(String packageId) async {
    final response =
        await _api.get(ApiEndpoints.packageMessagesUnread(packageId));
    return response['count'] ?? response['unread_count'] ?? 0;
  }
}
