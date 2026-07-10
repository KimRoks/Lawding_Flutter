import '../../domain/entities/calendar_event_request.dart';
import '../network/api_endpoints.dart';
import '../network/api_request.dart';
import '../network/http_methods.dart';

class CalendarEventApi {
  CalendarEventApi._();

  /// 월별 캘린더 이벤트 목록 조회
  /// GET /v1/calendar-events?year={year}&month={month}
  static ApiRequest getCalendarEvents({
    required int year,
    required int month,
  }) {
    return ApiRequest(
      method: HttpMethod.get,
      path: ApiEndpoints.calendarEvents,
      queryParameters: {'year': year, 'month': month},
    );
  }

  /// 단건 캘린더 이벤트 조회
  /// GET /v1/calendar-events/{id}
  static ApiRequest getCalendarEvent({required int id}) {
    return ApiRequest(
      method: HttpMethod.get,
      path: '${ApiEndpoints.calendarEvents}/$id',
    );
  }

  /// 캘린더 이벤트 생성
  /// POST /v1/calendar-events
  static ApiRequest createCalendarEvent({
    required CalendarEventRequest request,
  }) {
    return ApiRequest(
      method: HttpMethod.post,
      path: ApiEndpoints.calendarEvents,
      body: request.toJson(),
    );
  }

  /// 캘린더 이벤트 수정
  /// PUT /v1/calendar-events/{id}
  static ApiRequest updateCalendarEvent({
    required int id,
    required CalendarEventRequest request,
  }) {
    return ApiRequest(
      method: HttpMethod.put,
      path: '${ApiEndpoints.calendarEvents}/$id',
      body: request.toJson(),
    );
  }

  /// 캘린더 이벤트 삭제
  /// DELETE /v1/calendar-events/{id}
  static ApiRequest deleteCalendarEvent({required int id}) {
    return ApiRequest(
      method: HttpMethod.delete,
      path: '${ApiEndpoints.calendarEvents}/$id',
    );
  }
}
