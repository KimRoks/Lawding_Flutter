import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/leave_dashboard/leave_dashboard_repository_impl.dart';
import 'package:lawding_flutter/data/network/dio_client.dart';
import 'package:lawding_flutter/data/network/network_error.dart';
import 'package:lawding_flutter/domain/core/result.dart';
import 'package:lawding_flutter/domain/entities/leave_dashboard.dart';

import '../../helpers/mock_dio_helper.dart';

const path = '/v1/dashboard/leave';

Map<String, dynamic> _mockSuccess({bool isFinalized = false}) {
  return {
    'status': 'success',
    'message': 'success',
    'data': {
      'id': 2,
      'userId': 2,
      'startDate': '2026-05-08',
      'endDate': '2027-05-07',
      'weeklyWorkingDays': 5,
      'avgDailyWorkHours': 8.00,
      'totalLeaveMinutes': 7200,
      'usedLeaveMinutes': 960,
      'remainingLeaveMinutes': 6240,
      'isFinalized': isFinalized,
    },
    'timestamp': '2026-07-05T16:18:34.032293578+09:00',
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

    test('조회 성공 - 연차 사용 기간 진행 중 (isFinalized: false)', () async {
      mockDioHelper.mockGet(
        path: path,
        responseData: _mockSuccess(),
      );

      final result = await repository.get();

      expect(result, isA<Success<LeaveDashboard, NetworkError>>());
      result.fold(
        onSuccess: (dashboard) {
          expect(dashboard.id, 2);
          expect(dashboard.userId, 2);
          expect(dashboard.startDate, '2026-05-08');
          expect(dashboard.endDate, '2027-05-07');
          expect(dashboard.weeklyWorkingDays, 5);
          expect(dashboard.avgDailyWorkHours, 8.0);
          expect(dashboard.totalLeaveMinutes, 7200);
          expect(dashboard.usedLeaveMinutes, 960);
          expect(dashboard.remainingLeaveMinutes, 6240);
          expect(dashboard.isFinalized, false);
        },
        onFailure: (error) => fail('Should not fail: $error'),
      );
    });

    test('조회 성공 - 연차 사용 기간 종료 (isFinalized: true)', () async {
      mockDioHelper.mockGet(
        path: path,
        responseData: _mockSuccess(isFinalized: true),
      );

      final result = await repository.get();

      expect(result, isA<Success<LeaveDashboard, NetworkError>>());
      result.fold(
        onSuccess: (dashboard) => expect(dashboard.isFinalized, true),
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
