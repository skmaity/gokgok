import 'package:supabase_flutter/supabase_flutter.dart' show User;

/// Authentication operations exposed to the presentation layer, independent of
/// the concrete auth backend.
///
/// Note: [currentUser] intentionally returns Supabase's [User]; the app reuses
/// it as the auth entity rather than maintaining a duplicate domain model.
abstract interface class AuthRepository {
  Future<void> signUp({required String email, required String password});

  Future<void> login({required String email, required String password});

  Future<void> logout();

  /// The currently authenticated user, or `null` when signed out.
  User? get currentUser;
}
