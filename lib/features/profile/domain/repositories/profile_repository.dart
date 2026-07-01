import 'package:gokgok/features/profile/domain/entities/profile_screen_model.dart';

/// Profile read/update operations exposed to the presentation layer.
abstract interface class ProfileRepository {
  /// Loads the current user's profile, or an empty profile when signed out.
  Future<ProfileScreenModel> fetchCurrentProfile();

  /// Updates the current user's editable profile fields.
  Future<void> updateProfile({
    required String email,
    required String fullName,
  });
}
