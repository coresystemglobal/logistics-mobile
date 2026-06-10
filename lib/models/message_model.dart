class MessageModel {
  final String id;
  final String packageId;
  final String senderId;
  final String content;
  final String? senderName;
  final String? senderRole;
  final DateTime? createdAt;

  const MessageModel({
    required this.id,
    required this.packageId,
    required this.senderId,
    required this.content,
    this.senderName,
    this.senderRole,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id']?.toString() ?? '',
        packageId: json['package_id']?.toString() ?? json['packageId']?.toString() ?? '',
        senderId: json['sender_id']?.toString() ?? json['senderId']?.toString() ?? '',
        content: json['content'] ?? '',
        senderName: json['sender_name'] ?? json['senderName'],
        senderRole: json['sender_role'] ?? json['senderRole'],
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );
}
