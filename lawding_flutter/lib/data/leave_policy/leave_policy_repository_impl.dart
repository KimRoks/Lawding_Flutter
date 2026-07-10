import '../../domain/core/result.dart';
import '../../domain/entities/leave_policy.dart';
import '../../domain/entities/leave_policy_request.dart';
import '../../domain/repositories/leave_policy_repository.dart';
import '../network/api_endpoints.dart';
import '../network/api_request.dart';
import '../network/dio_client.dart';
import '../network/http_methods.dart';
import '../network/network_error.dart';
import 'leave_policy_response.dart';

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
  Future<Result<void, NetworkError>> update(LeavePolicyRequest request) async {
    try {
      await _client.request(ApiRequest(
        method: HttpMethod.put,
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

  @override
  Future<Result<LeavePolicy, NetworkError>> get() async {
    try {
      const request = ApiRequest(
        method: HttpMethod.get,
        path: ApiEndpoints.leavePolicy,
      );
      final response = await _client.request(request);
      final body = response.data as Map<String, dynamic>;
      final dto = LeavePolicyResponse.fromJson(
        body['data'] as Map<String, dynamic>,
      );
      return Success(dto.toDomain());
    } on NetworkError catch (error) {
      return Failure(error);
    }
  }
}
