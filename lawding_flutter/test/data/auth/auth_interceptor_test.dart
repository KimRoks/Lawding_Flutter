import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/auth/auth_repository_impl.dart';
import 'package:lawding_flutter/data/network/api_request.dart';
import 'package:lawding_flutter/data/network/dio_client.dart';
import 'package:lawding_flutter/data/network/http_methods.dart';
import 'package:lawding_flutter/data/network/network_error.dart';

import '../../helpers/mock_dio_helper.dart';

void main() {
  group('AuthInterceptor Tests', () {
    late MockDioHelper mockDioHelper;
    late AuthRepositoryImpl authRepository;
    // authDioClient — 로그인 필요 API용 (Bearer 토큰 주입 + 401 재시도)
    late DioClient authDioClient;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      mockDioHelper = MockDioHelper(baseUrl: 'https://api.test.com');
      authRepository = AuthRepositoryImpl();
      authDioClient = DioClient(
        baseUrl: 'https://api.test.com',
        authRepository: authRepository,
        dio: mockDioHelper.dio,
      );
    });

    // ========================================================================
    // 토큰 주입
    // ========================================================================

    test('저장된 accessToken이 있을 때 정상 요청 200 응답 수신', () async {
      // Given: accessToken이 저장된 상태
      await authRepository.saveTokens(
        accessToken: 'valid_access_token',
        refreshToken: 'valid_refresh_token',
      );

      // Given: 서버는 200 응답
      mockDioHelper.mockGet(
        path: '/v1/test',
        responseData: {'result': 'ok'},
        statusCode: 200,
      );

      // When: API 요청
      final response = await authDioClient.request(
        const ApiRequest(path: '/v1/test', method: HttpMethod.get),
      );

      // Then: 200 응답 정상 수신
      expect(response.statusCode, 200);
    });

    test('저장된 accessToken이 없어도 요청 자체는 정상 전송됨', () async {
      // Given: 토큰이 없는 초기 상태

      // Given: 서버는 200 응답
      mockDioHelper.mockGet(
        path: '/v1/test',
        responseData: {'result': 'ok'},
        statusCode: 200,
      );

      // When: API 요청
      final response = await authDioClient.request(
        const ApiRequest(path: '/v1/test', method: HttpMethod.get),
      );

      // Then: Authorization 헤더 없이도 요청 전송됨
      expect(response.statusCode, 200);
    });

    // ========================================================================
    // 401 — refreshToken 없을 때
    // ========================================================================

    test('401 응답 시 refreshToken이 없으면 UnauthorizedError 반환', () async {
      // Given: 토큰이 없는 상태 (비로그인)

      // Given: 서버가 401 반환
      mockDioHelper.mockError(
        path: '/v1/test',
        method: 'GET',
        statusCode: 401,
        errorMessage: 'Unauthorized',
      );

      // When / Then: UnauthorizedError throw
      await expectLater(
        () => authDioClient.request(
          const ApiRequest(path: '/v1/test', method: HttpMethod.get),
        ),
        throwsA(isA<UnauthorizedError>()),
      );
    });

    // ========================================================================
    // 401 외 에러 — 재시도 없음
    // ========================================================================

    test('500 에러는 토큰 갱신 없이 ServerError로 즉시 반환', () async {
      // Given: 유효한 토큰이 저장된 상태
      await authRepository.saveTokens(
        accessToken: 'valid_access_token',
        refreshToken: 'valid_refresh_token',
      );

      // Given: 서버가 500 에러 반환
      mockDioHelper.mockError(
        path: '/v1/test',
        method: 'GET',
        statusCode: 500,
        errorMessage: 'Internal Server Error',
      );

      // When / Then: ServerError throw
      await expectLater(
        () => authDioClient.request(
          const ApiRequest(path: '/v1/test', method: HttpMethod.get),
        ),
        throwsA(isA<ServerError>()),
      );

      // Then: 500 에러는 토큰에 영향 없음
      expect(await authRepository.getAccessToken(), 'valid_access_token');
    });

    test('타임아웃 에러는 토큰 갱신 없이 TimeoutError로 즉시 반환', () async {
      // Given: 유효한 토큰이 저장된 상태
      await authRepository.saveTokens(
        accessToken: 'valid_access_token',
        refreshToken: 'valid_refresh_token',
      );

      // Given: 서버 타임아웃
      mockDioHelper.mockTimeout(
        path: '/v1/test',
        method: 'GET',
      );

      // When / Then: TimeoutError throw
      await expectLater(
        () => authDioClient.request(
          const ApiRequest(path: '/v1/test', method: HttpMethod.get),
        ),
        throwsA(isA<TimeoutError>()),
      );

      // Then: 타임아웃은 토큰에 영향 없음
      expect(await authRepository.getAccessToken(), 'valid_access_token');
    });
  });
}
