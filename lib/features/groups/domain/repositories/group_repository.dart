import 'package:gokgok/features/groups/domain/entities/group_model.dart';

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
}
