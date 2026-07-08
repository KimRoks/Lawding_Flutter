class UserDashboard {
  final String nickname;
  final int remainingLeaveMinutes;
  final double remainingLeaveDays;
  final double remainingLeaveHours;

  const UserDashboard({
    required this.nickname,
    required this.remainingLeaveMinutes,
    required this.remainingLeaveDays,
    required this.remainingLeaveHours,
  });
}
