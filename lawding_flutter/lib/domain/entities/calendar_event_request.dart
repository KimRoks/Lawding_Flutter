/// 캘린더 이벤트 생성/수정 요청 모델
class CalendarEventRequest {
  final String title;
  final String description;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final int usedLeaveMinutes;
  final bool isAllDay;
  final bool isLeaveEvent;

  const CalendarEventRequest({
    this.title = '',
    this.description = '',
    required this.startDatetime,
    required this.endDatetime,
    this.usedLeaveMinutes = 0,
    required this.isAllDay,
    required this.isLeaveEvent,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startDatetime': startDatetime.toIso8601String().split('.').first,
      'endDatetime': endDatetime.toIso8601String().split('.').first,
      'usedLeaveMinutes': usedLeaveMinutes,
      'isAllDay': isAllDay,
      'isLeaveEvent': isLeaveEvent,
    };
  }
}
