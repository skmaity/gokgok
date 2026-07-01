import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokgok/core/errors/app_exception.dart';
import 'package:gokgok/core/network/supabase_providers.dart';
import 'package:gokgok/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:gokgok/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gokgok/features/auth/domain/repositories/auth_repository.dart';
import 'package:gokgok/features/auth/presentation/state/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// Re-exported so screens can keep importing auth state from the provider.
export 'package:gokgok/features/auth/presentation/state/auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    AuthRemoteDataSource(ref.watch(supabaseClientProvider)),
  );
});

class AuthNotifier extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() => const AuthIdle();

  Future<void> signUp(String email, String password) async {
    state = const AuthLoading();
    try {
      await _repository.signUp(email: email, password: password);
      state = const AuthSuccess();
    } on AppException catch (e) {
      state = AuthError(e.message);
    } catch (_) {
      state = const AuthError('An unexpected error occurred.');
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      await _repository.login(email: email, password: password);
      state = const AuthSuccess();
    } on AppException catch (e) {
      state = AuthError(e.message);
    } catch (_) {
      state = const AuthError('An unexpected error occurred.');
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
    }
  }

  User getCurrentUser() {
    final user = _repository.currentUser;
    if (user == null) {
      logout();
      throw AuthException('No authenticated user.');
    }
    return user;
  }

  void reset() => state = const AuthIdle();
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
