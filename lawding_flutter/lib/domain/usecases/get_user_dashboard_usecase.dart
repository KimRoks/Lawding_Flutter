import '../core/result.dart';
import '../entities/user_dashboard.dart';
import '../repositories/user_repository.dart';
import '../../data/network/network_error.dart';

/// 내 대시보드 정보 조회 UseCase
class GetUserDashboardUseCase {
  final UserRepository _repository;

  GetUserDashboardUseCase(this._repository);

  Future<Result<UserDashboard, NetworkError>> execute() async {
    return await _repository.getDashboard();
  }
}
