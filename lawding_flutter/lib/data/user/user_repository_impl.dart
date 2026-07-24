import 'package:flutter/foundation.dart';

import '../../domain/core/result.dart';
import '../../domain/entities/user_dashboard.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../network/api_endpoints.dart';
import '../network/api_request.dart';
import '../network/dio_client.dart';
import '../network/http_methods.dart';
import '../network/network_error.dart';
import 'user_dashboard_response.dart';
import 'user_profile_response.dart';

class UserRepositoryImpl implements UserRepository {
  final DioClient _client;

  UserRepositoryImpl(this._client);

  @override
  Future<Result<UserProfile, NetworkError>> getProfile() async {
    try {
      const request = ApiRequest(
        method: HttpMethod.get,
        path: ApiEndpoints.userProfile,
      );
      final response = await _client.request(request);
      final body = response.data as Map<String, dynamic>;
      final dto = UserProfileResponse.fromJson(
        body['data'] as Map<String, dynamic>,
      );
      return Success(dto.toDomain());
    } on NetworkError catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<UserDashboard, NetworkError>> getLeaveSummary() async {
    try {
      const request = ApiRequest(
        method: HttpMethod.get,
        path: ApiEndpoints.leaveSummary,
      );
      final response = await _client.request(request);
      final body = response.data as Map<String, dynamic>;
      final dto = UserDashboardResponse.fromJson(
        body['data'] as Map<String, dynamic>,
      );
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
  Future<Result<UserDashboard, NetworkError>> getDashboard() async {
    try {
      const request = ApiRequest(
        method: HttpMethod.get,
        path: ApiEndpoints.userDashboard,
      );
      final response = await _client.request(request);
      final body = response.data as Map<String, dynamic>;
      debugPrint('[UserDashboard] statusCode : ${response.statusCode}');
      debugPrint('[UserDashboard] headers    : ${response.requestOptions.headers}');
      debugPrint('[UserDashboard] response   : $body');
      final data = body['data'];
      final Map<String, dynamic> dataMap = data is List
          ? data.first as Map<String, dynamic>
          : data as Map<String, dynamic>;
      final dto = UserDashboardResponse.fromJson(dataMap);
      return Success(dto.toDomain());
    } on NetworkError catch (error) {
      return Failure(error);
    }
  }
}
