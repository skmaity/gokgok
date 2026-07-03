import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokgok/core/network/supabase_providers.dart';
import 'package:gokgok/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:gokgok/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:gokgok/features/chat/domain/entities/conversation_preview.dart';
import 'package:gokgok/features/chat/domain/entities/message_model.dart';
import 'package:gokgok/features/chat/domain/repositories/chat_repository.dart';
import 'package:gokgok/features/groups/presentation/providers/group_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    ChatRemoteDataSource(ref.watch(supabaseClientProvider)),
  );
});

class MessagesNotifier extends AsyncNotifier<List<MessageModel>> {
  MessagesNotifier(this.conversationId);

  final String conversationId;

  @override
  Future<List<MessageModel>> build() async {
    final repository = ref.read(chatRepositoryProvider);
    final completer = Completer<List<MessageModel>>();
    bool isFirst = true;

    final sub = repository.watchMessages(conversationId).listen(
      (messages) {
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

/// Last-message previews for the user's groups, keyed by group id.
final conversationPreviewsProvider = StreamProvider.autoDispose<
    Map<String, ConversationPreview>>((ref) async* {
  final groups = await ref.watch(groupProvider.future);
  if (groups.isEmpty) {
    yield const {};
    return;
  }
  yield* ref
      .read(chatRepositoryProvider)
      .watchConversationPreviews(groups.map((g) => g.id).toList());
});
