import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_request.dart';
import 'http_methods.dart';
import 'network_error.dart';

class DioClient {
  final Dio _dio;

  static String get _platformString =>
      defaultTargetPlatform == TargetPlatform.android ? 'android' : 'ios';

  DioClient({
    required String baseUrl,
    bool isTestMode = kDebugMode,
    Dio? dio,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: const Duration(seconds: 30),
               receiveTimeout: const Duration(seconds: 30),
               headers: {
                 'Content-Type': 'application/json',
                 'Accept': 'application/json',
                 'X-Platform': _platformString,
                 'X-Test': isTestMode.toString(),
               },
             ),
           ) {
    // 외부에서 dio를 주입받은 경우에도 헤더 설정
    if (dio != null) {
      _dio.options.baseUrl = baseUrl;
      _dio.options.headers.addAll({
        'X-Platform': _platformString,
        'X-Test': isTestMode.toString(),
      });
    }
  }

  Future<Response<dynamic>> request(ApiRequest request) async {
    try {
      switch (request.method) {
        case HttpMethod.get:
          return await _dio.get(
            request.path,
            queryParameters: request.queryParameters,
            options: Options(headers: request.headers),
          );

        case HttpMethod.post:
          return await _dio.post(
            request.path,
            data: request.body,
            queryParameters: request.queryParameters,
            options: Options(headers: request.headers),
          );

        case HttpMethod.patch:
          return await _dio.patch(
            request.path,
            data: request.body,
            queryParameters: request.queryParameters,
            options: Options(headers: request.headers),
          );

        case HttpMethod.delete:
          return await _dio.delete(
            request.path,
            data: request.body,
            queryParameters: request.queryParameters,
            options: Options(headers: request.headers),
          );
      }
    } on DioException catch (error) {
      throw _mapDioError(error);
    } catch (_) {
      throw const UnknownNetworkError();
    }
  }

  NetworkError _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutError();

      case DioExceptionType.connectionError:
        return const NetworkConnectionError();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data?['message']?.toString() ?? 'Server error';

        if (statusCode == 401) {
          return const UnauthorizedError();
        }

        return ServerError(message: message, statusCode: statusCode);

      default:
        return const UnknownNetworkError();
    }
  }
}
