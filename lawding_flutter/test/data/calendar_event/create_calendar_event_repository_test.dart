import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/calendar_event/calendar_event_repository_impl.dart';
import 'package:lawding_flutter/domain/entities/calendar_event_request.dart';
import 'package:lawding_flutter/data/network/dio_client.dart';
import 'package:lawding_flutter/data/network/network_error.dart';
import 'package:lawding_flutter/domain/core/result.dart';

import '../../helpers/mock_dio_helper.dart';

const _path = '/v1/calendar-events';

CalendarEventRequest _makeRequest({
  String title = '회의',
  String description = '주간 회의',
  DateTime? startDatetime,
  DateTime? endDatetime,
  int usedLeaveMinutes = 0,
  bool isAllDay = false,
  bool isLeaveEvent = false,
}) {
  return CalendarEventRequest(
    title: title,
    description: description,
    startDatetime: startDatetime ?? DateTime(2026, 6, 22, 10, 0),
    endDatetime: endDatetime ?? DateTime(2026, 6, 22, 11, 0),
    usedLeaveMinutes: usedLeaveMinutes,
    isAllDay: isAllDay,
    isLeaveEvent: isLeaveEvent,
  );
}

void main() {
  group('CalendarEventRepository - createCalendarEvent', () {
    late MockDioHelper mockDioHelper;
    late DioClient dioClient;
    late CalendarEventRepositoryImpl repository;

    setUp(() {
      mockDioHelper = MockDioHelper(baseUrl: 'https://api.test.com');
      dioClient = DioClient(
        baseUrl: 'https://api.test.com',
        dio: mockDioHelper.dio,
      );
      repository = CalendarEventRepositoryImpl(dioClient);
    });

    // ─── 성공 케이스 ─────────────────────────────────────────────────────────

    test('생성 성공 - 일반 이벤트 (isAllDay: false, isLeaveEvent: false)', () async {
      mockDioHelper.mockPost(
        path: _path,
        responseData: {'status': 'SUCCESS'},
        statusCode: 201,
      );

      final result = await repository.createCalendarEvent(
        request: _makeRequest(),
      );

      expect(result, isA<Success<void, NetworkError>>());
    });

    test('생성 성공 - 종일 이벤트 (isAllDay: true)', () async {
      mockDioHelper.mockPost(
        path: _path,
        responseData: {'status': 'SUCCESS'},
        statusCode: 201,
      );

      final result = await repository.createCalendarEvent(
        request: _makeRequest(
          isAllDay: true,
          startDatetime: DateTime(2026, 6, 22, 0, 0),
          endDatetime: DateTime(2026, 6, 22, 23, 59),
        ),
      );

      expect(result, isA<Success<void, NetworkError>>());
    });

    test('생성 성공 - 연차 이벤트 (isLeaveEvent: true, usedLeaveMinutes: 480)', () async {
      mockDioHelper.mockPost(
        path: _path,
        responseData: {'status': 'SUCCESS'},
        statusCode: 201,
      );

      final result = await repository.createCalendarEvent(
        request: _makeRequest(isLeaveEvent: true, usedLeaveMinutes: 480),
      );

      expect(result, isA<Success<void, NetworkError>>());
    });

    test('생성 성공 - title/description 없이 최소 필드만', () async {
      mockDioHelper.mockPost(
        path: _path,
        responseData: {'status': 'SUCCESS'},
        statusCode: 201,
      );

      final result = await repository.createCalendarEvent(
        request: CalendarEventRequest(
          startDatetime: DateTime(2026, 6, 22, 10, 0),
          endDatetime: DateTime(2026, 6, 22, 11, 0),
          isAllDay: false,
          isLeaveEvent: false,
        ),
      );

      expect(result, isA<Success<void, NetworkError>>());
    });

    test('생성 성공 - data 필드 없는 응답 (null)', () async {
      mockDioHelper.mockPost(
        path: _path,
        responseData: {'status': 'SUCCESS', 'data': null},
        statusCode: 201,
      );

      final result = await repository.createCalendarEvent(
        request: _makeRequest(),
      );

      expect(result, isA<Success<void, NetworkError>>());
    });

    test('생성 성공 - 200 응답', () async {
      mockDioHelper.mockPost(
        path: _path,
        responseData: {'status': 'SUCCESS'},
        statusCode: 200,
      );

      final result = await repository.createCalendarEvent(
        request: _makeRequest(),
      );

      expect(result, isA<Success<void, NetworkError>>());
    });

    // ─── 실패 케이스 ─────────────────────────────────────────────────────────

    test('생성 실패 - 인증 에러 (401)', () async {
      mockDioHelper.mockError(
        path: _path,
        method: 'POST',
        statusCode: 401,
        errorMessage: 'Unauthorized',
      );

      final result = await repository.createCalendarEvent(
        request: _makeRequest(),
      );

      expect(result, isA<Failure<void, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail'),
        onFailure: (error) => expect(error, isA<UnauthorizedError>()),
      );
    });

    test('생성 실패 - 잘못된 요청 (400)', () async {
      mockDioHelper.mockError(
        path: _path,
        method: 'POST',
        statusCode: 400,
        errorMessage: 'Bad Request - endDatetime must be after startDatetime',
      );

      final result = await repository.createCalendarEvent(
        request: _makeRequest(),
      );

      expect(result, isA<Failure<void, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail'),
        onFailure: (error) {
          expect(error, isA<ServerError>());
          expect((error as ServerError).statusCode, 400);
        },
      );
    });

    test('생성 실패 - 서버 에러 (500)', () async {
      mockDioHelper.mockError(
        path: _path,
        method: 'POST',
        statusCode: 500,
        errorMessage: 'Internal Server Error',
      );

      final result = await repository.createCalendarEvent(
        request: _makeRequest(),
      );

      expect(result, isA<Failure<void, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail'),
        onFailure: (error) {
          expect(error, isA<ServerError>());
          expect((error as ServerError).statusCode, 500);
        },
      );
    });

    test('생성 실패 - 타임아웃', () async {
      mockDioHelper.mockTimeout(
        path: _path,
        method: 'POST',
      );

      final result = await repository.createCalendarEvent(
        request: _makeRequest(),
      );

      expect(result, isA<Failure<void, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail'),
        onFailure: (error) => expect(error, isA<TimeoutError>()),
      );
    });
  });
}
