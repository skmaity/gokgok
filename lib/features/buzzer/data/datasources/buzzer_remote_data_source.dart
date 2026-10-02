import 'package:supabase_flutter/supabase_flutter.dart';

/// Raw Supabase calls for the buzzer feature. No business logic — only queries.
class BuzzerRemoteDataSource {
  BuzzerRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _table = 'buzzer_sounds';

  /// Active sounds, newest first. RLS already hides inactive rows from
  /// non-admins; the `is_active` filter keeps it explicit.
  Future<List<Map<String, dynamic>>> fetchActiveSounds() {
    return _client
        .from(_table)
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);
  }
}
