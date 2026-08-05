import '../../domain/core/result.dart';
import '../../domain/entities/leave_policy_request.dart';
import '../../domain/repositories/leave_policy_repository.dart';
import '../network/api_endpoints.dart';
import '../network/api_request.dart';
import '../network/dio_client.dart';
import '../network/http_methods.dart';
import '../network/network_error.dart';

class LeavePolicyRepositoryImpl implements LeavePolicyRepository {
  final DioClient _client;

  LeavePolicyRepositoryImpl(this._client);

  @override
  Future<Result<void, NetworkError>> submit(LeavePolicyRequest request) async {
    try {
      await _client.request(ApiRequest(
        method: HttpMethod.post,
        path: ApiEndpoints.leavePolicy,
        body: request.toJson(),
      ));
      return const Success(null);
    } on NetworkError catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<void, NetworkError>> delete() async {
    try {
      await _client.request(const ApiRequest(
        method: HttpMethod.delete,
        path: ApiEndpoints.leavePolicy,
      ));
      return const Success(null);
    } on NetworkError catch (error) {
      return Failure(error);
    }
  }

}
