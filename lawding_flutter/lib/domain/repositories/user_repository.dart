import '../core/result.dart';
import '../entities/user_dashboard.dart';
import '../entities/user_profile.dart';
import '../../data/network/network_error.dart';

/// User Repository 인터페이스
abstract interface class UserRepository {
  /// 내 프로필 조회
  /// GET /v1/users/me/profile
  Future<Result<UserProfile, NetworkError>> getProfile();

  /// 내 대시보드 정보 조회
  /// GET /v1/users/me/dashboard
  Future<Result<UserDashboard, NetworkError>> getDashboard();

  /// 남은 연차 요약 조회
  /// GET /v1/users/me/leave-summary
  Future<Result<UserDashboard, NetworkError>> getLeaveSummary();
}
