/// A meme sound in the buzzer catalog (managed in the admin panel,
/// table `buzzer_sounds`). Only fields the app actually uses are kept.
class BuzzerSound {
  final String id;
  final String name;
  final String? category;
  final String soundUrl;

  const BuzzerSound({
    required this.id,
    required this.name,
    required this.soundUrl,
    this.category,
  });

  factory BuzzerSound.fromJson(Map<String, dynamic> json) => BuzzerSound(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String?,
    soundUrl: json['sound_url'] as String,
  );
}
