import 'package:gokgok/features/buzzer/domain/entities/buzzer_sound.dart';

/// Read access to the buzzer sound catalog.
abstract interface class BuzzerRepository {
  /// One-shot fetch of the active buzzer sounds, newest first.
  Future<List<BuzzerSound>> fetchSounds();
}
