enum GroupRole {
  admin('admin'),
  subAdmin('sub_admin'),
  member('member');

  const GroupRole(this.value);

  final String value;

  // Unknown/null from DB falls back to member (least privilege).
  static GroupRole fromValue(String? value) => GroupRole.values.firstWhere(
    (r) => r.value == value,
    orElse: () => GroupRole.member,
  );
}

/// Actions a user can take on another group member.
///
/// UI gating only — the same rules are enforced server-side by the
/// SECURITY DEFINER RPCs in doc/group_roles.sql.
enum MemberAction { transferAdmin, promote, demote, kick }

extension GroupRolePermissions on GroupRole {
  /// Actions `this` (the current user's role) may take on [target].
  ///
  /// Rules: one admin per group; admin can transfer admin (becoming a plain
  /// member), promote/demote sub-admins, and kick anyone but self; sub-admins
  /// can promote members and kick members only; members can do nothing.
  List<MemberAction> actionsOn(GroupRole target, {required bool isSelf}) {
    // target == admin implies self under the one-admin invariant, but the
    // explicit guard keeps this safe on stale data.
    if (isSelf || target == GroupRole.admin) return const [];
    final isAdmin = this == GroupRole.admin;
    final isSub = this == GroupRole.subAdmin;
    return [
      if (isAdmin) MemberAction.transferAdmin,
      if ((isAdmin || isSub) && target == GroupRole.member)
        MemberAction.promote,
      if (isAdmin && target == GroupRole.subAdmin) MemberAction.demote,
      if (isAdmin || (isSub && target == GroupRole.member)) MemberAction.kick,
    ];
  }
}
