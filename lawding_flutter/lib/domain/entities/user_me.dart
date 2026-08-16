import 'leave_yearly_balance.dart';
import 'leave_policy.dart';
import 'user_profile.dart';

class UserMe {
  final UserProfile user;
  final LeavePolicy leavePolicy;
  final LeaveYearlyBalance leaveBalance;

  const UserMe({
    required this.user,
    required this.leavePolicy,
    required this.leaveBalance,
  });
}
