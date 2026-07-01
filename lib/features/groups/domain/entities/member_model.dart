class MemberModel {
  final String id;
  final String username;
  final String avatarUrl;
  final DateTime? updatedAt;

  MemberModel({
    required this.id,
    required this.username,
    required this.avatarUrl,
    this.updatedAt,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
    id: json['id'] as String,
    username: (json['full_name'] as String?) ?? '',
    avatarUrl: (json['avatar_url'] as String?) ?? '',
    updatedAt: json['updated_at'] == null
        ? null
        : DateTime.parse(json['updated_at'] as String),
  );
}
