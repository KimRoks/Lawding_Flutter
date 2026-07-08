import '../../data/network/network_error.dart';
import '../core/result.dart';
import '../entities/leave_policy_request.dart';
import '../repositories/leave_policy_repository.dart';

class SubmitLeavePolicyUseCase {
  final LeavePolicyRepository _repository;

  SubmitLeavePolicyUseCase(this._repository);

  Future<Result<void, NetworkError>> execute(LeavePolicyRequest request) {
    return _repository.submit(request);
  }
}
