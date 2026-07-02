// To parse this JSON data, do
//
//     final groupModel = groupModelFromJson(jsonString);

import 'dart:convert';

import 'package:gokgok/features/groups/domain/entities/member_model.dart';

GroupModel groupModelFromJson(String str) =>
    GroupModel.fromJson(json.decode(str));

String groupModelToJson(GroupModel data) => json.encode(data.toJson());

class GroupModel {
  final String? groupAvatarUrl;
  final String id;
  final String name;
  final String inviteCode;
  final String createdBy;
  final DateTime createdAt;
  final List<MemberModel> members;

  GroupModel({
    required this.groupAvatarUrl,
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
    required this.createdAt,
    this.members = const [],
  });

  GroupModel copyWith({
    String? groupAvatarUrl,
    String? id,
    String? name,
    String? inviteCode,
    String? createdBy,
    DateTime? createdAt,
    List<MemberModel>? members,
  }) => GroupModel(
    groupAvatarUrl: groupAvatarUrl ?? this.groupAvatarUrl,
    id: id ?? this.id,
    name: name ?? this.name,
    inviteCode: inviteCode ?? this.inviteCode,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    members: members ?? this.members,
  );

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
    groupAvatarUrl: json['group_avatar_url'],
    id: json["id"],
    name: json["name"],
    inviteCode: json["invite_code"],
    createdBy: json["created_by"],
    createdAt: DateTime.parse(json["created_at"]),
    members:
        (json['group_members'] as List?)
            ?.where((m) => m['profiles'] != null)
            .map(
              (m) =>
                  MemberModel.fromJson(m['profiles'] as Map<String, dynamic>),
            )
            .toList() ??
        const [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "invite_code": inviteCode,
    "created_by": createdBy,
    "created_at": createdAt.toIso8601String(),
  };
}
