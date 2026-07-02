import 'dart:typed_data';

import 'package:gokgok/features/groups/domain/entities/group_role.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Raw Supabase calls for the groups feature. No business logic — only queries.
class GroupRemoteDataSource {
  GroupRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _avatarBucket = 'group_img';

  String? get currentUserId => _client.auth.currentUser?.id;

  /// Streams the raw `group_members` rows for [userId].
  Stream<List<Map<String, dynamic>>> watchMemberRows(String userId) {
    return _client
        .from('group_members')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId);
  }

  Future<List<Map<String, dynamic>>> fetchGroupsByIds(List<String> groupIds) {
    return _client.from('groups').select().inFilter('id', groupIds);
  }

  /// One-shot: the group rows joined through the user's memberships.
  Future<List<Map<String, dynamic>>> fetchMemberGroupRows(String userId) async {
    final rows = await _client
        .from('group_members')
        .select('groups(*)')
        .eq('user_id', userId);

    return rows.map((row) => row['groups'] as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> fetchGroupMemberIds(String groupId) async {
    final members = await _client
        .from('group_members')
        .select('user_id, permission')
        .eq('group_id', groupId);

    return members
        .map((m) => {'userid': m['user_id'], 'permission': m['permission']})
        .toList();
  }

  /// Streams the raw `group_members` rows of one group (roles, joins, kicks).
  Stream<List<Map<String, dynamic>>> watchGroupMemberRows(String groupId) {
    return _client
        .from('group_members')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId);
  }

  /// Streams one `groups` row (name, avatar, ...); null once deleted.
  Stream<Map<String, dynamic>?> watchGroupRow(String groupId) {
    return _client
        .from('groups')
        .stream(primaryKey: ['id'])
        .eq('id', groupId)
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<List<Map<String, dynamic>>> fetchMemberProfiles(List<String> userIds) {
    return _client
        .from('profiles')
        .select('id, full_name, avatar_url, updated_at')
        .inFilter('id', userIds);
  }

  Future<Map<String, dynamic>?> findGroupByInviteCode(String code) {
    return _client
        .from('groups')
        .select()
        .eq('invite_code', code)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> findMembership({
    required String groupId,
    required String userId,
  }) {
    return _client
        .from('group_members')
        .select()
        .eq('group_id', groupId)
        .eq('user_id', userId)
        .maybeSingle();
  }

  Future<void> addMember({
    required String groupId,
    required String userId,
    GroupRole role = GroupRole.member,
  }) {
    return _client.from('group_members').insert({
      'group_id': groupId,
      'user_id': userId,
      'permission': role.value,
    });
  }

  /// Uploads the group avatar (same path convention as profile avatars:
  /// `<groupId>/avatar.<ext>`, upserted) and returns a cache-busted public URL.
  Future<String> uploadGroupAvatar({
    required String groupId,
    required Uint8List bytes,
    required String fileExt,
  }) async {
    final path = '$groupId/avatar.$fileExt';
    await _client.storage
        .from(_avatarBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: 'image/${fileExt == 'jpg' ? 'jpeg' : fileExt}',
          ),
        );
    final url = _client.storage.from(_avatarBucket).getPublicUrl(path);
    return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> updateGroupAvatarUrl({required String groupId, String? url}) {
    return _client
        .from('groups')
        .update({'group_avatar_url': url})
        .eq('id', groupId);
  }

  /// Atomic admin transfer via the `transfer_admin` RPC (doc/group_roles.sql).
  Future<void> transferAdmin({
    required String groupId,
    required String newAdminId,
  }) {
    return _client.rpc(
      'transfer_admin',
      params: {'p_group_id': groupId, 'p_new_admin_id': newAdminId},
    );
  }

  /// Promote/demote via the `set_member_role` RPC (doc/group_roles.sql).
  Future<void> setMemberRole({
    required String groupId,
    required String targetId,
    required GroupRole role,
  }) {
    return _client.rpc(
      'set_member_role',
      params: {
        'p_group_id': groupId,
        'p_target_id': targetId,
        'p_role': role.value,
      },
    );
  }

  /// Remove a member via the `kick_member` RPC (doc/group_roles.sql).
  Future<void> kickMember({required String groupId, required String targetId}) {
    return _client.rpc(
      'kick_member',
      params: {'p_group_id': groupId, 'p_target_id': targetId},
    );
  }

  Future<Map<String, dynamic>> insertGroup({
    required String name,
    required String createdBy,
  }) {
    return _client
        .from('groups')
        .insert({'name': name, 'created_by': createdBy})
        .select()
        .single();
  }
}
