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
  }) {
    return _client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'type': 'text',
      'body': body,
    });
  }

  Future<void> touchConversation(String conversationId) {
    return _client
        .from('conversations')
        .update({'last_message_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', conversationId);
  }
}
