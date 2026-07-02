import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokgok/core/network/supabase_providers.dart';
import 'package:gokgok/features/groups/data/datasources/group_remote_data_source.dart';
import 'package:gokgok/features/groups/data/repositories/group_repository_impl.dart';
import 'package:gokgok/features/groups/domain/entities/group_model.dart';
import 'package:gokgok/features/groups/domain/entities/group_role.dart';
import 'package:gokgok/features/groups/domain/entities/member_model.dart';
import 'package:gokgok/features/groups/domain/repositories/group_repository.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepositoryImpl(
    GroupRemoteDataSource(ref.watch(supabaseClientProvider)),
  );
});

final groupProvider = AsyncNotifierProvider<GroupNotifier, List<GroupModel>>(
  GroupNotifier.new,
);

class GroupNotifier extends AsyncNotifier<List<GroupModel>> {
  GroupRepository get _repository => ref.read(groupRepositoryProvider);

  @override
  Future<List<GroupModel>> build() async {
    final subscription = _repository.watchGroups().listen((groups) {
      state = AsyncData(groups);
    });
    ref.onDispose(subscription.cancel);

    return _repository.fetchGroups();
  }

  Future<void> joinGroup(String inviteCode) async {
    final group = await _repository.joinGroup(inviteCode);
    final current = state.value ?? [];
    state = AsyncData([...current, group]);
  }

  Future<void> createGroup(String groupName) async {
    try {
      final group = await _repository.createGroup(groupName);
      final current = state.value ?? [];
      state = AsyncData([...current, group]);
    } catch (e) {
      log('Error creating group: $e');
    }
  }
}

/// Realtime members of one group, with roles. The `group_members` stream
/// pushes role changes, joins, and kicks made by anyone — mutations below
/// don't need to refetch.
final groupMembersProvider = AsyncNotifierProvider.autoDispose
    .family<GroupMembersNotifier, List<MemberModel>, String>(
      (arg) => GroupMembersNotifier(arg),
    );

/// Realtime stream of one group's row (name, avatar); null once deleted.
final groupStreamProvider = StreamProvider.autoDispose
    .family<GroupModel?, String>(
      (ref, groupId) => ref.watch(groupRepositoryProvider).watchGroup(groupId),
    );

class GroupMembersNotifier extends AsyncNotifier<List<MemberModel>> {
  GroupMembersNotifier(this.groupId);

  final String groupId;

  GroupRepository get _repository => ref.read(groupRepositoryProvider);

  @override
  Future<List<MemberModel>> build() async {
    final subscription = _repository.watchGroupMembers(groupId).listen((
      members,
    ) {
      state = AsyncData(members);
    });
    ref.onDispose(subscription.cancel);

    return _repository.fetchGroupMembers(groupId);
  }

  Future<void> transferAdmin(String newAdminId) =>
      _repository.transferAdmin(groupId: groupId, newAdminId: newAdminId);

  Future<void> setRole(String targetId, GroupRole role) => _repository
      .setMemberRole(groupId: groupId, targetId: targetId, role: role);

  Future<void> kick(String targetId) =>
      _repository.kickMember(groupId: groupId, targetId: targetId);

  /// Uploads (or removes, when [bytes] is null) the group avatar and returns
  /// the new URL. Refreshes the groups list so chat tiles pick it up.
  Future<String?> updateAvatar(Uint8List? bytes) async {
    final url = await _repository.updateGroupAvatar(
      groupId: groupId,
      bytes: bytes,
    );
    ref.invalidate(groupProvider);
    return url;
  }
}
