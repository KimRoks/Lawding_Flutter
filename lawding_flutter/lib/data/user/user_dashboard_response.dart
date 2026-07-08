import '../../domain/entities/user_dashboard.dart';

class UserDashboardResponse {
  final String nickname;
  final int remainingLeaveMinutes;
  final double remainingLeaveDays;
  final double remainingLeaveHours;

  const UserDashboardResponse({
    required this.nickname,
    required this.remainingLeaveMinutes,
    required this.remainingLeaveDays,
    required this.remainingLeaveHours,
  });

  factory UserDashboardResponse.fromJson(Map<String, dynamic> json) {
    return UserDashboardResponse(
      nickname: json['nickname'] as String,
      remainingLeaveMinutes: (json['remainingLeaveMinutes'] as num?)?.toInt() ?? 0,
      remainingLeaveDays: (json['remainingLeaveDays'] as num?)?.toDouble() ?? 0.0,
      remainingLeaveHours: (json['remainingLeaveHours'] as num?)?.toDouble() ?? 0.0,
    );
  }

  UserDashboard toDomain() => UserDashboard(
    nickname: nickname,
    remainingLeaveMinutes: remainingLeaveMinutes,
    remainingLeaveDays: remainingLeaveDays,
    remainingLeaveHours: remainingLeaveHours,
  );
}
