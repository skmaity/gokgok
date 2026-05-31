import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokgok/features/dash_board/models/gorup_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final groupProvider = AsyncNotifierProvider<GroupNotifire, List<GorupModel>>(
  GroupNotifire.new,
);

class GroupNotifire extends AsyncNotifier<List<GorupModel>> {
  @override
  Future<List<GorupModel>> build() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    // Stream group_members rows for this user; re-fetch group details on each event.
    final subscription = supabase
        .from('group_members')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((memberRows) async {
          if (memberRows.isEmpty) {
            state = const AsyncData([]);
            return;
          }
          final groupIds = memberRows
              .map((r) => r['group_id'] as String)
              .toList();
          final groupRows = await supabase
              .from('groups')
              .select()
              .inFilter('id', groupIds);
          state = AsyncData(
            groupRows.map((r) => GorupModel.fromJson(r)).toList(),
          );
        });

    ref.onDispose(subscription.cancel);

    // Return current data for the initial state while stream warms up.
    final rows = await supabase
        .from('group_members')
        .select('groups(*)')
        .eq('user_id', userId);

    return rows
        .map(
          (row) => GorupModel.fromJson(row['groups'] as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> joinGroup(String inviteCode) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final code = inviteCode.trim();

    final row = await supabase
        .from('groups')
        .select()
        .eq('invite_code', code)
        .maybeSingle();

    if (row == null) throw Exception('Invalid invite code. Please check and try again.');

    final group = GorupModel.fromJson(row);

    final existing = await supabase
        .from('group_members')
        .select()
        .eq('group_id', group.id)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) throw Exception('You are already a member of this group.');

    await supabase.from('group_members').insert({
      'group_id': group.id,
      'user_id': userId,
    });

    final current = state.value ?? [];
    state = AsyncData([...current, group]);
  }

  Future<void> createGroup(String groupName) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final json = await supabase
          .from('groups')
          .insert({'name': groupName, 'created_by': userId})
          .select()
          .single();

      await supabase.from('group_members').insert({
        'group_id': json['id'],
        'user_id': userId,
      });

      final current = state.value ?? [];
      state = AsyncData([...current, GorupModel.fromJson(json)]);
    } catch (e) {
      log('Error creating group: $e');
    }
  }
}
