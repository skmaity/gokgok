import 'package:gokgok/features/dashboard/data/datasources/dashobard_remote_data_source.dart';
import 'package:gokgok/features/dashboard/domain/entities/dashboard_model.dart';
import 'package:gokgok/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._remote);
  final DashobardRemoteDataSource _remote;
  @override
  Future<DashboardModel> getDashboardData() async {
    final userId = _remote.currentUserId;
    if (userId == null) {
      return DashboardModel(null, null);
    }
    final row = await _remote.fetchProfileRow(userId);
    if (row == null) {
      return DashboardModel(null, null);
    }
    return DashboardModel.fromJson(row);
  }
}
