import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

sealed class AuthState {
  const AuthState();
}

class AuthIdle extends AuthState {
  const AuthIdle();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthNotifier extends Notifier<AuthState> {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  AuthState build() => const AuthIdle();

  Future<void> signUp(String email, String password) async {
    state = const AuthLoading();
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'test_key': 'test_data'},
      );
      if (response.user != null) {
        state = const AuthSuccess();
      } else {
        state = const AuthError('Sign up failed. Please try again.');
      }
    } on AuthException catch (e) {
      state = AuthError(e.message);
    } catch (_) {
      state = const AuthError('An unexpected error occurred.');
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      state = const AuthSuccess();
    } on AuthException catch (e) {
      state = AuthError(e.message);
    } catch (_) {
      state = const AuthError('An unexpected error occurred.');
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {}
  }

  void reset() => state = const AuthIdle();
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
