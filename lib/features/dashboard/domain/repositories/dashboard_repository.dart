import 'package:gokgok/features/dashboard/domain/entities/dashboard_model.dart';

abstract interface class DashboardRepository {
  // load current under info for dashboard
  Future<DashboardModel> getDashboardData();
}
