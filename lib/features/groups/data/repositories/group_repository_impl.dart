import 'package:gokgok/core/errors/app_exception.dart';
import 'package:gokgok/features/groups/data/datasources/group_remote_data_source.dart';
import 'package:gokgok/features/groups/domain/entities/group_model.dart';
import 'package:gokgok/features/groups/domain/repositories/group_repository.dart';

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
    return _attachAvatars(groupRows);
  }

  @override
  Stream<List<GroupModel>> watchGroups() {
    final userId = currentUserId;
    if (userId == null) return Stream.value(const []);

    return _remote.watchMemberRows(userId).asyncMap((memberRows) async {
      if (memberRows.isEmpty) return <GroupModel>[];

      final groupIds = memberRows.map((r) => r['group_id'] as String).toList();
      final groupRows = await _remote.fetchGroupsByIds(groupIds);
      return _attachAvatars(groupRows);
    });
  }

  Future<List<GroupModel>> _attachAvatars(
    List<Map<String, dynamic>> groupRows,
  ) {
    return Future.wait(groupRows.map(_attachMemberAvatars));
  }

  Future<GroupModel> _attachMemberAvatars(
    Map<String, dynamic> groupJson,
  ) async {
    try {
      final userIds = await _remote.fetchGroupMemberIds(
        groupJson['id'] as String,
      );
      if (userIds.isEmpty) return GroupModel.fromJson(groupJson);

      final avatarUrls = await _remote.fetchAvatarUrls(userIds);
      return GroupModel.fromJson(
        groupJson,
      ).copyWith(memberAvatarUrls: avatarUrls);
    } catch (_) {
      return GroupModel.fromJson(groupJson);
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
    await _remote.addMember(groupId: json['id'] as String, userId: userId);
    return GroupModel.fromJson(json);
  }
}
