import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/auth_repository.dart';
import 'api_endpoints.dart';
import 'api_request.dart';
import 'http_methods.dart';
import 'network_error.dart';

class DioClient {
  final Dio _dio;

  static String get _platformString =>
      defaultTargetPlatform == TargetPlatform.android ? 'android' : 'ios';

  DioClient({
    required String baseUrl,
    AuthRepository? authRepository,
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
    if (dio != null) {
      _dio.options.baseUrl = baseUrl;
      _dio.options.headers.addAll({
        'X-Platform': _platformString,
        'X-Test': isTestMode.toString(),
      });
    }

    if (authRepository != null) {
      _dio.interceptors.add(_AuthInterceptor(_dio, authRepository));
    }
  }

  Future<Response<dynamic>> request(ApiRequest request) async {
    final queryString = request.queryParameters?.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    final fullUrl =
        '${_dio.options.baseUrl}${request.path}'
        '${queryString != null ? '?$queryString' : ''}';
    debugPrint('[Network] ${request.method.name.toUpperCase()} $fullUrl');
    debugPrint('[Network] headers: ${_dio.options.headers}');
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

        case HttpMethod.put:
          return await _dio.put(
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
        final rawData = error.response?.data;
        debugPrint('[Network Error] statusCode : $statusCode');
        debugPrint('[Network Error] data type  : ${rawData.runtimeType}');
        debugPrint('[Network Error] data       : $rawData');

        final message = rawData is Map
            ? rawData['message']?.toString() ?? 'Server error'
            : rawData?.toString() ?? 'Server error';

        if (statusCode == 401) {
          return const UnauthorizedError();
        }

        return ServerError(message: message, statusCode: statusCode);

      default:
        return const UnknownNetworkError();
    }
  }
}

// ============================================================================
// Auth Interceptor — 토큰 주입 + 401 시 refreshToken으로 재시도
// ============================================================================

class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  final AuthRepository _authRepository;

  _AuthInterceptor(this._dio, this._authRepository);

  /// 모든 요청에 accessToken 주입
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _authRepository.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  /// 401 응답 시 refreshToken으로 토큰 갱신 후 원본 요청 재시도
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // reissue 요청 자체가 401을 반환한 경우: 무한 재시도 방지
    if (err.requestOptions.path == ApiEndpoints.reissue) {
      await _authRepository.clearTokens();
      return handler.next(err);
    }

    final refreshToken = await _authRepository.getRefreshToken();
    if (refreshToken == null) {
      await _authRepository.clearTokens();
      return handler.next(err);
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.reissue,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      final newAccessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;

      await _authRepository.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // 원본 요청 헤더에 새 토큰 적용 후 재시도
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await _dio.fetch(err.requestOptions);
      return handler.resolve(retryResponse);
    } catch (_) {
      // 갱신 실패 시 토큰 삭제 (강제 로그아웃)
      await _authRepository.clearTokens();
      return handler.next(err);
    }
  }
}
