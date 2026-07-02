import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokgok/core/network/supabase_providers.dart';
import 'package:gokgok/features/dashboard/data/datasources/dashobard_remote_data_source.dart';
import 'package:gokgok/features/dashboard/data/repository/dashboard_repository_impl.dart';
import 'package:gokgok/features/dashboard/domain/entities/dashboard_model.dart';
import 'package:gokgok/features/dashboard/domain/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    DashobardRemoteDataSource(ref.watch(supabaseClientProvider)),
  );
});

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardModel>(
      DashboardNotifier.new,
    );

class DashboardNotifier extends AsyncNotifier<DashboardModel> {
  DashboardRepository get _repository => ref.read(dashboardRepositoryProvider);

  @override
  FutureOr<DashboardModel> build() => _repository.getDashboardData();
}
