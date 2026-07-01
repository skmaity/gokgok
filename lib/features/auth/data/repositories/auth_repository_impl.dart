import 'package:gokgok/core/errors/app_exception.dart';
import 'package:gokgok/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:gokgok/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  User? get currentUser => _remote.currentUser;

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remote.signUp(email: email, password: password);
      if (response.user == null) {
        throw const AppException('Sign up failed. Please try again.');
      }
    } on AuthException catch (e) {
      throw AppException(e.message);
    }
  }

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _remote.login(email: email, password: password);
    } on AuthException catch (e) {
      throw AppException(e.message);
    }
  }

  @override
  Future<void> logout() => _remote.logout();
}
