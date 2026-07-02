import 'package:flutter_test/flutter_test.dart';
import 'package:gokgok/features/groups/domain/entities/group_role.dart';

void main() {
  group('GroupRolePermissions.actionsOn', () {
    test('admin on member: transfer, promote, kick', () {
      expect(GroupRole.admin.actionsOn(GroupRole.member, isSelf: false), [
        MemberAction.transferAdmin,
        MemberAction.promote,
        MemberAction.kick,
      ]);
    });

    test('admin on sub-admin: transfer, demote, kick', () {
      expect(GroupRole.admin.actionsOn(GroupRole.subAdmin, isSelf: false), [
        MemberAction.transferAdmin,
        MemberAction.demote,
        MemberAction.kick,
      ]);
    });

    test('sub-admin on member: promote, kick only', () {
      expect(GroupRole.subAdmin.actionsOn(GroupRole.member, isSelf: false), [
        MemberAction.promote,
        MemberAction.kick,
      ]);
    });

    test('sub-admin on sub-admin: nothing', () {
      expect(
        GroupRole.subAdmin.actionsOn(GroupRole.subAdmin, isSelf: false),
        isEmpty,
      );
    });

    test('nobody can act on the admin', () {
      for (final role in GroupRole.values) {
        expect(role.actionsOn(GroupRole.admin, isSelf: false), isEmpty);
      }
    });

    test('member can act on nobody', () {
      for (final target in GroupRole.values) {
        expect(GroupRole.member.actionsOn(target, isSelf: false), isEmpty);
      }
    });

    test('nobody can act on themselves', () {
      for (final role in GroupRole.values) {
        for (final target in GroupRole.values) {
          expect(role.actionsOn(target, isSelf: true), isEmpty);
        }
      }
    });
  });
}
