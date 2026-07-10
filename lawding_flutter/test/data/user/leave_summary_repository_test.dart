import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/network/dio_client.dart';
import 'package:lawding_flutter/data/network/network_error.dart';
import 'package:lawding_flutter/data/user/user_repository_impl.dart';
import 'package:lawding_flutter/domain/core/result.dart';
import 'package:lawding_flutter/domain/entities/user_dashboard.dart';

import '../../helpers/mock_dio_helper.dart';

const path = '/v1/users/me/leave-summary';

Map<String, dynamic> _mockSuccess() {
  return {
    'status': 'success',
    'message': 'success',
    'data': {
      'nickname': '홍길동',
      'availableLeaveMinutes': 2400,
      'avgDailyWorkHours': 8.0,
    },
    'timestamp': '2026-07-10T18:17:20.292063369+09:00',
  };
}

void main() {
  group('UserRepository getLeaveSummary Tests', () {
    late MockDioHelper mockDioHelper;
    late DioClient dioClient;
    late UserRepositoryImpl repository;

    setUp(() {
      mockDioHelper = MockDioHelper(baseUrl: 'https://api.test.com');
      dioClient = DioClient(
        baseUrl: 'https://api.test.com',
        dio: mockDioHelper.dio,
      );
      repository = UserRepositoryImpl(dioClient);
    });

    // ─── 성공 케이스 ─────────────────────────────────────────────────────────

    test('조회 성공 - 남은 연차 데이터 검증', () async {
      mockDioHelper.mockGet(
        path: path,
        responseData: _mockSuccess(),
      );

      final result = await repository.getLeaveSummary();

      expect(result, isA<Success<UserDashboard, NetworkError>>());
      result.fold(
        onSuccess: (summary) {
          expect(summary.nickname, '홍길동');
          expect(summary.availableLeaveMinutes, 2400);
          expect(summary.avgDailyWorkHours, 8.0);
          expect(summary.availableLeaveHours, 40.0);
          expect(summary.availableLeaveDays, 5.0);
        },
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

      final result = await repository.getLeaveSummary();

      expect(result, isA<Failure<UserDashboard, NetworkError>>());
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

      final result = await repository.getLeaveSummary();

      expect(result, isA<Failure<UserDashboard, NetworkError>>());
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

      final result = await repository.getLeaveSummary();

      expect(result, isA<Failure<UserDashboard, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with TimeoutError'),
        onFailure: (error) => expect(error, isA<TimeoutError>()),
      );
    });
  });
}
