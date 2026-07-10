import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/leave_policy/leave_policy_repository_impl.dart';
import 'package:lawding_flutter/data/network/dio_client.dart';
import 'package:lawding_flutter/data/network/network_error.dart';
import 'package:lawding_flutter/domain/core/result.dart';

import '../../helpers/mock_dio_helper.dart';

void main() {
  group('LeavePolicyRepository Delete Tests', () {
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

    test('삭제 성공 - 200', () async {
      mockDioHelper.mockDelete(
        path: path,
        responseData: {'success': true},
        statusCode: 200,
      );

      final result = await repository.delete();

      expect(result, isA<Success<void, NetworkError>>());
    });

    // ─── 실패 케이스 ─────────────────────────────────────────────────────────

    test('삭제 실패 - 서버 에러 (500)', () async {
      mockDioHelper.mockError(
        path: path,
        method: 'DELETE',
        statusCode: 500,
        errorMessage: 'Internal Server Error',
      );

      final result = await repository.delete();

      expect(result, isA<Failure<void, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with ServerError'),
        onFailure: (error) {
          expect(error, isA<ServerError>());
          expect((error as ServerError).statusCode, 500);
        },
      );
    });

    test('삭제 실패 - 인증 에러 (401)', () async {
      mockDioHelper.mockError(
        path: path,
        method: 'DELETE',
        statusCode: 401,
        errorMessage: 'Unauthorized',
      );

      final result = await repository.delete();

      expect(result, isA<Failure<void, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with UnauthorizedError'),
        onFailure: (error) => expect(error, isA<UnauthorizedError>()),
      );
    });

    test('삭제 실패 - 타임아웃', () async {
      mockDioHelper.mockTimeout(
        path: path,
        method: 'DELETE',
      );

      final result = await repository.delete();

      expect(result, isA<Failure<void, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail with TimeoutError'),
        onFailure: (error) => expect(error, isA<TimeoutError>()),
      );
    });
  });
}
