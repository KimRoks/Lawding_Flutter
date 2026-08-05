/// 인증 토큰 저장/조회/삭제 Repository 인터페이스
abstract interface class AuthRepository {
  /// accessToken 저장
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// accessToken 조회
  Future<String?> getAccessToken();

  /// refreshToken 조회
  Future<String?> getRefreshToken();

  /// 토큰 전체 삭제 (로그아웃)
  Future<void> clearTokens();

  /// 로그인 상태 여부
  Future<bool> isLoggedIn();

  /// 토큰 만료로 인한 강제 로그아웃 이벤트 스트림
  Stream<void> get onSessionExpired;

  /// 세션 만료 이벤트 발생 — 인터셉터가 reissue 실패 후 호출
  void notifySessionExpired();
}
