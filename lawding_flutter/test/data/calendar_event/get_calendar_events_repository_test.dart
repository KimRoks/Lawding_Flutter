import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/calendar_event/calendar_event_repository_impl.dart';
import 'package:lawding_flutter/data/network/dio_client.dart';
import 'package:lawding_flutter/data/network/network_error.dart';
import 'package:lawding_flutter/domain/core/result.dart';
import 'package:lawding_flutter/domain/entities/calendar_event.dart';

import '../../helpers/mock_dio_helper.dart';

const _path = '/v1/calendar-events';

Map<String, dynamic> _makeListResponse(List<Map<String, dynamic>> items) => {
      'status': 'SUCCESS',
      'message': '조회 성공',
      'data': items,
      'timestamp': '2026-07-01T00:00:00',
    };

Map<String, dynamic> _makeEventItem({
  int id = 1,
  String title = '회의',
  String description = '주간 회의',
  String startDatetime = '2026-07-22T10:00:00',
  String endDatetime = '2026-07-22T11:00:00',
  int usedLeaveMinutes = 60,
  bool isAllDay = false,
  bool isLeaveEvent = true,
}) =>
    {
      'id': id,
      'title': title,
      'description': description,
      'startDatetime': startDatetime,
      'endDatetime': endDatetime,
      'usedLeaveMinutes': usedLeaveMinutes,
      'isAllDay': isAllDay,
      'isLeaveEvent': isLeaveEvent,
    };

void main() {
  group('CalendarEventRepository - getCalendarEvents', () {
    late MockDioHelper mockDioHelper;
    late DioClient dioClient;
    late CalendarEventRepositoryImpl repository;

    const year = 2026;
    const month = 7;

    setUp(() {
      mockDioHelper = MockDioHelper(baseUrl: 'https://api.test.com');
      dioClient = DioClient(
        baseUrl: 'https://api.test.com',
        dio: mockDioHelper.dio,
      );
      repository = CalendarEventRepositoryImpl(dioClient);
    });

    // ─── 성공 케이스 ─────────────────────────────────────────────────────────

    test('조회 성공 - 이벤트 1건', () async {
      mockDioHelper.mockGet(
        path: _path,
        queryParameters: {'year': year, 'month': month},
        responseData: _makeListResponse([_makeEventItem()]),
      );

      final result = await repository.getCalendarEvents(year: year, month: month);

      expect(result, isA<Success<List<CalendarEventEntity>, NetworkError>>());
      result.fold(
        onSuccess: (events) {
          expect(events.length, 1);
          expect(events.first.id, 1);
          expect(events.first.title, '회의');
          expect(events.first.isLeaveEvent, true);
          expect(events.first.isAllDay, false);
        },
        onFailure: (_) => fail('Should succeed'),
      );
    });

    test('조회 성공 - 이벤트 여러 건', () async {
      mockDioHelper.mockGet(
        path: _path,
        queryParameters: {'year': year, 'month': month},
        responseData: _makeListResponse([
          _makeEventItem(id: 1, title: '연차'),
          _makeEventItem(id: 2, title: '외출', isLeaveEvent: false),
          _makeEventItem(id: 3, title: '종일 연차', isAllDay: true),
        ]),
      );

      final result = await repository.getCalendarEvents(year: year, month: month);

      expect(result, isA<Success<List<CalendarEventEntity>, NetworkError>>());
      result.fold(
        onSuccess: (events) => expect(events.length, 3),
        onFailure: (_) => fail('Should succeed'),
      );
    });

    test('조회 성공 - 이벤트 없음 (빈 배열)', () async {
      mockDioHelper.mockGet(
        path: _path,
        queryParameters: {'year': year, 'month': month},
        responseData: _makeListResponse([]),
      );

      final result = await repository.getCalendarEvents(year: year, month: month);

      expect(result, isA<Success<List<CalendarEventEntity>, NetworkError>>());
      result.fold(
        onSuccess: (events) => expect(events, isEmpty),
        onFailure: (_) => fail('Should succeed'),
      );
    });

    test('조회 성공 - 종일 이벤트 필드 확인', () async {
      mockDioHelper.mockGet(
        path: _path,
        queryParameters: {'year': year, 'month': month},
        responseData: _makeListResponse([
          _makeEventItem(
            isAllDay: true,
            startDatetime: '2026-07-22T00:00:00',
            endDatetime: '2026-07-22T23:59:00',
          ),
        ]),
      );

      final result = await repository.getCalendarEvents(year: year, month: month);

      result.fold(
        onSuccess: (events) {
          expect(events.first.isAllDay, true);
          expect(events.first.startDatetime.hour, 0);
          expect(events.first.endDatetime.hour, 23);
        },
        onFailure: (_) => fail('Should succeed'),
      );
    });

    // ─── 실패 케이스 ─────────────────────────────────────────────────────────

    test('조회 실패 - 인증 에러 (401)', () async {
      mockDioHelper.mockError(
        path: _path,
        method: 'GET',
        statusCode: 401,
        errorMessage: 'Unauthorized',
      );

      final result = await repository.getCalendarEvents(year: year, month: month);

      expect(result, isA<Failure<List<CalendarEventEntity>, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail'),
        onFailure: (error) => expect(error, isA<UnauthorizedError>()),
      );
    });

    test('조회 실패 - 서버 에러 (500)', () async {
      mockDioHelper.mockError(
        path: _path,
        method: 'GET',
        statusCode: 500,
        errorMessage: 'Internal Server Error',
      );

      final result = await repository.getCalendarEvents(year: year, month: month);

      expect(result, isA<Failure<List<CalendarEventEntity>, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail'),
        onFailure: (error) {
          expect(error, isA<ServerError>());
          expect((error as ServerError).statusCode, 500);
        },
      );
    });

    test('조회 실패 - 타임아웃', () async {
      mockDioHelper.mockTimeout(path: _path, method: 'GET');

      final result = await repository.getCalendarEvents(year: year, month: month);

      expect(result, isA<Failure<List<CalendarEventEntity>, NetworkError>>());
      result.fold(
        onSuccess: (_) => fail('Should fail'),
        onFailure: (error) => expect(error, isA<TimeoutError>()),
      );
    });
  });
}
