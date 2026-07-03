import 'package:supabase_flutter/supabase_flutter.dart';

/// Raw Supabase calls for the chat feature. No business logic — only queries.
class ChatRemoteDataSource {
  ChatRemoteDataSource(this._client);

  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  Stream<List<Map<String, dynamic>>> watchMessages(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
  }

  /// Conversations for [groupIds] with their newest non-deleted message.
  Future<List<Map<String, dynamic>>> fetchConversationPreviews(
    List<String> groupIds,
  ) {
    return _client
        .from('conversations')
        .select('group_id, last_message_at, '
            'messages(body, type, sender_id, created_at)')
        .inFilter('group_id', groupIds)
        .isFilter('messages.deleted_at', null)
        .order('created_at', referencedTable: 'messages', ascending: false)
        .limit(1, referencedTable: 'messages');
  }

  /// Emits whenever any of these groups' conversation rows change
  /// (last_message_at is bumped on every send).
  Stream<List<Map<String, dynamic>>> watchConversations(
    List<String> groupIds,
  ) {
    return _client
        .from('conversations')
        .stream(primaryKey: ['id'])
        .inFilter('group_id', groupIds);
  }

  Future<Map<String, dynamic>?> findGroupConversation(String groupId) {
    return _client
        .from('conversations')
        .select('id')
        .eq('group_id', groupId)
        .maybeSingle();
  }

  Future<Map<String, dynamic>> insertConversation({
    required String name,
    required String createdBy,
    required String groupId,
  }) {
    return _client
        .from('conversations')
        .insert({
          'type': 'group',
          'name': name,
          'created_by': createdBy,
          'group_id': groupId,
        })
        .select()
        .single();
  }

  Future<List<Map<String, dynamic>>> fetchGroupMembers(String groupId) {
    return _client
        .from('group_members')
        .select('user_id')
        .eq('group_id', groupId);
  }

  Future<void> insertConversationMembers(List<Map<String, dynamic>> rows) {
    return _client.from('conversation_members').insert(rows);
  }

  Future<void> insertMessage({
    required String conversationId,
    required String senderId,
    required String body,
    String? replyToId,
  }) {
    return _client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'type': 'text',
      'body': body,
      if (replyToId != null) 'reply_to_id': replyToId,
    });
  }

  Future<void> updateMessage(String messageId, String body) {
    return _client
        .from('messages')
        .update({
          'body': body,
          'edited_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', messageId);
  }

  Future<void> softDeleteMessage(String messageId) {
    return _client
        .from('messages')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', messageId);
  }

  Future<void> touchConversation(String conversationId) {
    return _client
        .from('conversations')
        .update({'last_message_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', conversationId);
  }
}
