import '../../data/network/network_error.dart';
import '../core/result.dart';
import '../entities/leave_policy.dart';
import '../repositories/leave_policy_repository.dart';

class GetLeavePolicyUseCase {
  final LeavePolicyRepository _repository;

  GetLeavePolicyUseCase(this._repository);

  Future<Result<LeavePolicy, NetworkError>> execute() {
    return _repository.get();
  }
}
