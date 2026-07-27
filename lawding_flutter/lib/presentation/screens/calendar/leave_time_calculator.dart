import '../../../domain/entities/holiday.dart';
import '../../../domain/entities/leave_policy_request.dart';

/// 일정 등록 화면의 연차 차감 시간 계산 로직.
/// 상태에 의존하지 않는 순수 클래스이므로 단위 테스트가 가능합니다.
class LeaveTimeCalculator {
  final Map<String, WorkTimeSlot> workPattern;
  final Map<String, WorkTimeSlot> breakTimePattern;
  final double avgDailyWorkHours;
  final List<Holiday> holidays;

  const LeaveTimeCalculator({
    required this.workPattern,
    required this.breakTimePattern,
    required this.avgDailyWorkHours,
    this.holidays = const [],
  });

  static const _weekdayNames = {
    1: 'MONDAY',
    2: 'TUESDAY',
    3: 'WEDNESDAY',
    4: 'THURSDAY',
    5: 'FRIDAY',
    6: 'SATURDAY',
    7: 'SUNDAY',
  };

  static int parseTimeStr(String t) {
    final p = t.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool isHolidayDate(DateTime date) =>
      holidays.any((h) => _isSameDay(h.date, date));

  /// 단일 날짜의 연차 차감 시간(분).
  /// [inputStartMin] / [inputEndMin]: 분 단위 시작·종료 시각 (다일 이벤트 위치에 따라 호출자가 조정).
  int calcUsedMinutesForDate(
    DateTime date, {
    required int inputStartMin,
    required int inputEndMin,
    required bool isAllDay,
  }) {
    if (isHolidayDate(date)) return 0;

    final maxMin = (avgDailyWorkHours * 60).round();
    final dayName = _weekdayNames[date.weekday]!;
    final workSlot = workPattern[dayName];
    if (workSlot == null) return 0;

    if (isAllDay) return maxMin;

    final workStart = parseTimeStr(workSlot.start);
    final workEnd = parseTimeStr(workSlot.end);

    final effStart = inputStartMin > workStart ? inputStartMin : workStart;
    final effEnd = inputEndMin < workEnd ? inputEndMin : workEnd;
    if (effStart >= effEnd) return 0;

    int breakDed = 0;
    final breakSlot = breakTimePattern[dayName];
    if (breakSlot != null) {
      final bStart = parseTimeStr(breakSlot.start);
      final bEnd = parseTimeStr(breakSlot.end);
      final oStart = effStart > bStart ? effStart : bStart;
      final oEnd = effEnd < bEnd ? effEnd : bEnd;
      if (oEnd > oStart) breakDed = oEnd - oStart;
    }

    return (effEnd - effStart - breakDed).clamp(0, maxMin);
  }

  /// 날짜 목록 전체의 합산 연차 차감 시간(분).
  /// 다일 이벤트: 첫날=startMin~workEnd, 중간=하루 전체, 마지막날=workStart~endMin
  int calcTotalUsedMinutes(
    List<DateTime> dates, {
    required int startMin,
    required int endMin,
    required bool isAllDay,
  }) {
    if (dates.isEmpty) return 0;
    if (dates.length == 1) {
      return calcUsedMinutesForDate(
        dates.first,
        inputStartMin: startMin,
        inputEndMin: endMin,
        isAllDay: isAllDay,
      );
    }
    int total = 0;
    for (int i = 0; i < dates.length; i++) {
      if (i == 0) {
        total += calcUsedMinutesForDate(
          dates[i],
          inputStartMin: startMin,
          inputEndMin: 24 * 60,
          isAllDay: isAllDay,
        );
      } else if (i == dates.length - 1) {
        total += calcUsedMinutesForDate(
          dates[i],
          inputStartMin: 0,
          inputEndMin: endMin,
          isAllDay: isAllDay,
        );
      } else {
        total += calcUsedMinutesForDate(
          dates[i],
          inputStartMin: 0,
          inputEndMin: 24 * 60,
          isAllDay: isAllDay,
        );
      }
    }
    return total;
  }

  /// 근로일이지만 입력 시간과 전혀 겹치지 않는 날이 있으면 true.
  /// 다일 이벤트: 첫날=startMin 기준, 중간날=항상 겹침, 마지막날=endMin 기준.
  bool hasWorkDayWithNoOverlap(
    List<DateTime> dates, {
    required int startMin,
    required int endMin,
  }) {
    for (int i = 0; i < dates.length; i++) {
      final d = dates[i];
      if (isHolidayDate(d)) continue;
      final workSlot = workPattern[_weekdayNames[d.weekday]!];
      if (workSlot == null) continue;
      final workStart = parseTimeStr(workSlot.start);
      final workEnd = parseTimeStr(workSlot.end);
      final isFirst = i == 0;
      final isLast = i == dates.length - 1;
      final inputStart = isFirst ? startMin : workStart;
      final inputEnd = isLast ? endMin : workEnd;
      final effStart = inputStart > workStart ? inputStart : workStart;
      final effEnd = inputEnd < workEnd ? inputEnd : workEnd;
      if (effStart >= effEnd) return true;
    }
    return false;
  }

  /// 첫날 시작·마지막날 종료 시각이 근무 시간 외에 걸치면 true.
  bool hasOutsideWorkHours(
    List<DateTime> dates, {
    required int startMin,
    required int endMin,
  }) {
    for (int i = 0; i < dates.length; i++) {
      final d = dates[i];
      if (isHolidayDate(d)) continue;
      final workSlot = workPattern[_weekdayNames[d.weekday]!];
      if (workSlot == null) continue;
      final workStart = parseTimeStr(workSlot.start);
      final workEnd = parseTimeStr(workSlot.end);
      final isFirst = i == 0;
      final isLast = i == dates.length - 1;
      if (isFirst && startMin < workStart) return true;
      if (isLast && endMin > workEnd) return true;
    }
    return false;
  }
}
