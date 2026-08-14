import 'dart:async';

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
    Dio? reissueDio, // 테스트 시 주입 가능
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
      _dio.interceptors.add(
        _AuthInterceptor(_dio, authRepository, reissueDio: reissueDio),
      );
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
  // reissue 전용 Dio — 인터셉터 없이 직접 호출해 무한루프 방지
  late final Dio _reissueDio;

  // 동시 401 처리 시 단일 refresh 보장
  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  _AuthInterceptor(this._dio, this._authRepository, {Dio? reissueDio})
      : _reissueDio = reissueDio ??
            Dio(
              BaseOptions(
                baseUrl: _dio.options.baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

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

  /// 401 응답 시 refreshToken으로 토큰 갱신 후 원본 요청 재시도.
  /// 동시 401이 여러 개 와도 refresh는 한 번만 수행 (single-flight).
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // 이미 refresh 중이면 완료 대기 후 새 토큰으로 재시도
    if (_isRefreshing) {
      final newToken = await _refreshCompleter!.future;
      if (newToken != null) {
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        try {
          final retryResponse = await _dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
      return handler.next(err);
    }

    _isRefreshing = true;
    final completer = Completer<String?>();
    _refreshCompleter = completer;

    debugPrint('[Auth] 401 감지 → path: ${err.requestOptions.path}');

    final refreshToken = await _authRepository.getRefreshToken();
    if (refreshToken == null) {
      debugPrint('[Auth] refreshToken 없음 → 토큰 삭제 → 로그아웃');
      await _authRepository.clearTokens();
      completer.complete(null);
      _isRefreshing = false;
      _refreshCompleter = null;
      return handler.next(err);
    }

    debugPrint('[Auth] refreshToken 존재 → reissue 시도');

    // reissue 전용 try-catch: 여기서 나오는 예외만 토큰 만료 처리
    String? newAccessToken;
    try {
      // 인터셉터 없는 별도 Dio로 reissue 호출 → 무한루프 방지
      final response = await _reissueDio.post(
        ApiEndpoints.reissue,
        data: {'refreshToken': refreshToken},
      );

      final body = response.data;
      // 응답 구조: { data: { accessToken, refreshToken } } 또는 flat
      final payload = body is Map && body['data'] is Map
          ? body['data'] as Map
          : body as Map;

      newAccessToken = payload['accessToken'] as String;
      final newRefreshToken = payload['refreshToken'] as String;

      await _authRepository.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      debugPrint('[Auth] 토큰 갱신 성공 → 원본 요청 재시도: ${err.requestOptions.path}');
      completer.complete(newAccessToken);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // 400: 서버가 refreshToken 만료/무효 시 반환하는 코드 포함
      if (status == 400 || status == 401 || status == 403) {
        debugPrint('[Auth] reissue $status → refreshToken 만료 → 토큰 삭제 → 로그아웃');
        await _authRepository.clearTokens();
        _authRepository.notifySessionExpired();
      } else {
        // 네트워크 순단·타임아웃 등 일시적 오류 → 토큰 유지
        debugPrint('[Auth] reissue 일시적 실패 (status: $status, type: ${e.type}) → 토큰 유지');
      }
      completer.complete(null);
      return handler.next(err);
    } catch (e) {
      debugPrint('[Auth] reissue 예외 (${e.runtimeType}: $e) → 토큰 유지');
      completer.complete(null);
      return handler.next(err);
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }

    // 원본 요청 retry — reissue try-catch 밖에서 실행하여 retry 오류가
    // reissue 오류 핸들러를 트리거하지 않도록 분리
    err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
    try {
      final retryResponse = await _dio.fetch(err.requestOptions);
      return handler.resolve(retryResponse);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}
