import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// Thin wrapper around [AudioPlayer] so features can fire one-shot sound
/// effects without depending on the audio package directly.
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  /// Plays a bundled asset from the start at the given [volume] (0.0–1.0).
  Future<void> playAsset(String assetPath, {double volume = 1.0}) async {
    await _player.stop();
    await _player.setAsset(assetPath);
    await _player.setVolume(volume);
    await _player.seek(Duration.zero);
    await _player.play();
  }

  void dispose() => _player.dispose();
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});
