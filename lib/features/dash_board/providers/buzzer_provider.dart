import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

const _buzzerAssetPath = 'assets/mp3/thetestdata-sample-mp3-6.mp3';
const _buzzerAssetPath1 =
    "https://previous-tomato-7gkqixkdo1.edgeone.app/thetestdata-sample-mp3-6.mp3";

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
      state = "Playing Buzzer...";
      await _player.stop();
      await _player.setUrl(
        "https://eventual-aquamarine-aymbqii6li.edgeone.app/faaah.mp3",
      );
      await _player.seek(Duration.zero);
      await _player.play();
      state = "";
    } catch (error) {
      state = "Audio error: $error";
    }
  }

  void buzzerClear() {
    state = "";
  }
}
