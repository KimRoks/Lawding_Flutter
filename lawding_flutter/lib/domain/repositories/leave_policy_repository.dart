import '../../data/network/network_error.dart';
import '../core/result.dart';
import '../entities/leave_policy.dart';
import '../entities/leave_policy_request.dart';

abstract interface class LeavePolicyRepository {
  Future<Result<void, NetworkError>> submit(LeavePolicyRequest request);
  Future<Result<void, NetworkError>> update(LeavePolicyRequest request);
  Future<Result<LeavePolicy, NetworkError>> get();
  Future<Result<void, NetworkError>> delete();
}
