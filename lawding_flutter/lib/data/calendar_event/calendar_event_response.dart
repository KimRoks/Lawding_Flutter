/// 캘린더 이벤트 목록 API 응답 모델
/// GET /v1/calendar-events?year={year}&month={month}
class CalendarEventListApiResponse {
  final String status;
  final String message;
  final List<CalendarEventItemResponse> data;
  final String timestamp;

  const CalendarEventListApiResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory CalendarEventListApiResponse.fromJson(Map<String, dynamic> json) {
    return CalendarEventListApiResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map(
            (item) => CalendarEventItemResponse.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      timestamp: json['timestamp'] as String,
    );
  }
}

/// 단건 캘린더 이벤트 API 응답 모델
/// GET /v1/calendar-events/{id}, POST /v1/calendar-events, PUT /v1/calendar-events/{id}
class CalendarEventSingleApiResponse {
  final String status;
  final String message;
  final CalendarEventItemResponse data;
  final String timestamp;

  const CalendarEventSingleApiResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory CalendarEventSingleApiResponse.fromJson(Map<String, dynamic> json) {
    return CalendarEventSingleApiResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: CalendarEventItemResponse.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
      timestamp: json['timestamp'] as String,
    );
  }
}

/// 캘린더 이벤트 항목 응답 모델
class CalendarEventItemResponse {
  final int id;
  final String title;
  final String description;
  final String startDatetime; // "2026-06-22T10:00:00"
  final String endDatetime; // "2026-06-22T11:00:00"
  final int usedLeaveMinutes;
  final bool isAllDay;
  final bool isLeaveEvent;

  const CalendarEventItemResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.startDatetime,
    required this.endDatetime,
    required this.usedLeaveMinutes,
    required this.isAllDay,
    required this.isLeaveEvent,
  });

  factory CalendarEventItemResponse.fromJson(Map<String, dynamic> json) {
    // 서버에 따라 int가 String으로 올 수 있어 안전하게 파싱
    return CalendarEventItemResponse(
      id: int.parse(json['id'].toString()),
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      startDatetime: json['startDatetime'] as String,
      endDatetime: json['endDatetime'] as String,
      usedLeaveMinutes: int.parse((json['usedLeaveMinutes'] ?? 0).toString()),
      isAllDay: json['isAllDay'] as bool,
      isLeaveEvent: json['isLeaveEvent'] as bool,
    );
  }
}
