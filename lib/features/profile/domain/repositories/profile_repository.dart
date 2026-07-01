import 'dart:typed_data';

import 'package:gokgok/features/profile/domain/entities/profile_screen_model.dart';

/// Profile read/update operations exposed to the presentation layer.
abstract interface class ProfileRepository {
  /// Loads the current user's profile, or an empty profile when signed out.
  Future<ProfileScreenModel> fetchCurrentProfile();

  /// Updates the current user's editable profile fields.
  Future<void> updateProfile({required String fullName});

  /// Uploads a new avatar image and stores its URL. Returns the new URL.
  Future<String> updateAvatar({
    required Uint8List bytes,
    required String fileExt,
  });

  /// Clears the current user's avatar.
  Future<void> removeAvatar();
}
