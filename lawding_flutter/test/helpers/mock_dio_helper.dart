import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';
import 'package:http_mock_adapter/src/response.dart';

/// 테스트용 Mock Dio 인스턴스를 생성하는 헬퍼 클래스
class MockDioHelper {
  late final Dio dio;
  late final DioAdapter dioAdapter;

  MockDioHelper({String baseUrl = 'https://api.test.com'}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    // 기본 matcher 사용 (headers는 매칭하지 않음)
    dioAdapter = DioAdapter(dio: dio);
  }

  /// GET 요청에 대한 Mock 응답 설정
  void mockGet({
    required String path,
    required Map<String, dynamic> responseData,
    int statusCode = 200,
    Map<String, dynamic>? queryParameters,
  }) {
    dioAdapter.onGet(
      path,
      (server) => server.reply(statusCode, responseData),
      queryParameters: queryParameters,
    );
  }

  /// POST 요청에 대한 Mock 응답 설정
  void mockPost({
    required String path,
    required dynamic responseData,
    int statusCode = 200,
    dynamic requestData,
  }) {
    dioAdapter.onPost(
      path,
      (server) => server.reply(statusCode, responseData),
      data: requestData ?? Matchers.any,
    );
  }

  /// PUT 요청에 대한 Mock 응답 설정
  void mockPut({
    required String path,
    required dynamic responseData,
    int statusCode = 200,
    dynamic requestData,
  }) {
    dioAdapter.onPut(
      path,
      (server) => server.reply(statusCode, responseData),
      data: requestData ?? Matchers.any,
    );
  }

  /// PATCH 요청에 대한 Mock 응답 설정
  void mockPatch({
    required String path,
    required Map<String, dynamic> responseData,
    int statusCode = 200,
    dynamic requestData,
  }) {
    dioAdapter.onPatch(
      path,
      (server) => server.reply(statusCode, responseData),
      data: requestData,
    );
  }

  /// DELETE 요청에 대한 Mock 응답 설정
  void mockDelete({
    required String path,
    required Map<String, dynamic> responseData,
    int statusCode = 200,
  }) {
    dioAdapter.onDelete(
      path,
      (server) => server.reply(statusCode, responseData),
    );
  }

  /// 에러 응답 Mock 설정
  void mockError({
    required String path,
    required String method,
    required int statusCode,
    String? errorMessage,
  }) {
    final errorData = {
      'message': errorMessage ?? 'Error occurred',
      'statusCode': statusCode,
    };

    switch (method.toUpperCase()) {
      case 'GET':
        dioAdapter.onGet(
          path,
          (server) => server.reply(statusCode, errorData),
        );
        break;
      case 'POST':
        dioAdapter.onPost(
          path,
          (server) => server.reply(statusCode, errorData),
          data: Matchers.any,
        );
        break;
      case 'PUT':
        dioAdapter.onPut(
          path,
          (server) => server.reply(statusCode, errorData),
          data: Matchers.any,
        );
        break;
      case 'PATCH':
        dioAdapter.onPatch(
          path,
          (server) => server.reply(statusCode, errorData),
          data: Matchers.any,
        );
        break;
      case 'DELETE':
        dioAdapter.onDelete(
          path,
          (server) => server.reply(statusCode, errorData),
        );
        break;
    }
  }

  /// 동일 경로에 대해 호출 순서별로 다른 응답을 반환 (retry 흐름 테스트용)
  ///
  /// http_mock_adapter는 동일 경로를 여러 번 등록하면 마지막 것만 사용되므로
  /// 상태형 클로저로 단일 핸들러 안에서 응답을 순서대로 전환한다.
  void mockGetSequential({
    required String path,
    required List<(int statusCode, Map<String, dynamic> data)> responses,
  }) {
    int callIndex = 0;
    dioAdapter.onGet(path, (server) {
      (server as RequestHandler).mockResponse = (requestOptions) async {
        final i = callIndex < responses.length ? callIndex : responses.length - 1;
        callIndex++;
        final (statusCode, data) = responses[i];
        return MockResponseBody.from(
          jsonEncode(data),
          statusCode,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          isRedirect: false,
        );
      };
    });
  }

  /// 타임아웃 에러 Mock 설정
  void mockTimeout({
    required String path,
    required String method,
  }) {
    switch (method.toUpperCase()) {
      case 'GET':
        dioAdapter.onGet(
          path,
          (server) => server.throws(
            408,
            DioException(
              requestOptions: RequestOptions(path: path),
              type: DioExceptionType.connectionTimeout,
            ),
          ),
        );
        break;
      case 'POST':
        dioAdapter.onPost(
          path,
          (server) => server.throws(
            408,
            DioException(
              requestOptions: RequestOptions(path: path),
              type: DioExceptionType.connectionTimeout,
            ),
          ),
          data: Matchers.any,
        );
        break;
      case 'PUT':
        dioAdapter.onPut(
          path,
          (server) => server.throws(
            408,
            DioException(
              requestOptions: RequestOptions(path: path),
              type: DioExceptionType.connectionTimeout,
            ),
          ),
          data: Matchers.any,
        );
        break;
      case 'DELETE':
        dioAdapter.onDelete(
          path,
          (server) => server.throws(
            408,
            DioException(
              requestOptions: RequestOptions(path: path),
              type: DioExceptionType.connectionTimeout,
            ),
          ),
        );
        break;
    }
  }
}
