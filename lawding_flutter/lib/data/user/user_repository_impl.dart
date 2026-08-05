import '../../domain/core/result.dart';
import '../../domain/entities/user_me.dart';
import '../../domain/repositories/user_repository.dart';
import '../network/api_endpoints.dart';
import '../network/api_request.dart';
import '../network/dio_client.dart';
import '../network/http_methods.dart';
import '../network/network_error.dart';
import 'user_me_response.dart';

class UserRepositoryImpl implements UserRepository {
  final DioClient _client;

  UserRepositoryImpl(this._client);

  @override
  Future<Result<UserMe, NetworkError>> getMe() async {
    try {
      const request = ApiRequest(
        method: HttpMethod.get,
        path: ApiEndpoints.userMe,
      );
      final response = await _client.request(request);
      final body = response.data as Map<String, dynamic>;
      final dto = UserMeResponse.fromJson(body['data'] as Map<String, dynamic>);
      return Success(dto.toDomain());
    } on NetworkError catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<void, NetworkError>> updateProfile({
    required String nickname,
  }) async {
    try {
      final request = ApiRequest(
        method: HttpMethod.patch,
        path: ApiEndpoints.userProfile,
        body: {'nickname': nickname},
      );
      await _client.request(request);
      return const Success(null);
    } on NetworkError catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<void, NetworkError>> deleteAccount() async {
    try {
      const request = ApiRequest(
        method: HttpMethod.delete,
        path: ApiEndpoints.userProfile,
      );
      await _client.request(request);
      return const Success(null);
    } on NetworkError catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<void, NetworkError>> updateLeaveYearlyBalance({
    required int totalLeaveMinutes,
  }) async {
    try {
      final request = ApiRequest(
        method: HttpMethod.patch,
        path: ApiEndpoints.leaveYearlyBalance,
        body: {'totalLeaveMinutes': totalLeaveMinutes},
      );
      await _client.request(request);
      return const Success(null);
    } on NetworkError catch (error) {
      return Failure(error);
    }
  }
}
