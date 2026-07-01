import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokgok/core/network/supabase_providers.dart';
import 'package:gokgok/features/groups/data/datasources/group_remote_data_source.dart';
import 'package:gokgok/features/groups/data/repositories/group_repository_impl.dart';
import 'package:gokgok/features/groups/domain/entities/group_model.dart';
import 'package:gokgok/features/groups/domain/repositories/group_repository.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepositoryImpl(
    GroupRemoteDataSource(ref.watch(supabaseClientProvider)),
  );
});

final groupProvider = AsyncNotifierProvider<GroupNotifier, List<GroupModel>>(
  GroupNotifier.new,
);

class GroupNotifier extends AsyncNotifier<List<GroupModel>> {
  GroupRepository get _repository => ref.read(groupRepositoryProvider);

  @override
  Future<List<GroupModel>> build() async {
    final subscription = _repository.watchGroups().listen((groups) {
      state = AsyncData(groups);
    });
    ref.onDispose(subscription.cancel);

    return _repository.fetchGroups();
  }

  Future<void> joinGroup(String inviteCode) async {
    final group = await _repository.joinGroup(inviteCode);
    final current = state.value ?? [];
    state = AsyncData([...current, group]);
  }

  Future<void> createGroup(String groupName) async {
    try {
      final group = await _repository.createGroup(groupName);
      final current = state.value ?? [];
      state = AsyncData([...current, group]);
    } catch (e) {
      log('Error creating group: $e');
    }
  }
}
