import '../../data/network/network_error.dart';
import '../core/result.dart';
import '../repositories/leave_policy_repository.dart';

class DeleteLeavePolicyUseCase {
  final LeavePolicyRepository _repository;

  DeleteLeavePolicyUseCase(this._repository);

  Future<Result<void, NetworkError>> execute() {
    return _repository.delete();
  }
}
