import '../core/result.dart';
import '../entities/calendar_event.dart';
import '../entities/calendar_event_request.dart';
import '../../data/network/network_error.dart';

abstract interface class CalendarEventRepository {
  /// 월별 캘린더 이벤트 목록 조회
  /// GET /v1/calendar-events?year={year}&month={month}
  Future<Result<List<CalendarEventEntity>, NetworkError>> getCalendarEvents({
    required int year,
    required int month,
  });

  /// 단건 캘린더 이벤트 조회
  /// GET /v1/calendar-events/{id}
  Future<Result<CalendarEventEntity, NetworkError>> getCalendarEvent({
    required int id,
  });

  /// 캘린더 이벤트 생성
  /// POST /v1/calendar-events
  Future<Result<void, NetworkError>> createCalendarEvent({
    required CalendarEventRequest request,
  });

  /// 캘린더 이벤트 수정
  /// PUT /v1/calendar-events/{id}
  Future<Result<CalendarEventEntity, NetworkError>> updateCalendarEvent({
    required int id,
    required CalendarEventRequest request,
  });

  /// 캘린더 이벤트 삭제
  /// DELETE /v1/calendar-events/{id}
  Future<Result<void, NetworkError>> deleteCalendarEvent({required int id});
}
