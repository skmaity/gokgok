import 'dart:typed_data';
import 'package:gokgok/core/errors/app_exception.dart';
import 'package:gokgok/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:gokgok/features/profile/domain/entities/profile_screen_model.dart';
import 'package:gokgok/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<ProfileScreenModel> fetchCurrentProfile() async {
    final user = _remote.currentUser;
    if (user == null) {
      return ProfileScreenModel(null, null, null, null);
    }

    final profileData = await _remote.fetchProfileRow(user.id);

    return ProfileScreenModel(
      profileData?['email'] as String? ?? user.email,
      profileData?['full_name'] as String? ??
          user.userMetadata?['full_name'] as String?,
      profileData?['phone'] as String? ?? user.phone,
      profileData?['avatar_url'] as String?,
    );
  }

  @override
  Future<void> updateProfile({required String fullName}) {
    return _remote.updateUserProfile(fullName: fullName);
  }

  @override
  Future<String> updateAvatar({
    required Uint8List bytes,
    required String fileExt,
  }) async {
    final user = _remote.currentUser;
    if (user == null) throw const AppException('Not authenticated');

    final url = await _remote.uploadAvatar(
      userId: user.id,
      bytes: bytes,
      fileExt: fileExt,
    );
    await _remote.updateAvatarUrl(userId: user.id, url: url);
    return url;
  }

  @override
  Future<void> removeAvatar() async {
    final user = _remote.currentUser;
    if (user == null) throw const AppException('Not authenticated');

    await _remote.updateAvatarUrl(userId: user.id, url: null);
  }
}
