import 'leave_policy_request.dart';

class LeavePolicy {
  final int userId;
  final String acceptedAt; // ISO datetime
  final int leaveAccrualBasis; // 1: 입사일기준, 2: 회계연도기준
  final String hireDate; // "YYYY-MM-DD"
  final int? fiscalYearBaseMonth;
  final int companySize;
  final Map<String, WorkTimeSlot> workPattern; // "HH:mm:ss"
  final Map<String, WorkTimeSlot> breakTimePattern; // "HH:mm:ss"

  const LeavePolicy({
    required this.userId,
    required this.acceptedAt,
    required this.leaveAccrualBasis,
    required this.hireDate,
    this.fiscalYearBaseMonth,
    required this.companySize,
    required this.workPattern,
    required this.breakTimePattern,
  });
}
