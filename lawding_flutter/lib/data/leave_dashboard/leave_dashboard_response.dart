import '../../domain/entities/leave_dashboard.dart';

class RecentLeaveUsageResponse {
  final String? title;
  final String startDatetime;
  final String endDatetime;
  final int usedLeaveMinutes;

  const RecentLeaveUsageResponse({
    this.title,
    required this.startDatetime,
    required this.endDatetime,
    required this.usedLeaveMinutes,
  });

  factory RecentLeaveUsageResponse.fromJson(Map<String, dynamic> json) {
    return RecentLeaveUsageResponse(
      title: json['title'] as String?,
      startDatetime: json['startDatetime'] as String,
      endDatetime: json['endDatetime'] as String,
      usedLeaveMinutes: json['usedLeaveMinutes'] as int,
    );
  }

  RecentLeaveUsage toDomain() => RecentLeaveUsage(
    title: title,
    startDatetime: startDatetime,
    endDatetime: endDatetime,
    usedLeaveMinutes: usedLeaveMinutes,
  );
}

class LeaveDashboardResponse {
  final int availableLeaveMinutes;
  final double avgDailyWorkHours;
  final int totalLeaveMinutes;
  final String nextLeaveAccrualDate;
  final int expiringLeaveMinutes;
  final String leavePeriodStartDate;
  final String leavePeriodEndDate;
  final List<RecentLeaveUsageResponse> recentLeaveUsages;
  final int leaveAccrualBasis;

  const LeaveDashboardResponse({
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

  factory LeaveDashboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaveDashboardResponse(
      availableLeaveMinutes: json['availableLeaveMinutes'] as int,
      avgDailyWorkHours: (json['avgDailyWorkHours'] as num).toDouble(),
      totalLeaveMinutes: json['totalLeaveMinutes'] as int,
      nextLeaveAccrualDate: json['nextLeaveAccrualDate'] as String,
      expiringLeaveMinutes: json['expiringLeaveMinutes'] as int,
      leavePeriodStartDate: json['leavePeriodStartDate'] as String,
      leavePeriodEndDate: json['leavePeriodEndDate'] as String,
      recentLeaveUsages: (json['recentLeaveUsages'] as List<dynamic>)
          .map((e) => RecentLeaveUsageResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      leaveAccrualBasis: json['leaveAccrualBasis'] as int,
    );
  }

  LeaveDashboard toDomain() => LeaveDashboard(
    availableLeaveMinutes: availableLeaveMinutes,
    avgDailyWorkHours: avgDailyWorkHours,
    totalLeaveMinutes: totalLeaveMinutes,
    nextLeaveAccrualDate: nextLeaveAccrualDate,
    expiringLeaveMinutes: expiringLeaveMinutes,
    leavePeriodStartDate: leavePeriodStartDate,
    leavePeriodEndDate: leavePeriodEndDate,
    recentLeaveUsages: recentLeaveUsages.map((e) => e.toDomain()).toList(),
    leaveAccrualBasis: leaveAccrualBasis,
  );
}
