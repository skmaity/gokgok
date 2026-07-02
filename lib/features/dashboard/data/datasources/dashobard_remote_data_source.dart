import 'package:supabase_flutter/supabase_flutter.dart';

class DashobardRemoteDataSource {
  DashobardRemoteDataSource(this._client);
  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<Map<String, dynamic>?> fetchProfileRow(String userId) {
    return _client.from('profiles').select().eq('id', userId).maybeSingle();
  }
}
