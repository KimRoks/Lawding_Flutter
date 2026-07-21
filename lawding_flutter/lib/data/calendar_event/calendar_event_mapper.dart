import '../../domain/entities/calendar_event.dart';
import 'calendar_event_response.dart';

/// CalendarEventItemResponse → CalendarEventEntity 변환
extension CalendarEventItemResponseMapper on CalendarEventItemResponse {
  CalendarEventEntity toDomain() {
    return CalendarEventEntity(
      id: id,
      title: title,
      description: description,
      startDatetime: DateTime.parse(startDatetime),
      endDatetime: DateTime.parse(endDatetime),
      usedLeaveMinutes: usedLeaveMinutes,
      isAllDay: isAllDay,
      isLeaveEvent: isLeaveEvent,
    );
  }
}

/// CalendarEventListApiResponse → `List<CalendarEventEntity>` 변환
extension CalendarEventListApiResponseMapper on CalendarEventListApiResponse {
  List<CalendarEventEntity> toDomain() =>
      data.map((item) => item.toDomain()).toList();
}

/// CalendarEventSingleApiResponse → CalendarEventEntity 변환
extension CalendarEventSingleApiResponseMapper
    on CalendarEventSingleApiResponse {
  CalendarEventEntity toDomain() => data!.toDomain();
}
