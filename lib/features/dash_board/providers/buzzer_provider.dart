import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

const _buzzerAssetPath = 'assets/mp3/thetestdata-sample-mp3-6.mp3';

final buzzerProvider = NotifierProvider<BuzzerNotifier, String>(
  BuzzerNotifier.new,
);

class BuzzerNotifier extends Notifier<String> {
  final _player = AudioPlayer();

  @override
  String build() {
    ref.onDispose(() => _player.dispose());
    return "";
  }

  Future<void> buzzerPressed() async {
    try {
      state = "Buzzer Pressed...";
      await _player.stop();
      await _player.setFilePath(filePath)
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (error) {
      state = "Audio error: $error";
    }
  }

  void buzzerClear() {
    state = "";
  }
}
