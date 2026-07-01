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
  Future<void> updateProfile({
    required String email,
    required String fullName,
  }) {
    return _remote.updateUserProfile(email: email, fullName: fullName);
  }
}
