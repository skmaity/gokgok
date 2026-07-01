import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokgok/core/services/audio_service.dart';

const _buzzerAssetPath = 'assets/mp3/faaah.mp3';

final buzzerProvider = NotifierProvider<BuzzerNotifier, String>(
  BuzzerNotifier.new,
);

class BuzzerNotifier extends Notifier<String> {
  @override
  String build() => "";

  Future<void> buzzerPressed() async {
    try {
      state = "Playing Buzzer...";
      await ref
          .read(audioServiceProvider)
          .playAsset(_buzzerAssetPath, volume: 1.0);
      state = "";
    } catch (error) {
      state = "Audio error: $error";
    }
  }

  void buzzerClear() {
    state = "";
  }
}
