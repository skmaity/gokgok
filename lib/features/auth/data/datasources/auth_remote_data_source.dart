import 'package:supabase_flutter/supabase_flutter.dart';

/// Raw Supabase auth calls. Holds no business logic — it only talks to the
/// backend so the repository can stay testable.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentSession?.user;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email.trim(), password: password);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() => _client.auth.signOut();
}
