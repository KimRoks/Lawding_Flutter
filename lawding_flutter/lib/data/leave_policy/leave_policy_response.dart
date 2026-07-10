import '../../domain/entities/leave_policy.dart';
import '../../domain/entities/leave_policy_request.dart';

class LeavePolicyResponse {
  final int userId;
  final String acceptedAt;
  final int leaveAccrualBasis;
  final String hireDate;
  final int? fiscalYearBaseMonth;
  final int companySize;
  final Map<String, WorkTimeSlot> workPattern;
  final Map<String, WorkTimeSlot> breakTimePattern;

  const LeavePolicyResponse({
    required this.userId,
    required this.acceptedAt,
    required this.leaveAccrualBasis,
    required this.hireDate,
    this.fiscalYearBaseMonth,
    required this.companySize,
    required this.workPattern,
    required this.breakTimePattern,
  });

  factory LeavePolicyResponse.fromJson(Map<String, dynamic> json) {
    Map<String, WorkTimeSlot> parsePattern(Map<String, dynamic> raw) {
      return raw.map(
        (day, slot) => MapEntry(
          day,
          WorkTimeSlot(
            start: slot['start'] as String,
            end: slot['end'] as String,
          ),
        ),
      );
    }

    return LeavePolicyResponse(
      userId: json['userId'] as int,
      acceptedAt: json['acceptedAt'] as String,
      leaveAccrualBasis: json['leaveAccrualBasis'] as int,
      hireDate: json['hireDate'] as String,
      fiscalYearBaseMonth: json['fiscalYearBaseMonth'] as int?,
      companySize: json['companySize'] as int,
      workPattern: parsePattern(
        json['workPattern'] as Map<String, dynamic>,
      ),
      breakTimePattern: parsePattern(
        json['breakTimePattern'] as Map<String, dynamic>,
      ),
    );
  }

  LeavePolicy toDomain() => LeavePolicy(
    userId: userId,
    acceptedAt: acceptedAt,
    leaveAccrualBasis: leaveAccrualBasis,
    hireDate: hireDate,
    fiscalYearBaseMonth: fiscalYearBaseMonth,
    companySize: companySize,
    workPattern: workPattern,
    breakTimePattern: breakTimePattern,
  );
}
