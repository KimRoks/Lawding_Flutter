import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/leave_dashboard/leave_dashboard_repository_impl.dart';
import 'package:lawding_flutter/data/network/dio_client.dart';
import 'package:lawding_flutter/data/network/network_error.dart';
import 'package:lawding_flutter/domain/core/result.dart';
import 'package:lawding_flutter/domain/entities/leave_dashboard.dart';

import '../../helpers/mock_dio_helper.dart';

const path = '/v1/dashboard/leave';

Map<String, dynamic> _mockSuccess({List<Map<String, dynamic>>? recentLeaveUsages}) {
  return {
    'status': 'success',
    'message': 'success',
    'data': {
      'remainingLeaveMinutes': 6240,
      'avgDailyWorkHours': 8.00,
      'totalLeaveMinutes': 7200,
      'nextLeaveAccrualDate': '2027-07-10',
      'expiringLeaveMinutes': 6240,
      'leavePeriodStartDate': '2026-07-10',
      'leavePeriodEndDate': '2027-07-09',
      'recentLeaveUsages': recentLeaveUsages ?? [
        {
          'startDatetime': '2026-07-25T09:00:00',
          'endDatetime': '2026-07-25T13:00:00',
          'usedLeaveMinutes': 240,
        }
      ],
    },
    'timestamp': '2026-07-10T19:28:41.816417842+09:00',
  };
}

void main() {
  group('LeaveDashboardRepository Tests', () {
    late MockDioHelper mockDioHelper;
    late DioClient dioClient;
    late LeaveDashboardRepositoryImpl repository;

    setUp(() {
      mockDioHelper = MockDioHelper(baseUrl: 'https://api.test.com');
      dioClient = DioClient(
        baseUrl: 'https://api.test.com',
        dio: mockDioHelper.dio,
      );
      repository = LeaveDashboardRepositoryImpl(dioClient);
    });

    // ─── 성공 케이스 ─────────────────────────────────────────────────────────

    test('조회 성공 - 모든 필드 정상 파싱', () async {
      mockDioHelper.mockGet(
        path: path,
        responseData: _mockSuccess(),
      );

      final result = await repository.get();

      expect(result, isA<Success<LeaveDashboard, NetworkError>>());
      result.fold(
        onSuccess: (dashboard) {
          expect(dashboard.remainingLeaveMinutes, 6240);
          expect(dashboard.avgDailyWorkHours, 8.0);
          expect(dashboard.totalLeaveMinutes, 7200);
          expect(dashboard.nextLeaveAccrualDate, '2027-07-10');
          expect(dashboard.expiringLeaveMinutes, 6240);
          expect(dashboard.leavePeriodStartDate, '2026-07-10');
          expect(dashboard.leavePeriodEndDate, '2027-07-09');
          expect(dashboard.recentLeaveUsages.length, 1);
          expect(dashboard.recentLeaveUsages.first.startDatetime, '2026-07-25T09:00:00');
          expect(dashboard.recentLeaveUsages.first.endDatetime, '2026-07-25T13:00:00');
          expect(dashboard.recentLeaveUsages.first.usedLeaveMinutes, 240);
        },
        onFailure: (error) => fail('Should not fail: $error'),
      );
    });

    test('조회 성공 - recentLeaveUsages 빈 배열', () async {
      mockDioHelper.mockGet(
        path: path,
        responseData: _mockSuccess(recentLeaveUsages: []),
      );

      final result = await repository.get();

      expect(result, isA<Success<LeaveDashboard, NetworkError>>());
      result.fold(
        onSuccess: (dashboard) => expect(dashboard.recentLeaveUsages, isEmpty),
        onFailure: (error) => fail('Should not fail: $error'),
      );
    });

    // ─── 실패 케이스 ─────────────────────────────────────────────────────────

    test('조회 실패 - 서버 에러 (500)', () async {
      mockDioHelper.mockError(
        path: path,
        method: 'GET',
        statusCode: 500,
        errorMessage: 'Internal Server Error',
      );

      final result = await repository.get();

      expect(result, isA<Failure<LeaveDashboard, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with ServerError'),
        onFailure: (error) {
          expect(error, isA<ServerError>());
          expect((error as ServerError).statusCode, 500);
        },
      );
    });

    test('조회 실패 - 인증 에러 (401)', () async {
      mockDioHelper.mockError(
        path: path,
        method: 'GET',
        statusCode: 401,
        errorMessage: 'Unauthorized',
      );

      final result = await repository.get();

      expect(result, isA<Failure<LeaveDashboard, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with UnauthorizedError'),
        onFailure: (error) => expect(error, isA<UnauthorizedError>()),
      );
    });

    test('조회 실패 - 타임아웃', () async {
      mockDioHelper.mockTimeout(
        path: path,
        method: 'GET',
      );

      final result = await repository.get();

      expect(result, isA<Failure<LeaveDashboard, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with TimeoutError'),
        onFailure: (error) => expect(error, isA<TimeoutError>()),
      );
    });
  });
}
