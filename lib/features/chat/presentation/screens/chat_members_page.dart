import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/core/widgets/app_network_image.dart';
import 'package:gokgok/core/widgets/avatar_picker.dart';
import 'package:gokgok/core/widgets/image_viewer_page.dart';
import 'package:gokgok/core/widgets/top_header_widget.dart';
import 'package:gokgok/features/groups/domain/entities/group_model.dart';
import 'package:gokgok/features/groups/domain/entities/group_role.dart';
import 'package:gokgok/features/groups/domain/entities/member_model.dart';
import 'package:gokgok/features/groups/presentation/providers/group_provider.dart';
import 'package:image_picker/image_picker.dart';

class ChatMembersPage extends ConsumerStatefulWidget {
  final GroupModel group;
  const ChatMembersPage({super.key, required this.group});

  @override
  ConsumerState<ChatMembersPage> createState() => _ChatMembersPageState();
}

class _ChatMembersPageState extends ConsumerState<ChatMembersPage> {
  bool _isUploadingAvatar = false;

  GroupModel get group => widget.group;

  void _showAvatarOptions() {
    showAvatarOptionsSheet(
      context,
      title: 'Change Group Photo',
      onCamera: () => _pickAndUpload(ImageSource.camera),
      onGallery: () => _pickAndUpload(ImageSource.gallery),
      onRemove: _removeAvatar,
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final bytes = await pickAndCropAvatar(context, source: source);
    if (bytes == null) return;
    await _updateAvatar(bytes, 'Group photo updated');
  }

  Future<void> _removeAvatar() => _updateAvatar(null, 'Group photo removed');

  Future<void> _updateAvatar(Uint8List? bytes, String successMessage) async {
    setState(() => _isUploadingAvatar = true);
    try {
      // The groups-row stream delivers the new URL to the header.
      await ref
          .read(groupMembersProvider(group.id).notifier)
          .updateAvatar(bytes);
      _showSnack(successMessage);
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final highlight = Theme.of(context).extension<AppColors>()!.highlight;
    final myId = ref.read(groupRepositoryProvider).currentUserId;
    final membersAsync = ref.watch(groupMembersProvider(group.id));

    // Kicked while viewing -> leave the page.
    ref.listen(groupMembersProvider(group.id), (_, next) {
      final members = next.value;
      if (members != null &&
          members.isNotEmpty &&
          !members.any((m) => m.id == myId)) {
        context.pop();
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            TopHeaderWidget(onPressed: () => context.pop(), title: 'Members'),
            Expanded(
              child: membersAsync.when(
                loading: () =>
                    Center(child: CircularProgressIndicator(color: highlight)),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (members) => _buildList(context, ref, members, myId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    // Live group row; falls back to the route's snapshot until the first event.
    final streamed = ref.watch(groupStreamProvider(group.id));
    final avatarUrl = streamed.hasValue
        ? streamed.value?.groupAvatarUrl
        : group.groupAvatarUrl;

    if (_isUploadingAvatar) {
      final highlight = Theme.of(context).extension<AppColors>()!.highlight;
      return Container(
        width: 96.w,
        height: 96.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: highlight.withAlpha(25),
        ),
        child: Center(
          child: CircularProgressIndicator(color: highlight, strokeWidth: 2.5),
        ),
      );
    }
    if (avatarUrl == null) {
      return CircleAvatar(
        radius: 48.w,
        child: Text(
          group.name[0].toUpperCase(),
          style: TextStyle(fontSize: 36.sp),
        ),
      );
    }
    return GestureDetector(
      onTap: () => showImageViewer(context, avatarUrl),
      child: Hero(
        tag: avatarUrl,
        child: AppNetworkImage(
          url: avatarUrl,
          size: 96.w,
          borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<MemberModel> members,
    String? myId,
  ) {
    // admin -> sub-admin -> member (enum declaration order).
    final sorted = [...members]
      ..sort(
        (a, b) => (a.permission ?? GroupRole.member).index.compareTo(
          (b.permission ?? GroupRole.member).index,
        ),
      );
    final myRole = sorted
        .where((m) => m.id == myId)
        .map((m) => m.permission ?? GroupRole.member)
        .firstOrNull;
    final canEditAvatar =
        myRole == GroupRole.admin || myRole == GroupRole.subAdmin;

    return RefreshIndicator(
      onRefresh: () => ref.refresh(groupMembersProvider(group.id).future),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
        children: [
          AppSizes.l.verticalSpace,
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                _buildAvatar(context),
                if (canEditAvatar)
                  GestureDetector(
                    onTap: _isUploadingAvatar ? null : _showAvatarOptions,
                    child: Container(
                      padding: EdgeInsets.all(7.w),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).extension<AppColors>()!.highlight,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 14.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          AppSizes.m.verticalSpace,
          Center(
            child: Text(
              group.name,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            ),
          ),
          AppSizes.xs.verticalSpace,
          Center(
            child: Text(
              '${sorted.length} member${sorted.length == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ),
          AppSizes.l.verticalSpace,
          for (final member in sorted)
            _MemberTile(
              member: member,
              isSelf: member.id == myId,
              actions: (myRole ?? GroupRole.member).actionsOn(
                member.permission ?? GroupRole.member,
                isSelf: member.id == myId,
              ),
              groupId: group.id,
            ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final MemberModel member;
  final bool isSelf;
  final List<MemberAction> actions;
  final String groupId;

  const _MemberTile({
    required this.member,
    required this.isSelf,
    required this.actions,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: AppNetworkImage(
        url: member.avatarUrl,
        size: AppSizes.avatarSize,
        borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
      ),
      title: Text(isSelf ? '${member.username} (you)' : member.username),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoleBadge(role: member.permission ?? GroupRole.member),
          // 3-dot hint that this tile opens the actions drawer.
          // if (actions.isNotEmpty)
          //   Icon(
          //     Icons.more_vert,
          //     size: AppSizes.iconSizeSmall,
          //     color: Colors.grey,
          //   ),
        ],
      ),
      onTap: actions.isEmpty
          ? null
          : () => _showMemberActionsSheet(
              context,
              groupId: groupId,
              member: member,
              actions: actions,
            ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final GroupRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final label = switch (role) {
      GroupRole.admin => 'Admin',
      GroupRole.subAdmin => 'Sub-admin',
      GroupRole.member => 'Member',
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4.h),
      decoration: BoxDecoration(
        color: role == GroupRole.admin ? colors.highlight : colors.searchBarBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: role == GroupRole.admin ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }
}

void _showMemberActionsSheet(
  BuildContext context, {
  required String groupId,
  required MemberModel member,
  required List<MemberAction> actions,
}) {
  showModalBottomSheet(
    useSafeArea: true,
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusMedium),
      ),
    ),
    builder: (_) =>
        _MemberActionsSheet(groupId: groupId, member: member, actions: actions),
  );
}

class _MemberActionsSheet extends ConsumerStatefulWidget {
  final String groupId;
  final MemberModel member;
  final List<MemberAction> actions;

  const _MemberActionsSheet({
    required this.groupId,
    required this.member,
    required this.actions,
  });

  @override
  ConsumerState<_MemberActionsSheet> createState() =>
      _MemberActionsSheetState();
}

class _MemberActionsSheetState extends ConsumerState<_MemberActionsSheet> {
  bool _isLoading = false;
  String? _error;

  Future<void> _run(MemberAction action) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final notifier = ref.read(groupMembersProvider(widget.groupId).notifier);
    final targetId = widget.member.id;
    try {
      switch (action) {
        case MemberAction.transferAdmin:
          await notifier.transferAdmin(targetId);
        case MemberAction.promote:
          await notifier.setRole(targetId, GroupRole.subAdmin);
        case MemberAction.demote:
          await notifier.setRole(targetId, GroupRole.member);
        case MemberAction.kick:
          await notifier.kick(targetId);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final highlight = Theme.of(context).extension<AppColors>()!.highlight;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.screenPadding,
        right: AppSizes.screenPadding,
        top: AppSizes.l,
        bottom: MediaQuery.of(context).padding.bottom + AppSizes.m,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
          AppSizes.l.verticalSpace,
          Text(
            widget.member.username,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
          ),
          AppSizes.s.verticalSpace,
          for (final action in widget.actions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: !_isLoading,
              leading: Icon(
                switch (action) {
                  MemberAction.transferAdmin => Icons.admin_panel_settings,
                  MemberAction.promote => Icons.add_moderator,
                  MemberAction.demote => Icons.remove_moderator,
                  MemberAction.kick => Icons.person_remove,
                },
                color: action == MemberAction.kick
                    ? Colors.red.shade400
                    : highlight,
              ),
              title: Text(
                switch (action) {
                  MemberAction.transferAdmin =>
                    'Make admin (you become a member)',
                  MemberAction.promote => 'Make sub-admin',
                  MemberAction.demote => 'Demote to member',
                  MemberAction.kick => 'Remove from group',
                },
                style: TextStyle(
                  color: action == MemberAction.kick
                      ? Colors.red.shade400
                      : null,
                ),
              ),
              onTap: () => _run(action),
            ),
          if (_error != null) ...[
            AppSizes.xs.verticalSpace,
            Text(
              _error!,
              style: TextStyle(fontSize: 12.sp, color: Colors.red.shade400),
            ),
          ],
        ],
      ),
    );
  }
}
