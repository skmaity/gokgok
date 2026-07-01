import 'package:gokgok/features/chat/domain/entities/message_model.dart';
import 'package:gokgok/features/groups/domain/entities/group_model.dart';

/// Chat/conversation operations exposed to the presentation layer.
abstract interface class ChatRepository {
  /// The current user's id, or `null` when signed out.
  String? get currentUserId;

  /// Realtime stream of non-deleted messages for a conversation, oldest first.
  Stream<List<MessageModel>> watchMessages(String conversationId);

  /// Returns the conversation id for [group], creating it (and seeding its
  /// members) on first use.
  Future<String> getOrCreateGroupConversation(GroupModel group);

  /// Sends a text message and bumps the conversation's last-message timestamp.
  Future<void> sendMessage(String conversationId, String text);
}
