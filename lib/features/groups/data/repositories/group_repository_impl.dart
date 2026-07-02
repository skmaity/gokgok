import 'dart:developer';
import 'dart:typed_data';

import 'package:gokgok/core/errors/app_exception.dart';
import 'package:gokgok/features/groups/data/datasources/group_remote_data_source.dart';
import 'package:gokgok/features/groups/domain/entities/group_model.dart';
import 'package:gokgok/features/groups/domain/entities/group_role.dart';
import 'package:gokgok/features/groups/domain/entities/member_model.dart';
import 'package:gokgok/features/groups/domain/repositories/group_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl(this._remote);

  final GroupRemoteDataSource _remote;

  @override
  String? get currentUserId => _remote.currentUserId;

  @override
  Future<List<GroupModel>> fetchGroups() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final groupRows = await _remote.fetchMemberGroupRows(userId);
    return _attachMembers(groupRows);
  }

  @override
  Stream<List<GroupModel>> watchGroups() {
    final userId = currentUserId;
    if (userId == null) return Stream.value(const []);

    return _remote.watchMemberRows(userId).asyncMap((memberRows) async {
      if (memberRows.isEmpty) return <GroupModel>[];

      final groupIds = memberRows.map((r) => r['group_id'] as String).toList();
      final groupRows = await _remote.fetchGroupsByIds(groupIds);
      return _attachMembers(groupRows);
    });
  }

  Future<List<GroupModel>> _attachMembers(
    List<Map<String, dynamic>> groupRows,
  ) {
    return Future.wait(groupRows.map(_attachMembersToGroup));
  }

  Future<GroupModel> _attachMembersToGroup(
    Map<String, dynamic> groupJson,
  ) async {
    try {
      final members = await fetchGroupMembers(groupJson['id'] as String);
      if (members.isEmpty) return GroupModel.fromJson(groupJson);
      return GroupModel.fromJson(groupJson).copyWith(members: members);
    } catch (e) {
      log("error in group members data ${e.toString()}");
      return GroupModel.fromJson(groupJson);
    }
  }

  @override
  Future<List<MemberModel>> fetchGroupMembers(String groupId) async {
    final memberRows = await _remote.fetchGroupMemberIds(groupId);
    return _membersWithRoles({
      for (final m in memberRows)
        m['userid'] as String: GroupRole.fromValue(m['permission'] as String?),
    });
  }

  @override
  Stream<List<MemberModel>> watchGroupMembers(String groupId) {
    return _remote.watchGroupMemberRows(groupId).asyncMap(
      (rows) => _membersWithRoles({
        for (final r in rows)
          r['user_id'] as String: GroupRole.fromValue(
            r['permission'] as String?,
          ),
      }),
    );
  }

  @override
  Stream<GroupModel?> watchGroup(String groupId) {
    return _remote
        .watchGroupRow(groupId)
        .map((row) => row == null ? null : GroupModel.fromJson(row));
  }

  /// Hydrates member profiles for the given userId->role map.
  Future<List<MemberModel>> _membersWithRoles(
    Map<String, GroupRole> roleById,
  ) async {
    if (roleById.isEmpty) return const [];
    final profiles = await _remote.fetchMemberProfiles(roleById.keys.toList());
    return profiles
        .map(
          (p) =>
              MemberModel.fromJson(p).copyWith(permission: roleById[p['id']]),
        )
        .toList();
  }

  @override
  Future<void> transferAdmin({
    required String groupId,
    required String newAdminId,
  }) {
    return _runRpc(
      () => _remote.transferAdmin(groupId: groupId, newAdminId: newAdminId),
    );
  }

  @override
  Future<void> setMemberRole({
    required String groupId,
    required String targetId,
    required GroupRole role,
  }) {
    return _runRpc(
      () => _remote.setMemberRole(
        groupId: groupId,
        targetId: targetId,
        role: role,
      ),
    );
  }

  @override
  Future<void> kickMember({
    required String groupId,
    required String targetId,
  }) {
    return _runRpc(
      () => _remote.kickMember(groupId: groupId, targetId: targetId),
    );
  }

  @override
  Future<String?> updateGroupAvatar({
    required String groupId,
    Uint8List? bytes,
  }) async {
    try {
      String? url;
      if (bytes != null) {
        // Crop output is always a 500x500 JPG (see avatar_picker.dart).
        url = await _remote.uploadGroupAvatar(
          groupId: groupId,
          bytes: bytes,
          fileExt: 'jpg',
        );
      }
      await _remote.updateGroupAvatarUrl(groupId: groupId, url: url);
      return url;
    } on StorageException catch (e) {
      throw AppException(e.message);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    }
  }

  /// Surfaces the `raise exception` message from the SQL RPCs as a clean
  /// [AppException] for the UI.
  Future<void> _runRpc(Future<void> Function() call) async {
    try {
      await call();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    }
  }

  @override
  Future<GroupModel> joinGroup(String inviteCode) async {
    final userId = currentUserId;
    if (userId == null) throw const AppException('Not authenticated');

    final code = inviteCode.trim();
    final row = await _remote.findGroupByInviteCode(code);
    if (row == null) {
      throw const AppException(
        'Invalid invite code. Please check and try again.',
      );
    }

    final group = GroupModel.fromJson(row);
    final existing = await _remote.findMembership(
      groupId: group.id,
      userId: userId,
    );
    if (existing != null) {
      throw const AppException('You are already a member of this group.');
    }

    await _remote.addMember(groupId: group.id, userId: userId);
    return group;
  }

  @override
  Future<GroupModel> createGroup(String groupName) async {
    final userId = currentUserId;
    if (userId == null) throw const AppException('Not authenticated');

    final json = await _remote.insertGroup(name: groupName, createdBy: userId);
    await _remote.addMember(
      groupId: json['id'] as String,
      userId: userId,
      role: GroupRole.admin,
    );
    return GroupModel.fromJson(json);
  }
}
