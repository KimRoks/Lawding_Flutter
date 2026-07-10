import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/leave_policy/leave_policy_repository_impl.dart';
import 'package:lawding_flutter/data/network/dio_client.dart';
import 'package:lawding_flutter/data/network/network_error.dart';
import 'package:lawding_flutter/domain/core/result.dart';
import 'package:lawding_flutter/domain/entities/leave_policy.dart';

import '../../helpers/mock_dio_helper.dart';

const path = '/v1/users/leave-policy';

Map<String, dynamic> _mockSuccess({int leaveAccrualBasis = 1, int? fiscalYearBaseMonth}) {
  return {
    'status': 'success',
    'message': 'success',
    'data': {
      'userId': 2,
      'acceptedAt': '2026-07-05T15:35:56.04926',
      'leaveAccrualBasis': leaveAccrualBasis,
      'hireDate': '2024-05-08',
      'fiscalYearBaseMonth': fiscalYearBaseMonth,
      'companySize': 30,
      'workPattern': {
        'MONDAY': {'start': '09:00:00', 'end': '18:00:00'},
        'TUESDAY': {'start': '09:00:00', 'end': '18:00:00'},
        'WEDNESDAY': {'start': '09:00:00', 'end': '18:00:00'},
        'THURSDAY': {'start': '09:00:00', 'end': '18:00:00'},
        'FRIDAY': {'start': '09:00:00', 'end': '18:00:00'},
      },
      'breakTimePattern': {
        'MONDAY': {'start': '12:00:00', 'end': '13:00:00'},
        'TUESDAY': {'start': '12:00:00', 'end': '13:00:00'},
        'WEDNESDAY': {'start': '12:00:00', 'end': '13:00:00'},
        'THURSDAY': {'start': '12:00:00', 'end': '13:00:00'},
        'FRIDAY': {'start': '12:00:00', 'end': '13:00:00'},
      },
    },
    'timestamp': '2026-07-05T15:59:23.434311801+09:00',
  };
}

void main() {
  group('LeavePolicyRepository Get Tests', () {
    late MockDioHelper mockDioHelper;
    late DioClient dioClient;
    late LeavePolicyRepositoryImpl repository;

    setUp(() {
      mockDioHelper = MockDioHelper(baseUrl: 'https://api.test.com');
      dioClient = DioClient(
        baseUrl: 'https://api.test.com',
        dio: mockDioHelper.dio,
      );
      repository = LeavePolicyRepositoryImpl(dioClient);
    });

    // ─── 성공 케이스 ─────────────────────────────────────────────────────────

    test('조회 성공 - 입사일 기준 (leaveAccrualBasis: 1, fiscalYearBaseMonth: null)', () async {
      mockDioHelper.mockGet(
        path: path,
        responseData: _mockSuccess(),
      );

      final result = await repository.get();

      expect(result, isA<Success<LeavePolicy, NetworkError>>());
      result.fold(
        onSuccess: (policy) {
          expect(policy.userId, 2);
          expect(policy.leaveAccrualBasis, 1);
          expect(policy.hireDate, '2024-05-08');
          expect(policy.fiscalYearBaseMonth, isNull);
          expect(policy.companySize, 30);
          expect(policy.workPattern.length, 5);
          expect(policy.workPattern['MONDAY']?.start, '09:00:00');
          expect(policy.workPattern['MONDAY']?.end, '18:00:00');
          expect(policy.breakTimePattern['MONDAY']?.start, '12:00:00');
          expect(policy.breakTimePattern['MONDAY']?.end, '13:00:00');
        },
        onFailure: (error) => fail('Should not fail: $error'),
      );
    });

    test('조회 성공 - 회계연도 기준 (leaveAccrualBasis: 2, fiscalYearBaseMonth: 3)', () async {
      mockDioHelper.mockGet(
        path: path,
        responseData: _mockSuccess(leaveAccrualBasis: 2, fiscalYearBaseMonth: 3),
      );

      final result = await repository.get();

      expect(result, isA<Success<LeavePolicy, NetworkError>>());
      result.fold(
        onSuccess: (policy) {
          expect(policy.leaveAccrualBasis, 2);
          expect(policy.fiscalYearBaseMonth, 3);
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

      final result = await repository.get();

      expect(result, isA<Failure<LeavePolicy, NetworkError>>());
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

      expect(result, isA<Failure<LeavePolicy, NetworkError>>());
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

      expect(result, isA<Failure<LeavePolicy, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with TimeoutError'),
        onFailure: (error) => expect(error, isA<TimeoutError>()),
      );
    });
  });
}
