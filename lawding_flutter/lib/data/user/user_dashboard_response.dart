import '../../domain/entities/user_dashboard.dart';

class UserDashboardResponse {
  final String nickname;
  final int availableLeaveMinutes;
  final double avgDailyWorkHours;

  const UserDashboardResponse({
    required this.nickname,
    required this.availableLeaveMinutes,
    required this.avgDailyWorkHours,
  });

  factory UserDashboardResponse.fromJson(Map<String, dynamic> json) {
    return UserDashboardResponse(
      nickname: json['nickname'] as String,
      availableLeaveMinutes:
          (json['availableLeaveMinutes'] as num?)?.toInt() ?? 0,
      avgDailyWorkHours:
          (json['avgDailyWorkHours'] as num?)?.toDouble() ?? 8.0,
    );
  }

  UserDashboard toDomain() => UserDashboard(
    nickname: nickname,
    availableLeaveMinutes: availableLeaveMinutes,
    avgDailyWorkHours: avgDailyWorkHours,
  );
}
