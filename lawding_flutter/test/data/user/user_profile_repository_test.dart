import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/network/dio_client.dart';
import 'package:lawding_flutter/data/network/network_error.dart';
import 'package:lawding_flutter/data/user/user_repository_impl.dart';
import 'package:lawding_flutter/domain/core/result.dart';
import 'package:lawding_flutter/domain/entities/user_profile.dart';

import '../../helpers/mock_dio_helper.dart';

const path = '/v1/users/me/profile';

Map<String, dynamic> _mockSuccess({
  bool onboardingCompleted = true,
  bool deleted = false,
}) {
  return {
    'status': 'success',
    'message': 'success',
    'data': {
      'id': 2,
      'username': '김재윤',
      'email': 'jaeyun1723@naver.com',
      'provider': 'kakao',
      'nickname': '홍길동',
      'onboardingCompleted': onboardingCompleted,
      'deleted': deleted,
    },
    'timestamp': '2026-07-05T15:44:33.027077723+09:00',
  };
}

void main() {
  group('UserRepository getProfile Tests', () {
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

    test('조회 성공 - 온보딩 완료 유저', () async {
      mockDioHelper.mockGet(
        path: path,
        responseData: _mockSuccess(),
      );

      final result = await repository.getProfile();

      expect(result, isA<Success<UserProfile, NetworkError>>());
      result.fold(
        onSuccess: (profile) {
          expect(profile.id, 2);
          expect(profile.username, '김재윤');
          expect(profile.email, 'jaeyun1723@naver.com');
          expect(profile.provider, 'kakao');
          expect(profile.nickname, '홍길동');
          expect(profile.onboardingCompleted, true);
          expect(profile.deleted, false);
        },
        onFailure: (error) => fail('Should not fail: $error'),
      );
    });

    test('조회 성공 - 온보딩 미완료 유저 (onboardingCompleted: false)', () async {
      mockDioHelper.mockGet(
        path: path,
        responseData: _mockSuccess(onboardingCompleted: false),
      );

      final result = await repository.getProfile();

      expect(result, isA<Success<UserProfile, NetworkError>>());
      result.fold(
        onSuccess: (profile) => expect(profile.onboardingCompleted, false),
        onFailure: (error) => fail('Should not fail: $error'),
      );
    });

    test('조회 성공 - 탈퇴 유저 (deleted: true)', () async {
      mockDioHelper.mockGet(
        path: path,
        responseData: _mockSuccess(deleted: true),
      );

      final result = await repository.getProfile();

      expect(result, isA<Success<UserProfile, NetworkError>>());
      result.fold(
        onSuccess: (profile) => expect(profile.deleted, true),
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

      final result = await repository.getProfile();

      expect(result, isA<Failure<UserProfile, NetworkError>>());
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

      final result = await repository.getProfile();

      expect(result, isA<Failure<UserProfile, NetworkError>>());
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

      final result = await repository.getProfile();

      expect(result, isA<Failure<UserProfile, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with TimeoutError'),
        onFailure: (error) => expect(error, isA<TimeoutError>()),
      );
    });
  });
}
