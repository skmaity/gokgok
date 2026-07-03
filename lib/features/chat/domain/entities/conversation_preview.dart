/// Last-message snapshot of a group's conversation, for the chat list.
class ConversationPreview {
  final String groupId;
  final DateTime? lastMessageAt;
  final String? body;
  final String? senderId;
  final String? type;

  ConversationPreview({
    required this.groupId,
    this.lastMessageAt,
    this.body,
    this.senderId,
    this.type,
  });

  factory ConversationPreview.fromJson(Map<String, dynamic> json) {
    final messages = json['messages'] as List?;
    final last = (messages != null && messages.isNotEmpty)
        ? messages.first as Map<String, dynamic>
        : null;
    return ConversationPreview(
      groupId: json['group_id'] as String,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      body: last?['body'] as String?,
      senderId: last?['sender_id'] as String?,
      type: last?['type'] as String?,
    );
  }
}
