class RecentLeaveUsage {
  final String? title;
  final String startDatetime; // "YYYY-MM-DDTHH:MM:SS"
  final String endDatetime;
  final int usedLeaveMinutes;

  const RecentLeaveUsage({
    this.title,
    required this.startDatetime,
    required this.endDatetime,
    required this.usedLeaveMinutes,
  });
}

class LeaveDashboard {
  final int availableLeaveMinutes;
  final double avgDailyWorkHours;
  final int totalLeaveMinutes;
  final String nextLeaveAccrualDate; // "YYYY-MM-DD"
  final int expiringLeaveMinutes;
  final String leavePeriodStartDate; // "YYYY-MM-DD"
  final String leavePeriodEndDate; // "YYYY-MM-DD"
  final List<RecentLeaveUsage> recentLeaveUsages;
  final int leaveAccrualBasis; // 1: 입사일 기준, 2: 회계연도 기준

  const LeaveDashboard({
    required this.availableLeaveMinutes,
    required this.avgDailyWorkHours,
    required this.totalLeaveMinutes,
    required this.nextLeaveAccrualDate,
    required this.expiringLeaveMinutes,
    required this.leavePeriodStartDate,
    required this.leavePeriodEndDate,
    required this.recentLeaveUsages,
    required this.leaveAccrualBasis,
  });
}
