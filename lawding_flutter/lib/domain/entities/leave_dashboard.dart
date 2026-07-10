class LeaveDashboard {
  final int id;
  final int userId;
  final String startDate; // "YYYY-MM-DD"
  final String endDate; // "YYYY-MM-DD"
  final int weeklyWorkingDays;
  final double avgDailyWorkHours;
  final int totalLeaveMinutes;
  final int usedLeaveMinutes;
  final int remainingLeaveMinutes;
  final bool isFinalized;

  const LeaveDashboard({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.weeklyWorkingDays,
    required this.avgDailyWorkHours,
    required this.totalLeaveMinutes,
    required this.usedLeaveMinutes,
    required this.remainingLeaveMinutes,
    required this.isFinalized,
  });
}
