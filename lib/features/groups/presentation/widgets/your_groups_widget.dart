import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gokgok/core/routing/app_routes.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/core/widgets/app_network_image.dart';
import 'package:gokgok/features/groups/domain/entities/group_model.dart';
import 'package:gokgok/features/groups/domain/entities/member_model.dart';
import 'package:gokgok/features/groups/presentation/providers/group_provider.dart';
import 'package:gokgok/features/dashboard/presentation/providers/navbar_provider.dart';

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

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        context.push(AppRoutes.chat, extra: group);
      },

      leading: group.groupAvatarUrl == null
          ? CircleAvatar(child: Text(group.name[0].toUpperCase()))
          : AppNetworkImage(
              url: group.groupAvatarUrl,
              size: AppSizes.avatarSize,
              borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
            ),

      title: Text(group.name, style: TextStyle(fontWeight: FontWeight.w600)),
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
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
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
}
