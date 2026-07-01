// To parse this JSON data, do
//
//     final groupModel = groupModelFromJson(jsonString);

import 'dart:convert';

GroupModel groupModelFromJson(String str) =>
    GroupModel.fromJson(json.decode(str));

String groupModelToJson(GroupModel data) => json.encode(data.toJson());

class GroupModel {
  final String id;
  final String name;
  final String inviteCode;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberAvatarUrls;

  GroupModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
    required this.createdAt,
    this.memberAvatarUrls = const [],
  });

  GroupModel copyWith({
    String? id,
    String? name,
    String? inviteCode,
    String? createdBy,
    DateTime? createdAt,
    List<String>? memberAvatarUrls,
  }) => GroupModel(
    id: id ?? this.id,
    name: name ?? this.name,
    inviteCode: inviteCode ?? this.inviteCode,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    memberAvatarUrls: memberAvatarUrls ?? this.memberAvatarUrls,
  );

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
    id: json["id"],
    name: json["name"],
    inviteCode: json["invite_code"],
    createdBy: json["created_by"],
    createdAt: DateTime.parse(json["created_at"]),
    memberAvatarUrls: (json['group_members'] as List?)
            ?.map((m) => (m['profiles']?['avatar_url'] as String?) ?? '')
            .where((url) => url.isNotEmpty)
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "invite_code": inviteCode,
    "created_by": createdBy,
    "created_at": createdAt.toIso8601String(),
  };
}
