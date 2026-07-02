import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gokgok/core/routing/app_routes.dart';
import 'package:gokgok/core/widgets/top_header_widget.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/groups/domain/entities/group_model.dart';
import 'package:gokgok/features/chat/domain/entities/message_model.dart';
import 'package:gokgok/features/chat/presentation/providers/chat_provider.dart';

class GroupChatPage extends ConsumerStatefulWidget {
  final GroupModel group;
  const GroupChatPage({super.key, required this.group});

  @override
  ConsumerState<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends ConsumerState<GroupChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  String? _conversationId;
  bool _loadingConversation = true;
  String? _conversationError;

  @override
  void initState() {
    super.initState();
    _initConversation();
  }

  Future<void> _initConversation() async {
    try {
      final id = await ref
          .read(chatRepositoryProvider)
          .getOrCreateGroupConversation(widget.group);
      if (mounted) setState(() => _conversationId = id);
    } catch (e) {
      if (mounted) setState(() => _conversationError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingConversation = false);
    }
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _conversationId == null) return;
    _textController.clear();
    await ref.read(chatRepositoryProvider).sendMessage(_conversationId!, text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlight = Theme.of(context).extension<AppColors>()!.highlight;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            TopHeaderWidget(
              onPressed: () => context.pop(),
              title: widget.group.name,
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'members') {
                    context.push(AppRoutes.chatMembers, extra: widget.group);
                  } else {
                    // TODO: abc action
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'members', child: Text('Members')),
                  PopupMenuItem(value: 'abc', child: Text('Abc')),
                ],
              ),
            ),

            Expanded(child: _buildBody(highlight)),
            _InputBar(
              controller: _textController,
              onSend: _send,
              highlight: highlight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(Color highlight) {
    if (_loadingConversation) {
      return Center(child: CircularProgressIndicator(color: highlight));
    }
    if (_conversationError != null) {
      return Center(child: Text(_conversationError!));
    }
    final messagesAsync = ref.watch(messagesProvider(_conversationId!));
    return messagesAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: highlight)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (messages) {
        if (messages.isEmpty) return _EmptyChat(groupName: widget.group.name);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.m,
            vertical: AppSizes.s,
          ),
          itemCount: messages.length,
          itemBuilder: (context, i) {
            final msg = messages[i];
            final currentUserId =
                ref.read(chatRepositoryProvider).currentUserId ?? '';
            final isMe = msg.senderId == currentUserId;
            return _MessageBubble(
              message: msg,
              isMe: isMe,
              highlight: highlight,
            );
          },
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final Color highlight;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final time =
        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 3.h,
          bottom: 3.h,
          left: isMe ? 60.w : 0,
          right: isMe ? 0 : 60.w,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.m,
          vertical: AppSizes.s,
        ),
        decoration: BoxDecoration(
          color: isMe ? highlight : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusMedium),
            topRight: Radius.circular(AppSizes.radiusMedium),
            bottomLeft: Radius.circular(isMe ? AppSizes.radiusMedium : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : AppSizes.radiusMedium),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.body ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                color: isMe ? Colors.white : null,
              ),
            ),
            3.verticalSpace,
            Text(
              time,
              style: TextStyle(
                fontSize: 10.sp,
                color: isMe ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Color highlight;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.m,
        AppSizes.s,
        AppSizes.m,
        AppSizes.m,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).extension<AppColors>()!.searchBarBg,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSizes.m,
                    vertical: AppSizes.sm,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          AppSizes.s.horizontalSpace,
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: highlight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: AppSizes.iconSizeMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final String groupName;
  const _EmptyChat({required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.waving_hand_rounded, size: 48.w, color: Colors.amber),
          AppSizes.s.verticalSpace,
          Text(
            'Say hi to $groupName!',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
