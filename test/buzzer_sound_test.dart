import 'package:flutter_test/flutter_test.dart';
import 'package:gokgok/features/buzzer/domain/entities/buzzer_sound.dart';

void main() {
  test('BuzzerSound.fromJson maps snake_case row + nullable category', () {
    final full = BuzzerSound.fromJson({
      'id': 'abc',
      'name': 'Vine Boom',
      'category': 'Memes',
      'sound_url': 'https://x/boom.mp3',
    });
    expect(full.id, 'abc');
    expect(full.name, 'Vine Boom');
    expect(full.category, 'Memes');
    expect(full.soundUrl, 'https://x/boom.mp3');

    final noCategory = BuzzerSound.fromJson({
      'id': 'def',
      'name': 'Air Horn',
      'category': null,
      'sound_url': 'https://x/horn.mp3',
    });
    expect(noCategory.category, isNull);
  });
}
