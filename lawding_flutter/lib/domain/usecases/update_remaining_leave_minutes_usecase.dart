import '../core/result.dart';
import '../repositories/user_repository.dart';
import '../../data/network/network_error.dart';

class UpdateRemainingLeaveMinutesUseCase {
  final UserRepository _repository;

  UpdateRemainingLeaveMinutesUseCase(this._repository);

  Future<Result<void, NetworkError>> execute({
    required int remainingLeaveMinutes,
  }) {
    return _repository.updateRemainingLeaveMinutes(
      remainingLeaveMinutes: remainingLeaveMinutes,
    );
  }
}
