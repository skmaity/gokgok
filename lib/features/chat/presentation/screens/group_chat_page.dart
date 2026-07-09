import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gokgok/core/routing/app_routes.dart';
import 'package:gokgok/core/widgets/glass_header_bar.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/groups/domain/entities/group_model.dart';
import 'package:gokgok/features/groups/presentation/providers/group_provider.dart';
import 'package:gokgok/features/chat/domain/entities/message_model.dart';
import 'package:gokgok/features/chat/presentation/providers/chat_provider.dart';
import 'package:gokgok/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:gokgok/features/chat/presentation/widgets/date_separator.dart';
import 'package:gokgok/features/chat/presentation/widgets/empty_chat.dart';
import 'package:gokgok/features/chat/presentation/widgets/message_bubble.dart';

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
      bottomNavigationBar: ChatInputBar(
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
        if (messages.isEmpty) return EmptyChat(groupName: widget.group.name);
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
            final bubble = MessageBubble(
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
                DateSeparator(date: msg.createdAt.toLocal()),
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
