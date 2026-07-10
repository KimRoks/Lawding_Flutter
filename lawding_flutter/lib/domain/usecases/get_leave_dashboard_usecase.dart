import '../../data/network/network_error.dart';
import '../core/result.dart';
import '../entities/leave_dashboard.dart';
import '../repositories/leave_dashboard_repository.dart';

class GetLeaveDashboardUseCase {
  final LeaveDashboardRepository _repository;

  GetLeaveDashboardUseCase(this._repository);

  Future<Result<LeaveDashboard, NetworkError>> execute() {
    return _repository.get();
  }
}
