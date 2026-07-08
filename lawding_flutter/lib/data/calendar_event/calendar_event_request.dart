/// 캘린더 이벤트 생성/수정 요청 모델
class CalendarEventRequest {
  final String? title;           // 옵셔널
  final String? description;     // 옵셔널
  final DateTime startDatetime;  // 필수
  final DateTime endDatetime;    // 필수
  final int? usedLeaveMinutes;   // 옵셔널
  final bool isAllDay;           // 필수
  final bool isLeaveEvent;       // 필수

  const CalendarEventRequest({
    this.title,
    this.description,
    required this.startDatetime,
    required this.endDatetime,
    this.usedLeaveMinutes,
    required this.isAllDay,
    required this.isLeaveEvent,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'startDatetime': startDatetime.toIso8601String().split('.').first,
      'endDatetime': endDatetime.toIso8601String().split('.').first,
      'isAllDay': isAllDay,
      'isLeaveEvent': isLeaveEvent,
    };
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (usedLeaveMinutes != null) map['usedLeaveMinutes'] = usedLeaveMinutes;
    return map;
  }
}
