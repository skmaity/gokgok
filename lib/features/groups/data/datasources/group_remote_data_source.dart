import 'package:supabase_flutter/supabase_flutter.dart';

/// Raw Supabase calls for the groups feature. No business logic — only queries.
class GroupRemoteDataSource {
  GroupRemoteDataSource(this._client);

  final SupabaseClient _client;

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

  Future<List<String>> fetchGroupMemberIds(String groupId) async {
    final members = await _client
        .from('group_members')
        .select('user_id')
        .eq('group_id', groupId);

    return members.map((m) => m['user_id'] as String).toList();
  }

  Future<List<String>> fetchAvatarUrls(List<String> userIds) async {
    final profiles = await _client
        .from('profiles')
        .select('avatar_url')
        .inFilter('id', userIds);

    return profiles
        .map((p) => (p['avatar_url'] as String?) ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
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
  }) {
    return _client.from('group_members').insert({
      'group_id': groupId,
      'user_id': userId,
    });
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
