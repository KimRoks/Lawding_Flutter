import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/network/dio_client.dart';
import 'package:lawding_flutter/data/network/network_error.dart';
import 'package:lawding_flutter/data/user/user_repository_impl.dart';
import 'package:lawding_flutter/domain/core/result.dart';

import '../../helpers/mock_dio_helper.dart';

const path = '/v1/users/leave-yearly-balance/remaining-minutes';

void main() {
  group('UserRepository updateRemainingLeaveMinutes Tests', () {
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

    test('수정 성공 - 200 응답', () async {
      mockDioHelper.mockPatch(
        path: path,
        responseData: {'status': 'success', 'message': 'success'},
      );

      final result = await repository.updateRemainingLeaveMinutes(
        remainingLeaveMinutes: 4320,
      );

      expect(result, isA<Success<void, NetworkError>>());
    });

    test('수정 성공 - 0분 (연차 소진)', () async {
      mockDioHelper.mockPatch(
        path: path,
        responseData: {'status': 'success', 'message': 'success'},
      );

      final result = await repository.updateRemainingLeaveMinutes(
        remainingLeaveMinutes: 0,
      );

      expect(result, isA<Success<void, NetworkError>>());
    });

    // ─── 실패 케이스 ─────────────────────────────────────────────────────────

    test('수정 실패 - 인증 에러 (401)', () async {
      mockDioHelper.mockError(
        path: path,
        method: 'PATCH',
        statusCode: 401,
        errorMessage: 'Unauthorized',
      );

      final result = await repository.updateRemainingLeaveMinutes(
        remainingLeaveMinutes: 4320,
      );

      expect(result, isA<Failure<void, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with UnauthorizedError'),
        onFailure: (error) => expect(error, isA<UnauthorizedError>()),
      );
    });

    test('수정 실패 - 서버 에러 (500)', () async {
      mockDioHelper.mockError(
        path: path,
        method: 'PATCH',
        statusCode: 500,
        errorMessage: 'Internal Server Error',
      );

      final result = await repository.updateRemainingLeaveMinutes(
        remainingLeaveMinutes: 4320,
      );

      expect(result, isA<Failure<void, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with ServerError'),
        onFailure: (error) {
          expect(error, isA<ServerError>());
          expect((error as ServerError).statusCode, 500);
        },
      );
    });

    test('수정 실패 - 타임아웃', () async {
      mockDioHelper.mockTimeout(path: path, method: 'PATCH');

      final result = await repository.updateRemainingLeaveMinutes(
        remainingLeaveMinutes: 4320,
      );

      expect(result, isA<Failure<void, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with TimeoutError'),
        onFailure: (error) => expect(error, isA<TimeoutError>()),
      );
    });
  });
}
