import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/network/network_error.dart';
import '../../../data/network/oauth_urls.dart';
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
  }

  void _initDeepLinkListener() {
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'ggimiowner.annualleavecalculator' &&
          uri.host == 'oauth') {
        debugPrint('[OAuth] 콜백 수신 - 전체 파라미터: ${uri.queryParameters}');
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

    if (mounted) widget.onLoginSuccess(onboardingCompleted);
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _loginWith(String fullUrl) async {
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
                  label: 'Apple로 시작하기',
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  borderColor: const Color(0xFFE1E1E1),
                  onTap: _isLoading
                      ? null
                      : () => _loginWith(
                          OAuthUrls.apple(ref.read(baseUrlProvider)),
                        ),
                ),
                const SizedBox(height: 12),
              ],
              _LoginButton(
                icon: const _GoogleIcon(),
                label: 'Google로 시작하기',
                backgroundColor: Colors.white,
                textColor: Colors.black,
                borderColor: const Color(0xFFE1E1E1),
                onTap: _isLoading
                    ? null
                    : () => _loginWith(
                        OAuthUrls.google(ref.read(baseUrlProvider)),
                      ),
              ),
              const SizedBox(height: 12),
              _LoginButton(
                icon: const _KakaoIcon(),
                label: '카카오로 시작하기',
                backgroundColor: const Color(0xFFFEE500),
                textColor: const Color(0xFF191919),
                onTap: _isLoading
                    ? null
                    : () => _loginWith(
                        OAuthUrls.kakao(ref.read(baseUrlProvider)),
                      ),
              ),
              const SizedBox(height: 22),
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
            const SizedBox(width: 8),
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
// TODO: 실제 SVG 에셋으로 교체 필요
// ============================================================================

class _AppleIcon extends StatelessWidget {
  const _AppleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 28,
      child: CustomPaint(painter: _AppleIconPainter()),
    );
  }
}

class _AppleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final bodyPath = Path()
      ..addOval(Rect.fromLTWH(w * 0.05, h * 0.22, w * 0.45, h * 0.7))
      ..addOval(Rect.fromLTWH(w * 0.50, h * 0.22, w * 0.45, h * 0.7));

    final bitePath = Path()
      ..addOval(Rect.fromLTWH(w * 0.52, h * 0.12, w * 0.5, h * 0.44));

    final applePath = Path.combine(
      PathOperation.difference,
      bodyPath,
      bitePath,
    );
    canvas.drawPath(applePath, paint);

    final stemPath = Path();
    stemPath.moveTo(w * 0.52, h * 0.22);
    stemPath.quadraticBezierTo(w * 0.60, h * 0.04, w * 0.72, h * 0.01);
    stemPath.lineTo(w * 0.74, h * 0.07);
    stemPath.quadraticBezierTo(w * 0.64, h * 0.10, w * 0.57, h * 0.24);
    stemPath.close();
    canvas.drawPath(stemPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 23,
      height: 23,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 3.5;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    arcPaint.color = const Color(0xFFE94235);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -1.57,
      1.57,
      false,
      arcPaint,
    );
    arcPaint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      0.0,
      1.57,
      false,
      arcPaint,
    );
    arcPaint.color = const Color(0xFFFBBC04);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      1.57,
      1.57,
      false,
      arcPaint,
    );
    arcPaint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      3.14,
      1.57,
      false,
      arcPaint,
    );

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx + radius - strokeWidth / 2, center.dy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _KakaoIcon extends StatelessWidget {
  const _KakaoIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      height: 22,
      child: CustomPaint(painter: _KakaoIconPainter()),
    );
  }
}

class _KakaoIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF191919)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final bodyPath = Path()..addOval(Rect.fromLTWH(0, 0, w, h * 0.82));

    final tailPath = Path();
    tailPath.moveTo(w * 0.35, h * 0.72);
    tailPath.lineTo(w * 0.25, h * 1.0);
    tailPath.lineTo(w * 0.55, h * 0.78);
    tailPath.close();

    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(tailPath, paint);

    final eyePaint = Paint()
      ..color = const Color(0xFFFEE500)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.35, h * 0.38), w * 0.07, eyePaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.38), w * 0.07, eyePaint);

    final mouthPaint = Paint()
      ..color = const Color(0xFFFEE500)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final mouthPath = Path();
    mouthPath.moveTo(w * 0.28, h * 0.52);
    mouthPath.quadraticBezierTo(w * 0.50, h * 0.65, w * 0.72, h * 0.52);
    canvas.drawPath(mouthPath, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
