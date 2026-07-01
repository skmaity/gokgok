class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String type;
  final String? body;
  final Map<String, dynamic> metadata;
  final String? replyToId;
  final DateTime createdAt;
  final DateTime? editedAt;
  final DateTime? deletedAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    this.body,
    required this.metadata,
    this.replyToId,
    required this.createdAt,
    this.editedAt,
    this.deletedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json['id'] as String,
    conversationId: json['conversation_id'] as String,
    senderId: json['sender_id'] as String,
    type: json['type'] as String,
    body: json['body'] as String?,
    metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    replyToId: json['reply_to_id'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    editedAt: json['edited_at'] != null
        ? DateTime.parse(json['edited_at'] as String)
        : null,
    deletedAt: json['deleted_at'] != null
        ? DateTime.parse(json['deleted_at'] as String)
        : null,
  );

  bool get isDeleted => deletedAt != null;
  bool get isEdited => editedAt != null;
  bool get hasReply => replyToId != null;
}
