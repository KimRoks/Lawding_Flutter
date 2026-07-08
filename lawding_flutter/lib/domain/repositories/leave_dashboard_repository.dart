import '../../data/network/network_error.dart';
import '../core/result.dart';
import '../entities/leave_dashboard.dart';

abstract interface class LeaveDashboardRepository {
  /// GET /v1/dashboard/leave
  Future<Result<LeaveDashboard, NetworkError>> get();
}
