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
    // 최상위 필드가 null이면 명시적 예외 → user_repository_impl catch(e)가 잡아 Failure 반환
    final rawUser = json['user'];
    final rawPolicy = json['leavePolicy'];
    final rawBalance = json['leaveBalance'];
    if (rawUser is! Map<String, dynamic>) {
      throw const FormatException('user_me: user field is null or invalid');
    }
    if (rawPolicy is! Map<String, dynamic>) {
      throw const FormatException('user_me: leavePolicy field is null or invalid');
    }
    if (rawBalance is! Map<String, dynamic>) {
      throw const FormatException('user_me: leaveBalance field is null or invalid');
    }
    final u = rawUser;
    final p = rawPolicy;
    final b = rawBalance;

    Map<String, WorkTimeSlot> parsePattern(Object? raw) {
      if (raw is! Map<String, dynamic>) return const {};
      return raw.map(
        (day, slot) {
          final s = slot is Map<String, dynamic> ? slot : const <String, dynamic>{};
          return MapEntry(
            day,
            WorkTimeSlot(
              start: s['start'] as String? ?? '00:00',
              end: s['end'] as String? ?? '00:00',
            ),
          );
        },
      );
    }

    return UserMeResponse(
      user: UserProfile(
        id: (u['id'] as num?)?.toInt() ?? 0,
        username: u['username'] as String? ?? '',
        email: u['email'] as String? ?? '',
        provider: u['provider'] as String? ?? '',
        nickname: u['nickname'] as String? ?? '',
        onboardingCompleted: u['onboardingCompleted'] as bool? ?? false,
        deleted: u['deleted'] as bool? ?? false,
      ),
      leavePolicy: LeavePolicy(
        userId: (p['userId'] as num?)?.toInt() ?? 0,
        acceptedAt: p['acceptedAt'] as String? ?? '',
        leaveAccrualBasis: (p['leaveAccrualBasis'] as num?)?.toInt() ?? 1,
        hireDate: p['hireDate'] as String? ?? '',
        fiscalYearBaseMonth: (p['fiscalYearBaseMonth'] as num?)?.toInt(),
        companySize: (p['companySize'] as num?)?.toInt() ?? 0,
        workPattern: parsePattern(p['workPattern']),
        breakTimePattern: parsePattern(p['breakTimePattern']),
      ),
      leaveBalance: LeaveYearlyBalance(
        usedLeaveMinutes: (b['usedLeaveMinutes'] as num?)?.toInt() ?? 0,
        remainingLeaveMinutes: (b['remainingLeaveMinutes'] as num?)?.toInt() ?? 0,
        totalLeaveMinutes: (b['totalLeaveMinutes'] as num?)?.toInt() ?? 0,
        avgDailyWorkHours: (b['avgDailyWorkHours'] as num?)?.toDouble() ?? 8.0,
      ),
    );
  }

  UserMe toDomain() => UserMe(
    user: user,
    leavePolicy: leavePolicy,
    leaveBalance: leaveBalance,
  );
}
