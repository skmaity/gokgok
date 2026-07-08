import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/core/widgets/app_network_image.dart';
import 'package:gokgok/features/groups/domain/entities/group_model.dart';
import 'package:gokgok/features/chat/domain/entities/conversation_preview.dart';
import 'package:gokgok/features/chat/presentation/providers/chat_provider.dart';
import 'package:gokgok/features/chat/presentation/screens/group_chat_page.dart';
import 'package:gokgok/features/groups/domain/entities/member_model.dart';
import 'package:gokgok/features/groups/presentation/providers/group_provider.dart';
import 'package:gokgok/features/groups/presentation/widgets/empty_state_no_friends_groups.dart';
import 'package:gokgok/features/dashboard/presentation/widgets/top_header_widget_title_only.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.paddingOf(context).top),
        TopHeaderWidgetTitleOnly(title: 'Chats', padding: 24.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
            child: groupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (groups) {
                if (groups.isEmpty) return EmptyStateNoFriendsGroups();
                final previews =
                    ref.watch(conversationPreviewsProvider).value ?? const {};
                final currentUserId =
                    ref.read(chatRepositoryProvider).currentUserId;
                // Most recent activity first; groups without messages last.
                final sorted = [...groups]
                  ..sort((a, b) {
                    final ta = previews[a.id]?.lastMessageAt;
                    final tb = previews[b.id]?.lastMessageAt;
                    if (ta == null && tb == null) return 0;
                    if (ta == null) return 1;
                    if (tb == null) return -1;
                    return tb.compareTo(ta);
                  });
                return ListView.builder(
                  // Clears the floating bottom nav (parent uses extendBody).
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.paddingOf(context).bottom + AppSizes.m,
                  ),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) => _GroupTile(
                    group: sorted[index],
                    preview: previews[sorted[index].id],
                    currentUserId: currentUserId,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group, this.preview, this.currentUserId});

  final GroupModel group;
  final ConversationPreview? preview;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final lastMessageAt = preview?.lastMessageAt;
    String? senderName;
    if (preview?.senderId != null) {
      senderName = preview!.senderId == currentUserId
          ? 'You'
          : group.members
                .where((m) => m.id == preview!.senderId)
                .firstOrNull
                ?.username;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => GroupChatPage(group: group))),
      leading: group.groupAvatarUrl == null
          ? CircleAvatar(child: Text(group.name[0].toUpperCase()))
          : AppNetworkImage(
              url: group.groupAvatarUrl,
              size: AppSizes.avatarSize,
              borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
            ),

      title: Text(group.name),
      subtitle: preview?.body != null
          ? Text(
              '${senderName ?? 'Someone'}: ${preview!.body}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            )
          : group.members.isEmpty
          ? SizedBox()
          : SizedBox(
              width: 60,
              height: 22,

              child: WidgetStack(
                positions: RestrictedPositions(
                  minCoverage: 0.4,
                  maxCoverage: 0.6,
                ),
                stackedWidgets: group.members
                    .map((m) => _memberAvatar(context, m))
                    .toList(),
                buildInfoWidget: (surplus, context) =>
                    _initialCircle(context, '+$surplus'),
              ),
            ),
      trailing: lastMessageAt != null
          ? Text(
              _relativeTime(lastMessageAt),
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            )
          : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }
}

String _relativeTime(DateTime t) {
  final local = t.toLocal();
  final now = DateTime.now();
  final diff = DateTime(now.year, now.month, now.day)
      .difference(DateTime(local.year, local.month, local.day))
      .inDays;
  if (diff == 0) {
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
  if (diff == 1) return 'Yesterday';
  return '${local.day}/${local.month}/${local.year}';
}

Widget _memberAvatar(BuildContext context, MemberModel member) {
  if (member.avatarUrl.isNotEmpty) {
    return BorderedCircleAvatar(
      border: const BorderSide(color: Colors.white, width: 2),
      backgroundImage: CachedNetworkImageProvider(member.avatarUrl),
    );
  }
  final initial = member.username.isNotEmpty
      ? member.username[0].toUpperCase()
      : '?';
  return _initialCircle(context, initial);
}

Widget _initialCircle(BuildContext context, String text) {
  return BorderedCircleAvatar(
    border: const BorderSide(color: Colors.white, width: 2),
    backgroundColor: Theme.of(context).colorScheme.primary,
    child: FittedBox(
      fit: BoxFit.contain,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    ),
  );
}
