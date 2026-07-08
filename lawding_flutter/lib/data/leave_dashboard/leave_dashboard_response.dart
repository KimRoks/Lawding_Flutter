import '../../domain/entities/leave_dashboard.dart';

class LeaveDashboardResponse {
  final int id;
  final int userId;
  final String startDate;
  final String endDate;
  final int weeklyWorkingDays;
  final double avgDailyWorkHours;
  final int totalLeaveMinutes;
  final int usedLeaveMinutes;
  final int remainingLeaveMinutes;
  final bool isFinalized;

  const LeaveDashboardResponse({
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

  factory LeaveDashboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaveDashboardResponse(
      id: json['id'] as int,
      userId: json['userId'] as int,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      weeklyWorkingDays: json['weeklyWorkingDays'] as int,
      avgDailyWorkHours: (json['avgDailyWorkHours'] as num).toDouble(),
      totalLeaveMinutes: json['totalLeaveMinutes'] as int,
      usedLeaveMinutes: json['usedLeaveMinutes'] as int,
      remainingLeaveMinutes: json['remainingLeaveMinutes'] as int,
      isFinalized: json['isFinalized'] as bool,
    );
  }

  LeaveDashboard toDomain() => LeaveDashboard(
    id: id,
    userId: userId,
    startDate: startDate,
    endDate: endDate,
    weeklyWorkingDays: weeklyWorkingDays,
    avgDailyWorkHours: avgDailyWorkHours,
    totalLeaveMinutes: totalLeaveMinutes,
    usedLeaveMinutes: usedLeaveMinutes,
    remainingLeaveMinutes: remainingLeaveMinutes,
    isFinalized: isFinalized,
  );
}
