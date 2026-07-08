import '../../data/network/network_error.dart';
import '../core/result.dart';
import '../entities/user_dashboard.dart';
import '../repositories/user_repository.dart';

class GetLeaveSummaryUseCase {
  final UserRepository _repository;

  GetLeaveSummaryUseCase(this._repository);

  Future<Result<UserDashboard, NetworkError>> execute() {
    return _repository.getLeaveSummary();
  }
}
