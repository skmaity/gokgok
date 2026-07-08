import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gokgok/core/routing/app_routes.dart';
import 'package:gokgok/core/widgets/app_network_image.dart';
import 'package:gokgok/core/widgets/glass_header_bar.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/groups/domain/entities/group_model.dart';
import 'package:gokgok/features/groups/domain/entities/member_model.dart';
import 'package:gokgok/features/groups/presentation/providers/group_provider.dart';
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
  bool _didInitialScroll = false;
  MessageModel? _replyTo;
  MessageModel? _editing;

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
    try {
      final repository = ref.read(chatRepositoryProvider);
      if (_editing != null) {
        await repository.editMessage(_editing!.id, text);
      } else {
        await repository.sendMessage(
          _conversationId!,
          text,
          replyToId: _replyTo?.id,
        );
        _scrollToBottom(force: true);
      }
      if (mounted) {
        setState(() {
          _replyTo = null;
          _editing = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      // Give the message back so it isn't lost.
      _textController.text = text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _senderName(String senderId) {
    if (senderId == ref.read(chatRepositoryProvider).currentUserId) {
      return 'You';
    }
    return widget.group.members
            .where((m) => m.id == senderId)
            .firstOrNull
            ?.username ??
        'Unknown';
  }

  Future<void> _showMessageActions(MessageModel message, bool isMe) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusMedium),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () => Navigator.pop(sheetContext, 'reply'),
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () => Navigator.pop(sheetContext, 'copy'),
            ),
            if (isMe) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () => Navigator.pop(sheetContext, 'edit'),
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red.shade400),
                title: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red.shade400),
                ),
                onTap: () => Navigator.pop(sheetContext, 'delete'),
              ),
            ],
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case 'copy':
        await Clipboard.setData(ClipboardData(text: message.body ?? ''));
      case 'reply':
        setState(() {
          _replyTo = message;
          _editing = null;
        });
      case 'edit':
        setState(() {
          _editing = message;
          _replyTo = null;
          _textController.text = message.body ?? '';
        });
      case 'delete':
        try {
          await ref.read(chatRepositoryProvider).deleteMessage(message.id);
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
    }
  }

  void _scrollToBottom({bool force = false}) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // Don't yank the user down while they're reading history.
    if (!force && position.maxScrollExtent - position.pixels > 200) return;
    _scrollController.animateTo(
      position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
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
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GlassHeaderBar(
        onBack: () => context.pop(),
        title: widget.group.name,
        trailing: IconButton(
          icon: const Icon(Icons.group_outlined),
          onPressed: () =>
              context.push(AppRoutes.chatMembers, extra: widget.group),
        ),
      ),
      body: Builder(
        // Body context: Scaffold folds the glass header (extendBodyBehindAppBar)
        // and input bar (extendBody) heights into MediaQuery.padding here.
        builder: (bodyContext) => Column(
          children: [
            Expanded(child: _buildBody(bodyContext, highlight)),
            _buildComposeContext(highlight),
          ],
        ),
      ),
      bottomNavigationBar: _InputBar(
        controller: _textController,
        onSend: _send,
        highlight: highlight,
      ),
    );
  }

  /// Strip above the input while replying to or editing a message.
  Widget _buildComposeContext(Color highlight) {
    final target = _editing ?? _replyTo;
    if (target == null) return const SizedBox.shrink();
    final label = _editing != null
        ? 'Editing message'
        : 'Replying to ${_senderName(target.senderId)}';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.m,
        vertical: AppSizes.s,
      ),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Icon(
            _editing != null ? Icons.edit : Icons.reply,
            size: 18,
            color: highlight,
          ),
          AppSizes.s.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: highlight,
                  ),
                ),
                Text(
                  target.body ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() {
              if (_editing != null) _textController.clear();
              _replyTo = null;
              _editing = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, Color highlight) {
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollController.hasClients) return;
          if (!_didInitialScroll) {
            _didInitialScroll = true;
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          } else {
            _scrollToBottom();
          }
        });
        final currentUserId =
            ref.read(chatRepositoryProvider).currentUserId ?? '';
        // Live members for sender names/avatars; route snapshot until loaded.
        final members =
            ref.watch(groupMembersProvider(widget.group.id)).value ??
            widget.group.members;
        final membersById = {for (final m in members) m.id: m};
        final messagesById = {for (final m in messages) m.id: m};
        return ListView.builder(
          controller: _scrollController,
          // Insets clear the glass header and input bar (already in the body
          // MediaQuery padding) so messages scroll under both but end visible.
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + AppSizes.s,
            left: AppSizes.m,
            right: AppSizes.m,
            bottom: MediaQuery.paddingOf(context).bottom + AppSizes.s,
          ),
          itemCount: messages.length,
          itemBuilder: (context, i) {
            final msg = messages[i];
            final prev = i > 0 ? messages[i - 1] : null;
            final isMe = msg.senderId == currentUserId;
            final newDay =
                prev == null ||
                !_sameDay(prev.createdAt.toLocal(), msg.createdAt.toLocal());
            final replied = msg.replyToId != null
                ? messagesById[msg.replyToId]
                : null;
            final bubble = _MessageBubble(
              message: msg,
              isMe: isMe,
              highlight: highlight,
              sender: membersById[msg.senderId],
              showSender: !isMe && (newDay || prev.senderId != msg.senderId),
              replied: replied,
              repliedSender: replied != null
                  ? _senderName(replied.senderId)
                  : null,
              onLongPress: () => _showMessageActions(msg, isMe),
            );
            if (!newDay) return bubble;
            return Column(
              children: [
                _DateSeparator(date: msg.createdAt.toLocal()),
                bubble,
              ],
            );
          },
        );
      },
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final Color highlight;
  final MemberModel? sender;

  /// Show sender name + avatar (first message of a sender's run).
  final bool showSender;

  /// The message this one replies to, if loaded.
  final MessageModel? replied;
  final String? repliedSender;
  final VoidCallback? onLongPress;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.highlight,
    this.sender,
    this.showSender = false,
    this.replied,
    this.repliedSender,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final local = message.createdAt.toLocal();
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

    final bubble = Container(
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
          if (showSender) ...[
            Text(
              sender?.username ?? 'Unknown',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: highlight,
              ),
            ),
            2.verticalSpace,
          ],
          if (message.hasReply) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: (isMe ? Colors.white : highlight).withAlpha(30),
                // No borderRadius: BoxDecoration forbids it with a
                // non-uniform border.
                border: Border(
                  left: BorderSide(
                    color: isMe ? Colors.white : highlight,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    repliedSender ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isMe ? Colors.white : highlight,
                    ),
                  ),
                  Text(
                    replied?.body ?? 'Message unavailable',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isMe ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            4.verticalSpace,
          ],
          Text(
            message.body ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              color: isMe ? Colors.white : null,
            ),
          ),
          3.verticalSpace,
          Text(
            message.isEdited ? '$time · edited' : time,
            style: TextStyle(
              fontSize: 10.sp,
              color: isMe ? Colors.white70 : Colors.grey,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: 3.h,
        bottom: 3.h,
        left: isMe ? 60.w : 0,
        right: isMe ? 0 : 60.w,
      ),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: isMe
            ? Align(alignment: Alignment.centerRight, child: bubble)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSender)
                    Padding(
                      padding: EdgeInsets.only(right: 6.w),
                      child: AppNetworkImage(
                        url: sender?.avatarUrl,
                        size: 30.w,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusCircular,
                        ),
                      ),
                    )
                  else
                    SizedBox(width: 36.w),
                  Flexible(child: bubble),
                ],
              ),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;
    final label = diff == 0
        ? 'Today'
        : diff == 1
        ? 'Yesterday'
        : '${date.day} ${_months[date.month - 1]}'
              '${date.year == now.year ? '' : ' ${date.year}'}';

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSizes.s),
        padding: EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
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
        MediaQuery.of(context).viewInsets.bottom + AppSizes.m,
      ),
      // decoration: BoxDecoration(
      //   color: Theme.of(context).scaffoldBackgroundColor.withAlpha(100),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withAlpha(15),
      //       blurRadius: 8,
      //       offset: const Offset(0, -2),
      //     ),
      //   ],
      // ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).extension<AppColors>()!.searchBarBg,
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
            ),
          ),
          AppSizes.s.horizontalSpace,
          GestureDetector(
            onTap: onSend,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).extension<AppColors>()!.searchBarBg.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: AppSizes.iconSizeMedium,
                  ),
                ),
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
