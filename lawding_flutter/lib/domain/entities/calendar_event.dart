/// 캘린더 이벤트 도메인 엔티티
class CalendarEventEntity {
  final int id;
  final String title;
  final String description;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final int usedLeaveMinutes;
  final bool isAllDay;
  final bool isLeaveEvent;

  const CalendarEventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.startDatetime,
    required this.endDatetime,
    required this.usedLeaveMinutes,
    required this.isAllDay,
    required this.isLeaveEvent,
  });
}
