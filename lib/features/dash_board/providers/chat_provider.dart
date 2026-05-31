import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokgok/features/dash_board/models/gorup_model.dart';
import 'package:gokgok/features/dash_board/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesNotifier extends AsyncNotifier<List<MessageModel>> {
  final String conversationId;

  MessagesNotifier(this.conversationId);

  @override
  Future<List<MessageModel>> build() async {
    final supabase = Supabase.instance.client;
    final completer = Completer<List<MessageModel>>();
    bool isFirst = true;

    final sub = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .listen(
          (rows) {
            final messages = rows
                .map((r) => MessageModel.fromJson(r))
                .where((m) => !m.isDeleted)
                .toList();

            if (isFirst) {
              isFirst = false;
              completer.complete(messages);
            } else {
              state = AsyncData(messages);
            }
          },
          onError: (Object e, StackTrace st) {
            if (isFirst) {
              isFirst = false;
              completer.completeError(e, st);
            } else {
              state = AsyncError(e, st);
            }
          },
        );

    ref.onDispose(sub.cancel);
    return completer.future;
  }
}

final messagesProvider = AsyncNotifierProvider.autoDispose
    .family<MessagesNotifier, List<MessageModel>, String>(
      (arg) => MessagesNotifier(arg),
    );

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

class ChatService {
  final _supabase = Supabase.instance.client;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Future<String> getOrCreateGroupConversation(GorupModel group) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final existing = await _supabase
        .from('conversations')
        .select('id')
        .eq('group_id', group.id)
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    final conv = await _supabase
        .from('conversations')
        .insert({
          'type': 'group',
          'name': group.name,
          'created_by': userId,
          'group_id': group.id,
        })
        .select()
        .single();

    final conversationId = conv['id'] as String;

    final memberRows = await _supabase
        .from('group_members')
        .select('user_id')
        .eq('group_id', group.id);

    await _supabase.from('conversation_members').insert(
      memberRows
          .map(
            (m) => {
              'conversation_id': conversationId,
              'user_id': m['user_id'],
              'role': m['user_id'] == group.createdBy ? 'owner' : 'member',
            },
          )
          .toList(),
    );

    return conversationId;
  }

  Future<void> sendMessage(String conversationId, String text) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': userId,
      'type': 'text',
      'body': text.trim(),
    });

    await _supabase
        .from('conversations')
        .update({'last_message_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', conversationId);
  }
}
