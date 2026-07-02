import 'package:gokgok/features/groups/domain/entities/group_role.dart';

class MemberModel {
  final String id;
  final String username;
  final String avatarUrl;
  final DateTime? updatedAt;
  final GroupRole? permission;

  MemberModel({
    required this.id,
    required this.username,
    required this.avatarUrl,
    this.updatedAt,
    this.permission,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
    id: json['id'] as String,
    username: (json['full_name'] as String?) ?? '',
    avatarUrl: (json['avatar_url'] as String?) ?? '',
    updatedAt: json['updated_at'] == null
        ? null
        : DateTime.parse(json['updated_at'] as String),
    permission: GroupRole.fromValue(json['permission']),
  );

  MemberModel copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    DateTime? updatedAt,
    GroupRole? permission,
  }) {
    return MemberModel(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      permission: permission ?? this.permission,
    );
  }
}
