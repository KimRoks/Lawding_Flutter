import 'leave_policy_request.dart';

class LeavePolicy {
  final int userId;
  final String acceptedAt; // ISO datetime
  final int leaveAccrualBasis; // 1: 입사일기준, 2: 회계연도기준
  final String hireDate; // "YYYY-MM-DD"
  final int? fiscalYearBaseMonth;
  final int companySize;
  final Map<String, WorkTimeSlot> workPattern; // "HH:mm:ss"
  final Map<String, WorkTimeSlot> breakTimePattern; // "HH:mm:ss"

  const LeavePolicy({
    required this.userId,
    required this.acceptedAt,
    required this.leaveAccrualBasis,
    required this.hireDate,
    this.fiscalYearBaseMonth,
    required this.companySize,
    required this.workPattern,
    required this.breakTimePattern,
  });

  /// 하루 평균 순 근무시간(분): (근무시간 - 휴게시간) 평균
  int get dailyWorkMinutes {
    if (workPattern.isEmpty) return 480; // fallback 8시간

    int total = 0;
    for (final day in workPattern.keys) {
      final work = workPattern[day]!;
      final breakSlot = breakTimePattern[day];
      final workMin = _slotMinutes(work.start, work.end);
      final breakMin = breakSlot != null
          ? _slotMinutes(breakSlot.start, breakSlot.end)
          : 0;
      total += (workMin - breakMin).clamp(0, 1440);
    }
    return (total / workPattern.length).round();
  }

  /// "HH:mm" 또는 "HH:mm:ss" → 분 단위 변환
  static int _slotMinutes(String start, String end) {
    int parseTime(String t) {
      final parts = t.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    return (parseTime(end) - parseTime(start)).clamp(0, 1440);
  }
}
