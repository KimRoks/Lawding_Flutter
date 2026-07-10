import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/leave_policy/leave_policy_repository_impl.dart';
import 'package:lawding_flutter/data/network/dio_client.dart';
import 'package:lawding_flutter/data/network/network_error.dart';
import 'package:lawding_flutter/domain/core/result.dart';
import 'package:lawding_flutter/domain/entities/leave_policy_request.dart';

import '../../helpers/mock_dio_helper.dart';

LeavePolicyRequest _makeRequest({
  int leaveAccrualBasis = 1,
  int? fiscalYearBaseMonth,
}) {
  return LeavePolicyRequest(
    nickname: '홍길동',
    acceptedTerms: true,
    leaveAccrualBasis: leaveAccrualBasis,
    fiscalYearBaseMonth: fiscalYearBaseMonth,
    hireDate: '2024-05-08',
    workPattern: const {
      'MONDAY': WorkTimeSlot(start: '09:00', end: '18:00'),
      'TUESDAY': WorkTimeSlot(start: '09:00', end: '18:00'),
      'WEDNESDAY': WorkTimeSlot(start: '09:00', end: '18:00'),
      'THURSDAY': WorkTimeSlot(start: '09:00', end: '18:00'),
      'FRIDAY': WorkTimeSlot(start: '09:00', end: '18:00'),
    },
    breakTimePattern: const {
      'MONDAY': WorkTimeSlot(start: '12:00', end: '13:00'),
      'TUESDAY': WorkTimeSlot(start: '12:00', end: '13:00'),
      'WEDNESDAY': WorkTimeSlot(start: '12:00', end: '13:00'),
      'THURSDAY': WorkTimeSlot(start: '12:00', end: '13:00'),
      'FRIDAY': WorkTimeSlot(start: '12:00', end: '13:00'),
    },
    companySize: 30,
    totalLeave: 15,
    usedLeave: 2,
  );
}

void main() {
  group('LeavePolicyRepository Update Tests', () {
    late MockDioHelper mockDioHelper;
    late DioClient dioClient;
    late LeavePolicyRepositoryImpl repository;

    const path = '/v1/users/leave-policy';

    setUp(() {
      mockDioHelper = MockDioHelper(baseUrl: 'https://api.test.com');
      dioClient = DioClient(
        baseUrl: 'https://api.test.com',
        dio: mockDioHelper.dio,
      );
      repository = LeavePolicyRepositoryImpl(dioClient);
    });

    // ─── 성공 케이스 ─────────────────────────────────────────────────────────

    test('수정 성공 - 입사일 기준 (leaveAccrualBasis: 1)', () async {
      mockDioHelper.mockPut(
        path: path,
        responseData: {'success': true},
        statusCode: 200,
      );

      final result = await repository.update(_makeRequest());

      expect(result, isA<Success<void, NetworkError>>());
    });

    test('수정 성공 - 회계연도 기준 (leaveAccrualBasis: 2, fiscalYearBaseMonth 포함)', () async {
      mockDioHelper.mockPut(
        path: path,
        responseData: {'success': true},
        statusCode: 200,
      );

      final result = await repository.update(
        _makeRequest(leaveAccrualBasis: 2, fiscalYearBaseMonth: 3),
      );

      expect(result, isA<Success<void, NetworkError>>());
    });

    // ─── 실패 케이스 ─────────────────────────────────────────────────────────

    test('수정 실패 - 서버 에러 (500)', () async {
      mockDioHelper.mockError(
        path: path,
        method: 'PUT',
        statusCode: 500,
        errorMessage: 'Internal Server Error',
      );

      final result = await repository.update(_makeRequest());

      expect(result, isA<Failure<void, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with ServerError'),
        onFailure: (error) {
          expect(error, isA<ServerError>());
          expect((error as ServerError).statusCode, 500);
        },
      );
    });

    test('수정 실패 - 인증 에러 (401)', () async {
      mockDioHelper.mockError(
        path: path,
        method: 'PUT',
        statusCode: 401,
        errorMessage: 'Unauthorized',
      );

      final result = await repository.update(_makeRequest());

      expect(result, isA<Failure<void, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with UnauthorizedError'),
        onFailure: (error) => expect(error, isA<UnauthorizedError>()),
      );
    });

    test('수정 실패 - 잘못된 요청 (400)', () async {
      mockDioHelper.mockError(
        path: path,
        method: 'PUT',
        statusCode: 400,
        errorMessage: 'Bad Request - Invalid field',
      );

      final result = await repository.update(_makeRequest());

      expect(result, isA<Failure<void, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with ServerError'),
        onFailure: (error) {
          expect(error, isA<ServerError>());
          expect((error as ServerError).statusCode, 400);
        },
      );
    });

    test('수정 실패 - 타임아웃', () async {
      mockDioHelper.mockTimeout(
        path: path,
        method: 'PUT',
      );

      final result = await repository.update(_makeRequest());

      expect(result, isA<Failure<void, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with TimeoutError'),
        onFailure: (error) => expect(error, isA<TimeoutError>()),
      );
    });
  });
}
