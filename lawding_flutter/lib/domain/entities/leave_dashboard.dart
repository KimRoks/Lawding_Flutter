class RecentLeaveUsage {
  final String startDatetime; // "YYYY-MM-DDTHH:MM:SS"
  final String endDatetime;
  final int usedLeaveMinutes;

  const RecentLeaveUsage({
    required this.startDatetime,
    required this.endDatetime,
    required this.usedLeaveMinutes,
  });
}

class LeaveDashboard {
  final int remainingLeaveMinutes;
  final double avgDailyWorkHours;
  final int totalLeaveMinutes;
  final String nextLeaveAccrualDate; // "YYYY-MM-DD"
  final int expiringLeaveMinutes;
  final String leavePeriodStartDate; // "YYYY-MM-DD"
  final String leavePeriodEndDate; // "YYYY-MM-DD"
  final List<RecentLeaveUsage> recentLeaveUsages;

  const LeaveDashboard({
    required this.remainingLeaveMinutes,
    required this.avgDailyWorkHours,
    required this.totalLeaveMinutes,
    required this.nextLeaveAccrualDate,
    required this.expiringLeaveMinutes,
    required this.leavePeriodStartDate,
    required this.leavePeriodEndDate,
    required this.recentLeaveUsages,
  });
}
