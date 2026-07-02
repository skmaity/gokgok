import 'dart:typed_data';

import 'package:gokgok/features/groups/domain/entities/group_model.dart';
import 'package:gokgok/features/groups/domain/entities/group_role.dart';
import 'package:gokgok/features/groups/domain/entities/member_model.dart';

/// Group membership operations exposed to the presentation layer.
abstract interface class GroupRepository {
  /// The current user's id, or `null` when signed out.
  String? get currentUserId;

  /// One-shot fetch of the current user's groups (with member avatars).
  Future<List<GroupModel>> fetchGroups();

  /// Realtime stream of the current user's groups (with member avatars).
  Stream<List<GroupModel>> watchGroups();

  /// Joins a group by invite code and returns the joined group.
  Future<GroupModel> joinGroup(String inviteCode);

  /// Creates a group owned by the current user and returns it.
  Future<GroupModel> createGroup(String groupName);

  /// One-shot fetch of a group's members with their roles.
  Future<List<MemberModel>> fetchGroupMembers(String groupId);

  /// Realtime stream of a group's members with their roles.
  Stream<List<MemberModel>> watchGroupMembers(String groupId);

  /// Realtime stream of one group's row (name, avatar); null once deleted.
  Stream<GroupModel?> watchGroup(String groupId);

  /// Makes [newAdminId] the admin; the current admin becomes a member.
  Future<void> transferAdmin({
    required String groupId,
    required String newAdminId,
  });

  /// Promotes a member to sub-admin, or demotes a sub-admin to member.
  Future<void> setMemberRole({
    required String groupId,
    required String targetId,
    required GroupRole role,
  });

  /// Removes [targetId] from the group.
  Future<void> kickMember({required String groupId, required String targetId});

  /// Uploads a new group avatar and returns its URL, or removes it (and
  /// returns null) when [bytes] is null.
  Future<String?> updateGroupAvatar({
    required String groupId,
    Uint8List? bytes,
  });
}
