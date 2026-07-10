import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/auth/auth_repository_impl.dart';

void main() {
  group('AuthRepository Tests', () {
    late AuthRepositoryImpl repository;

    setUp(() {
      // 각 테스트 전에 Keychain/EncryptedSharedPreferences를 빈 상태로 초기화
      FlutterSecureStorage.setMockInitialValues({});
      repository = AuthRepositoryImpl();
    });

    // ========================================================================
    // saveTokens / getAccessToken / getRefreshToken
    // ========================================================================

    test('토큰 저장 후 조회 성공', () async {
      // Given: 유효한 accessToken과 refreshToken
      const accessToken = 'access_token_abc';
      const refreshToken = 'refresh_token_xyz';

      // When: 토큰 저장
      await repository.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // Then: 저장한 토큰과 동일하게 조회됨
      expect(await repository.getAccessToken(), accessToken);
      expect(await repository.getRefreshToken(), refreshToken);
    });

    test('토큰 저장 후 덮어쓰기 시 최신 토큰으로 조회됨', () async {
      // Given: 기존 토큰이 저장된 상태
      await repository.saveTokens(
        accessToken: 'old_access',
        refreshToken: 'old_refresh',
      );

      // When: 새 토큰으로 덮어쓰기
      await repository.saveTokens(
        accessToken: 'new_access',
        refreshToken: 'new_refresh',
      );

      // Then: 최신 토큰으로 조회됨
      expect(await repository.getAccessToken(), 'new_access');
      expect(await repository.getRefreshToken(), 'new_refresh');
    });

    // ========================================================================
    // getAccessToken / getRefreshToken — 토큰 없는 경우
    // ========================================================================

    test('저장된 토큰이 없으면 accessToken은 null 반환', () async {
      // Given: 아무것도 저장하지 않은 초기 상태

      // When: accessToken 조회

      // Then: null 반환
      expect(await repository.getAccessToken(), isNull);
    });

    test('저장된 토큰이 없으면 refreshToken은 null 반환', () async {
      // Given: 아무것도 저장하지 않은 초기 상태

      // When: refreshToken 조회

      // Then: null 반환
      expect(await repository.getRefreshToken(), isNull);
    });

    // ========================================================================
    // clearTokens
    // ========================================================================

    test('토큰 삭제 후 accessToken과 refreshToken이 모두 null', () async {
      // Given: 토큰이 저장된 상태
      await repository.saveTokens(
        accessToken: 'access_token_abc',
        refreshToken: 'refresh_token_xyz',
      );

      // When: 토큰 전체 삭제
      await repository.clearTokens();

      // Then: 두 토큰 모두 null
      expect(await repository.getAccessToken(), isNull);
      expect(await repository.getRefreshToken(), isNull);
    });

    test('토큰이 없는 상태에서 clearTokens 호출해도 예외 없음', () async {
      // Given: 아무것도 저장하지 않은 초기 상태

      // When: 토큰 삭제 시도

      // Then: 예외 없이 완료
      expect(() => repository.clearTokens(), returnsNormally);
    });

    // ========================================================================
    // isLoggedIn
    // ========================================================================

    test('accessToken이 있으면 로그인 상태 true', () async {
      // Given: accessToken이 저장된 상태
      await repository.saveTokens(
        accessToken: 'access_token_abc',
        refreshToken: 'refresh_token_xyz',
      );

      // When: 로그인 상태 확인

      // Then: true 반환
      expect(await repository.isLoggedIn(), isTrue);
    });

    test('토큰이 없으면 로그인 상태 false', () async {
      // Given: 아무것도 저장하지 않은 초기 상태

      // When: 로그인 상태 확인

      // Then: false 반환
      expect(await repository.isLoggedIn(), isFalse);
    });

    test('토큰 삭제 후 로그인 상태 false', () async {
      // Given: 토큰이 저장된 상태
      await repository.saveTokens(
        accessToken: 'access_token_abc',
        refreshToken: 'refresh_token_xyz',
      );

      // When: 토큰 삭제
      await repository.clearTokens();

      // Then: false 반환
      expect(await repository.isLoggedIn(), isFalse);
    });
  });
}
