import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gokgok/core/routing/app_routes.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/core/widgets/app_network_image.dart';
import 'package:gokgok/features/groups/domain/entities/group_model.dart';
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
        MediaQuery.of(context).viewPadding.top.verticalSpace,
        TopHeaderWidgetTitleOnly(title: 'Chats', padding: 24.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
            child: groupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (groups) => groups.isEmpty
                  ? EmptyStateNoFriendsGroups()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: groups.length,
                            itemBuilder: (context, index) =>
                                _GroupTile(group: groups[index]),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
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
      subtitle: group.members.isEmpty
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
      trailing: PopupMenuButton<String>(
        color: Colors.white,
        icon: const Icon(Icons.more_vert_outlined, color: Colors.black54),
        onSelected: (value) {
          if (value == 'members') {
            context.push(AppRoutes.chatMembers, extra: group);
          } else {
            // TODO: abc action
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'members', child: Text('Members')),
          PopupMenuItem(value: 'abc', child: Text('Abc')),
        ],
      ),
      // trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }
}

Widget _memberAvatar(BuildContext context, MemberModel member) {
  if (member.avatarUrl.isNotEmpty) {
    return BorderedCircleAvatar(
      border: const BorderSide(color: Colors.white, width: 2),
      backgroundImage: NetworkImage(member.avatarUrl),
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
