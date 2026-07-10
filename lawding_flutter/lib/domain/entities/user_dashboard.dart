class UserDashboard {
  final String nickname;
  final int availableLeaveMinutes;
  final double avgDailyWorkHours;

  const UserDashboard({
    required this.nickname,
    required this.availableLeaveMinutes,
    required this.avgDailyWorkHours,
  });

  double get availableLeaveHours => availableLeaveMinutes / 60;

  double get availableLeaveDays =>
      avgDailyWorkHours > 0 ? availableLeaveHours / avgDailyWorkHours : 0;
}
