import '../core/result.dart';
import '../repositories/user_repository.dart';
import '../../data/network/network_error.dart';

class UpdateLeaveYearlyBalanceUseCase {
  final UserRepository _repository;

  UpdateLeaveYearlyBalanceUseCase(this._repository);

  Future<Result<void, NetworkError>> execute({
    required int totalLeaveMinutes,
  }) {
    return _repository.updateLeaveYearlyBalance(
      totalLeaveMinutes: totalLeaveMinutes,
    );
  }
}
