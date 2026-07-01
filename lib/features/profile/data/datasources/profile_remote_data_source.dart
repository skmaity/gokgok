import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Raw Supabase calls for the profile feature.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._client);

  static const _avatarBucket = 'profile_img';

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Future<Map<String, dynamic>?> fetchProfileRow(String userId) {
    return _client.from('profiles').select().eq('id', userId).maybeSingle();
  }

  Future<void> updateUserProfile({required String fullName}) async {
    final userId = currentUser?.id;
    if (userId == null) return;
    await _client
        .from('profiles')
        .update({'full_name': fullName})
        .eq('id', userId);
  }

  /// Uploads [bytes] to the `profile_img` bucket and returns a public URL.
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileExt,
  }) async {
    final path = '$userId/avatar.$fileExt';
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
    // Cache-bust so the new image shows immediately over the reused path.
    return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> updateAvatarUrl({
    required String userId,
    required String? url,
  }) async {
    await _client.from('profiles').update({'avatar_url': url}).eq('id', userId);
  }
}
