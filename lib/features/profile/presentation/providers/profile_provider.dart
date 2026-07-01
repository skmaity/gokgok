import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokgok/core/network/supabase_providers.dart';
import 'package:gokgok/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:gokgok/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:gokgok/features/profile/domain/entities/profile_screen_model.dart';
import 'package:gokgok/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    ProfileRemoteDataSource(ref.watch(supabaseClientProvider)),
  );
});

final profileScreenProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileScreenModel>(
      ProfileNotifier.new,
    );

class ProfileNotifier extends AsyncNotifier<ProfileScreenModel> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  Future<ProfileScreenModel> build() => _repository.fetchCurrentProfile();

  /// Persists the editable profile fields via the repository.
  Future<void> updateProfile({
    required String email,
    required String fullName,
  }) {
    return _repository.updateProfile(email: email, fullName: fullName);
  }
}
