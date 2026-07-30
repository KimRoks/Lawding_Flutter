import 'package:flutter/foundation.dart';

import '../../domain/core/result.dart';
import '../../domain/entities/leave_dashboard.dart';
import '../../domain/repositories/leave_dashboard_repository.dart';
import '../network/api_endpoints.dart';
import '../network/api_request.dart';
import '../network/dio_client.dart';
import '../network/http_methods.dart';
import '../network/network_error.dart';
import 'leave_dashboard_response.dart';

class LeaveDashboardRepositoryImpl implements LeaveDashboardRepository {
  final DioClient _client;

  LeaveDashboardRepositoryImpl(this._client);

  @override
  Future<Result<LeaveDashboard, NetworkError>> get() async {
    try {
      const request = ApiRequest(
        method: HttpMethod.get,
        path: ApiEndpoints.leaveDashboard,
      );
      final response = await _client.request(request);
      final body = response.data as Map<String, dynamic>;
      final dto = LeaveDashboardResponse.fromJson(
        body['data'] as Map<String, dynamic>,
      );
      debugPrint('[LeaveDashboard] remainingLeaveMinutes : ${dto.remainingLeaveMinutes}');
      debugPrint('[LeaveDashboard] avgDailyWorkHours     : ${dto.avgDailyWorkHours}');
      debugPrint('[LeaveDashboard] totalLeaveMinutes     : ${dto.totalLeaveMinutes}');
      debugPrint('[LeaveDashboard] nextLeaveAccrualDate  : ${dto.nextLeaveAccrualDate}');
      debugPrint('[LeaveDashboard] expiringLeaveMinutes  : ${dto.expiringLeaveMinutes}');
      debugPrint('[LeaveDashboard] leavePeriodStartDate  : ${dto.leavePeriodStartDate}');
      debugPrint('[LeaveDashboard] leavePeriodEndDate    : ${dto.leavePeriodEndDate}');
      debugPrint('[LeaveDashboard] recentLeaveUsages     : ${dto.recentLeaveUsages.length}건');
      for (final u in dto.recentLeaveUsages) {
        debugPrint('[LeaveDashboard]   - ${u.startDatetime} ~ ${u.endDatetime} (${u.usedLeaveMinutes}분)');
      }
      return Success(dto.toDomain());
    } on NetworkError catch (error) {
      return Failure(error);
    }
  }
}
