import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokgok/features/dash_board/models/gorup_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final groupProvider =
    AsyncNotifierProvider<GroupNotifire, List<GorupModel>>(
  GroupNotifire.new,
);

class GroupNotifire extends AsyncNotifier<List<GorupModel>> {
  @override
  Future<List<GorupModel>> build() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final rows = await supabase
        .from('group_members')
        .select('groups(*)')
        .eq('user_id', userId);

    return rows
        .map((row) => GorupModel.fromJson(row['groups'] as Map<String, dynamic>))
        .toList();
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
      print('Error creating group: $e');
    }
  }
}
