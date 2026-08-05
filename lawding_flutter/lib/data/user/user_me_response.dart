import '../../domain/entities/leave_policy_request.dart';
import '../../domain/entities/user_me.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/leave_policy.dart';
import '../../domain/entities/leave_yearly_balance.dart';

class UserMeResponse {
  final UserProfile user;
  final LeavePolicy leavePolicy;
  final LeaveYearlyBalance leaveBalance;

  const UserMeResponse({
    required this.user,
    required this.leavePolicy,
    required this.leaveBalance,
  });

  factory UserMeResponse.fromJson(Map<String, dynamic> json) {
    final u = json['user'] as Map<String, dynamic>;
    final p = json['leavePolicy'] as Map<String, dynamic>;
    final b = json['leaveBalance'] as Map<String, dynamic>;

    Map<String, WorkTimeSlot> parsePattern(Map<String, dynamic> raw) {
      return raw.map(
        (day, slot) => MapEntry(
          day,
          WorkTimeSlot(
            start: (slot as Map<String, dynamic>)['start'] as String,
            end: slot['end'] as String,
          ),
        ),
      );
    }

    return UserMeResponse(
      user: UserProfile(
        id: u['id'] as int,
        username: u['username'] as String,
        email: u['email'] as String,
        provider: u['provider'] as String,
        nickname: u['nickname'] as String,
        onboardingCompleted: u['onboardingCompleted'] as bool,
        deleted: u['deleted'] as bool? ?? false,
      ),
      leavePolicy: LeavePolicy(
        userId: p['userId'] as int,
        acceptedAt: p['acceptedAt'] as String,
        leaveAccrualBasis: p['leaveAccrualBasis'] as int,
        hireDate: p['hireDate'] as String,
        fiscalYearBaseMonth: p['fiscalYearBaseMonth'] as int?,
        companySize: p['companySize'] as int,
        workPattern: parsePattern(p['workPattern'] as Map<String, dynamic>),
        breakTimePattern: parsePattern(p['breakTimePattern'] as Map<String, dynamic>),
      ),
      leaveBalance: LeaveYearlyBalance(
        usedLeaveMinutes: b['usedLeaveMinutes'] as int,
        remainingLeaveMinutes: b['remainingLeaveMinutes'] as int,
        totalLeaveMinutes: b['totalLeaveMinutes'] as int,
        avgDailyWorkHours: (b['avgDailyWorkHours'] as num).toDouble(),
      ),
    );
  }

  UserMe toDomain() => UserMe(
    user: user,
    leavePolicy: leavePolicy,
    leaveBalance: leaveBalance,
  );
}
