import 'package:supabase_flutter/supabase_flutter.dart';

/// Raw Supabase calls for the profile feature.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Future<Map<String, dynamic>?> fetchProfileRow(String userId) {
    return _client.from('profiles').select().eq('id', userId).maybeSingle();
  }

  Future<void> updateUserProfile({
    required String email,
    required String fullName,
  }) async {
    await _client.auth.updateUser(
      UserAttributes(email: email, data: {'full_name': fullName}),
    );
  }
}
