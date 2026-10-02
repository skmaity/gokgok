import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokgok/core/network/supabase_providers.dart';
import 'package:gokgok/core/services/audio_service.dart';
import 'package:gokgok/features/buzzer/data/datasources/buzzer_remote_data_source.dart';
import 'package:gokgok/features/buzzer/data/repositories/buzzer_repository_impl.dart';
import 'package:gokgok/features/buzzer/domain/entities/buzzer_sound.dart';
import 'package:gokgok/features/buzzer/domain/repositories/buzzer_repository.dart';

const _buzzerAssetPath = 'assets/mp3/faaah.mp3';

final buzzerRepositoryProvider = Provider<BuzzerRepository>(
  (ref) => BuzzerRepositoryImpl(
    BuzzerRemoteDataSource(ref.watch(supabaseClientProvider)),
  ),
);

/// The buzzer sound catalog (admin-managed, active only). One-shot fetch;
/// `ref.invalidate` re-fetches (pull-to-refresh on the sounds page).
final buzzerSoundsProvider = FutureProvider<List<BuzzerSound>>(
  (ref) => ref.watch(buzzerRepositoryProvider).fetchSounds(),
);

/// The sound the buzzer button fires. Null → the bundled fallback asset.
// ponytail: in-memory only; add shared_preferences if the pick must survive
// an app restart.
final selectedSoundProvider =
    NotifierProvider<SelectedSoundNotifier, BuzzerSound?>(
      SelectedSoundNotifier.new,
    );

class SelectedSoundNotifier extends Notifier<BuzzerSound?> {
  @override
  BuzzerSound? build() => null;

  void select(BuzzerSound sound) => state = sound;
}

final buzzerProvider = NotifierProvider<BuzzerNotifier, String>(
  BuzzerNotifier.new,
);

class BuzzerNotifier extends Notifier<String> {
  @override
  String build() => "";

  Future<void> buzzerPressed() async {
    final selected = ref.read(selectedSoundProvider);
    try {
      state = "Playing Buzzer...";
      final audio = ref.read(audioServiceProvider);
      if (selected != null) {
        await audio.playUrl(selected.soundUrl, volume: 1.0);
      } else {
        await audio.playAsset(_buzzerAssetPath, volume: 1.0);
      }
      state = "";
    } catch (error) {
      state = "Audio error: $error";
    }
  }

  void buzzerClear() {
    state = "";
  }
}
