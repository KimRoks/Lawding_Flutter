import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/network/network_error.dart';
import '../../../data/network/oauth_urls.dart';
import '../../../infrastructure/services/analytics_service.dart';
import '../../providers/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  /// onboardingCompleted: 서버 응답의 onboardingCompleted 값
  final void Function(bool onboardingCompleted) onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
    AnalyticsService().logLoginScreenViewed();
  }

  void _initDeepLinkListener() {
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'ggimiowner.annualleavecalculator' &&
          uri.host == 'oauth') {
        _handleOAuthCallback(uri.queryParameters);
      }
    });
  }

  Future<void> _handleOAuthCallback(Map<String, String> params) async {
    final accessToken = params['accessToken'];
    final refreshToken = params['refreshToken'];

    if (accessToken == null || refreshToken == null) {
      debugPrint(
        '[OAuth] 토큰 누락 - accessToken: $accessToken, refreshToken: $refreshToken',
      );
      return;
    }

    final onboardingCompleted =
        params['onboardingCompleted']?.toLowerCase() == 'true';

    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    debugPrint('[OAuth] 토큰 저장 완료 / onboardingCompleted: $onboardingCompleted');

    AnalyticsService().logLoginSucceeded(onboardingCompleted: onboardingCompleted);
    if (mounted) widget.onLoginSuccess(onboardingCompleted);
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _loginWith(String method, String fullUrl) async {
    setState(() => _isLoading = true);
    try {
      debugPrint('[OAuth] 요청 URL: $fullUrl');
      final uri = Uri.parse(fullUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      String errorMessage;
      if (e is ServerError) {
        errorMessage = '[${e.statusCode}] ${e.message}';
      } else {
        errorMessage = e.runtimeType.toString();
      }
      debugPrint('[OAuth] 에러: $errorMessage');
      AnalyticsService().logLoginFailed(method: method, errorMessage: errorMessage);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그인 중 오류: $errorMessage')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(flex: 201),
              Image.asset('assets/icons/app_icon.png', width: 185, height: 166),
              const Spacer(flex: 304),
              if (Platform.isIOS) ...[
                _LoginButton(
                  icon: const _AppleIcon(),
                  label: 'Apple로 계속하기',
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  borderColor: const Color(0xFFE1E1E1),
                  onTap: _isLoading
                      ? null
                      : () {
                          AnalyticsService().logLoginMethodTapped('apple');
                          _loginWith('apple', OAuthUrls.apple(ref.read(baseUrlProvider)));
                        },
                ),
                const SizedBox(height: 12),
              ],
              _LoginButton(
                icon: const _GoogleIcon(),
                label: 'Google로 계속하기',
                backgroundColor: Colors.white,
                textColor: Colors.black,
                borderColor: const Color(0xFFE1E1E1),
                onTap: _isLoading
                    ? null
                    : () {
                        AnalyticsService().logLoginMethodTapped('google');
                        _loginWith('google', OAuthUrls.google(ref.read(baseUrlProvider)));
                      },
              ),
              const SizedBox(height: 12),
              _LoginButton(
                icon: const _KakaoIcon(),
                label: '카카오로 계속하기',
                backgroundColor: const Color(0xFFFEE500),
                textColor: const Color(0xFF191919),
                onTap: _isLoading
                    ? null
                    : () {
                        AnalyticsService().logLoginMethodTapped('kakao');
                        _loginWith('kakao', OAuthUrls.kakao(ref.read(baseUrlProvider)));
                      },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  AnalyticsService().logLoginSkipTapped();
                  Navigator.of(context).pop();
                },
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      '건너뛰기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 로그인 버튼
// ============================================================================

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.borderColor,
  });

  final Widget icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.48,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 브랜드 아이콘
// ============================================================================

class _AppleIcon extends StatelessWidget {
  const _AppleIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/OAuth_apple.svg',
      width: 22,
      height: 22,
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/OAuth_google.svg',
      width: 22,
      height: 22,
    );
  }
}

class _KakaoIcon extends StatelessWidget {
  const _KakaoIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/OAuth_kakao.svg',
      width: 22,
      height: 22,
    );
  }
}
