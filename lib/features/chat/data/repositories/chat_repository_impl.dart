import 'package:gokgok/core/errors/app_exception.dart';
import 'package:gokgok/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:gokgok/features/chat/domain/entities/message_model.dart';
import 'package:gokgok/features/chat/domain/repositories/chat_repository.dart';
import 'package:gokgok/features/groups/domain/entities/group_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remote);

  final ChatRemoteDataSource _remote;

  @override
  String? get currentUserId => _remote.currentUserId;

  @override
  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _remote.watchMessages(conversationId).map((rows) {
      return rows
          .map((r) => MessageModel.fromJson(r))
          .where((m) => !m.isDeleted)
          .toList();
    });
  }

  @override
  Future<String> getOrCreateGroupConversation(GroupModel group) async {
    final userId = currentUserId;
    if (userId == null) throw const AppException('Not authenticated');

    final existing = await _remote.findGroupConversation(group.id);
    if (existing != null) return existing['id'] as String;

    final conv = await _remote.insertConversation(
      name: group.name,
      createdBy: userId,
      groupId: group.id,
    );
    final conversationId = conv['id'] as String;

    final memberRows = await _remote.fetchGroupMembers(group.id);
    await _remote.insertConversationMembers(
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

  // send messages
  @override
  Future<void> sendMessage(String conversationId, String text) async {
    final userId = currentUserId;
    if (userId == null) throw const AppException('Not authenticated');

    await _remote.insertMessage(
      conversationId: conversationId,
      senderId: userId,
      body: text.trim(),
    );
    await _remote.touchConversation(conversationId);
  }
}
