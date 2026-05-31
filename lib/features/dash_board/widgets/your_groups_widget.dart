import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/features/dash_board/models/gorup_model.dart';
import 'package:gokgok/features/dash_board/pages/group_chat_page.dart';
import 'package:gokgok/features/dash_board/providers/group_provider.dart';
import 'package:gokgok/features/dash_board/providers/navbar_provider.dart';

class YourGroupsWidget extends ConsumerWidget {
  const YourGroupsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "your groups",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            GestureDetector(
              // onTap: () => showJoinGroupSheet(context),
              onTap: () {
                ref.read(navbarProvider.notifier).state = 1;
              },
              child: Text(
                'see all',
                style: TextStyle(
                  color: Theme.of(context).extension<AppColors>()!.highlight,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        groupsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (groups) => groups.isEmpty
              ? const Text('No groups yet')
              : ListView.builder(
                  padding: EdgeInsets.all(0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groups.length,
                  itemBuilder: (context, index) =>
                      _GroupTile(group: groups[index]),
                ),
        ),
      ],
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});

  final GorupModel group;

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
