import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/network/dio_client.dart';
import 'package:lawding_flutter/data/network/network_error.dart';
import 'package:lawding_flutter/data/user/user_repository_impl.dart';
import 'package:lawding_flutter/domain/core/result.dart';
import 'package:lawding_flutter/domain/entities/user_me.dart';

import '../../helpers/mock_dio_helper.dart';

const path = '/v1/users/me';

Map<String, dynamic> _mockSuccess({
  bool onboardingCompleted = true,
  int leaveAccrualBasis = 1,
  int? fiscalYearBaseMonth,
}) {
  return {
    'status': 'success',
    'message': 'success',
    'data': {
      'user': {
        'id': 2,
        'username': '김재윤',
        'email': 'jaeyun1723@naver.com',
        'provider': 'kakao',
        'nickname': '홍길동',
        'onboardingCompleted': onboardingCompleted,
        'deleted': false,
      },
      'leavePolicy': {
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
      'leaveBalance': {
        'usedLeaveMinutes': 480,
        'remainingLeaveMinutes': 6240,
        'totalLeaveMinutes': 6720,
        'avgDailyWorkHours': 8.0,
      },
    },
    'timestamp': '2026-07-10T18:17:20.292063369+09:00',
  };
}

void main() {
  group('UserRepository getMe Tests', () {
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

    test('조회 성공 - user 필드 검증', () async {
      mockDioHelper.mockGet(path: path, responseData: _mockSuccess());

      final result = await repository.getMe();

      expect(result, isA<Success<UserMe, NetworkError>>());
      result.fold(
        onSuccess: (me) {
          expect(me.user.id, 2);
          expect(me.user.username, '김재윤');
          expect(me.user.email, 'jaeyun1723@naver.com');
          expect(me.user.provider, 'kakao');
          expect(me.user.nickname, '홍길동');
          expect(me.user.onboardingCompleted, true);
          expect(me.user.deleted, false);
        },
        onFailure: (e) => fail('Should not fail: $e'),
      );
    });

    test('조회 성공 - leavePolicy 필드 검증', () async {
      mockDioHelper.mockGet(path: path, responseData: _mockSuccess());

      final result = await repository.getMe();

      result.fold(
        onSuccess: (me) {
          expect(me.leavePolicy.userId, 2);
          expect(me.leavePolicy.leaveAccrualBasis, 1);
          expect(me.leavePolicy.hireDate, '2024-05-08');
          expect(me.leavePolicy.fiscalYearBaseMonth, isNull);
          expect(me.leavePolicy.companySize, 30);
          expect(me.leavePolicy.workPattern.length, 5);
          expect(me.leavePolicy.workPattern['MONDAY']?.start, '09:00:00');
          expect(me.leavePolicy.workPattern['MONDAY']?.end, '18:00:00');
          expect(me.leavePolicy.breakTimePattern['MONDAY']?.start, '12:00:00');
          expect(me.leavePolicy.breakTimePattern['MONDAY']?.end, '13:00:00');
        },
        onFailure: (e) => fail('Should not fail: $e'),
      );
    });

    test('조회 성공 - leaveBalance 필드 및 파생값 검증', () async {
      mockDioHelper.mockGet(path: path, responseData: _mockSuccess());

      final result = await repository.getMe();

      result.fold(
        onSuccess: (me) {
          expect(me.leaveBalance.usedLeaveMinutes, 480);
          expect(me.leaveBalance.remainingLeaveMinutes, 6240);
          expect(me.leaveBalance.totalLeaveMinutes, 6720);
          expect(me.leaveBalance.avgDailyWorkHours, 8.0);
          expect(me.leaveBalance.remainingLeaveHours, 104.0);
          expect(me.leaveBalance.remainingLeaveDays, 13.0);
        },
        onFailure: (e) => fail('Should not fail: $e'),
      );
    });

    test('조회 성공 - 온보딩 미완료 유저', () async {
      mockDioHelper.mockGet(
        path: path,
        responseData: _mockSuccess(onboardingCompleted: false),
      );

      final result = await repository.getMe();

      result.fold(
        onSuccess: (me) => expect(me.user.onboardingCompleted, false),
        onFailure: (e) => fail('Should not fail: $e'),
      );
    });

    test(
      '조회 성공 - 회계연도 기준 (leaveAccrualBasis: 2, fiscalYearBaseMonth: 3)',
      () async {
        mockDioHelper.mockGet(
          path: path,
          responseData: _mockSuccess(
            leaveAccrualBasis: 2,
            fiscalYearBaseMonth: 3,
          ),
        );

        final result = await repository.getMe();

        result.fold(
          onSuccess: (me) {
            expect(me.leavePolicy.leaveAccrualBasis, 2);
            expect(me.leavePolicy.fiscalYearBaseMonth, 3);
          },
          onFailure: (e) => fail('Should not fail: $e'),
        );
      },
    );

    // ─── 실패 케이스 ─────────────────────────────────────────────────────────

    test('조회 실패 - 서버 에러 (500)', () async {
      mockDioHelper.mockError(
        path: path,
        method: 'GET',
        statusCode: 500,
        errorMessage: 'Internal Server Error',
      );

      final result = await repository.getMe();

      expect(result, isA<Failure<UserMe, NetworkError>>());
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

      final result = await repository.getMe();

      expect(result, isA<Failure<UserMe, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with UnauthorizedError'),
        onFailure: (error) => expect(error, isA<UnauthorizedError>()),
      );
    });

    test('조회 실패 - 타임아웃', () async {
      mockDioHelper.mockTimeout(path: path, method: 'GET');

      final result = await repository.getMe();

      expect(result, isA<Failure<UserMe, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with TimeoutError'),
        onFailure: (error) => expect(error, isA<TimeoutError>()),
      );
    });
  });
}
