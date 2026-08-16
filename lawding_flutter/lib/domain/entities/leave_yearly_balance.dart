class LeaveYearlyBalance {
  final int usedLeaveMinutes;
  final int remainingLeaveMinutes;
  final int totalLeaveMinutes;
  final double avgDailyWorkHours;

  const LeaveYearlyBalance({
    required this.usedLeaveMinutes,
    required this.remainingLeaveMinutes,
    required this.totalLeaveMinutes,
    required this.avgDailyWorkHours,
  });

  double get remainingLeaveHours => remainingLeaveMinutes / 60;

  double get remainingLeaveDays =>
      avgDailyWorkHours > 0 ? remainingLeaveHours / avgDailyWorkHours : 0;
}
