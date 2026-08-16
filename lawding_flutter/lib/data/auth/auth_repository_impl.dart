import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();

  @override
  Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  @override
  void notifySessionExpired() {
    _sessionExpiredController.add(null);
  }

  void dispose() {
    _sessionExpiredController.close();
  }

  // iOS: Keychain / Android: EncryptedSharedPreferences
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    // refreshToken 먼저 저장: crash 시 new_access + old_refresh 불일치 방지
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _accessTokenKey, value: accessToken);
    debugPrint('[Auth] 토큰 저장 완료');
  }

  @override
  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    debugPrint('[Auth] 토큰 삭제 완료');
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
