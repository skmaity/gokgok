class DashboardModel {
  final String? avatarUrl;
  final String? fullName;

  DashboardModel(this.avatarUrl, this.fullName);

  DashboardModel copyWith({String? avatarUrl, String? fullName}) =>
      DashboardModel(avatarUrl ?? this.avatarUrl, fullName ?? this.fullName);

  factory DashboardModel.fromJson(Map<String, dynamic> json) =>
      DashboardModel(json['avatar_url'] as String?, json['full_name'] as String?);
}
