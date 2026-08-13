import '../core/result.dart';
import '../entities/user_me.dart';
import '../../data/network/network_error.dart';

/// User Repository 인터페이스
abstract interface class UserRepository {
  /// 내 전체 정보 조회 (유저 + 연차 정책 + 연차 잔여)
  /// GET /v1/users/me
  Future<Result<UserMe, NetworkError>> getMe();

  /// 닉네임 수정
  /// PATCH /v1/users/me/profile
  Future<Result<void, NetworkError>> updateProfile({required String nickname});

  /// 회원 탈퇴
  /// DELETE /v1/users/me/profile
  Future<Result<void, NetworkError>> deleteAccount();

  /// 남은 연차 분 수정
  /// PATCH /v1/users/leave-yearly-balance/remaining-minutes
  Future<Result<void, NetworkError>> updateRemainingLeaveMinutes({
    required int remainingLeaveMinutes,
  });
}
