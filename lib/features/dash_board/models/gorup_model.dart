// To parse this JSON data, do
//
//     final gorupModel = gorupModelFromJson(jsonString);

import 'dart:convert';

GorupModel gorupModelFromJson(String str) =>
    GorupModel.fromJson(json.decode(str));

String gorupModelToJson(GorupModel data) => json.encode(data.toJson());

class GorupModel {
  final String id;
  final String name;
  final String inviteCode;
  final String createdBy;
  final DateTime createdAt;

  GorupModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
    required this.createdAt,
  });

  GorupModel copyWith({
    String? id,
    String? name,
    String? inviteCode,
    String? createdBy,
    DateTime? createdAt,
  }) => GorupModel(
    id: id ?? this.id,
    name: name ?? this.name,
    inviteCode: inviteCode ?? this.inviteCode,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );

  factory GorupModel.fromJson(Map<String, dynamic> json) => GorupModel(
    id: json["id"],
    name: json["name"],
    inviteCode: json["invite_code"],
    createdBy: json["created_by"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "invite_code": inviteCode,
    "created_by": createdBy,
    "created_at": createdAt.toIso8601String(),
  };
}
