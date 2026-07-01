import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/groups/domain/entities/group_model.dart';
import 'package:gokgok/features/chat/presentation/screens/group_chat_page.dart';
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
      leading: CircleAvatar(child: Text(group.name[0].toUpperCase())),
      title: Text(group.name),
      subtitle: Text('Code: ${group.inviteCode}'),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }
}
