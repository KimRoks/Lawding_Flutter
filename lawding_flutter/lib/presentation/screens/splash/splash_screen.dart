import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/core/result.dart';
import '../../../infrastructure/services/analytics_service.dart';
import '../../../infrastructure/services/app_version_service.dart';
import '../../../infrastructure/services/crashlytics_service.dart';
import '../../providers/providers.dart';
import '../../widgets/force_update_dialog.dart';
import '../calculator/calculator_screen.dart';
import '../dictionary/dictionary_screen.dart';
import '../main/main_tab_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final _analytics = AnalyticsService();
  final _crashlytics = CrashlyticsService();
  final _appVersionService = AppVersionService();
  final _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// 앱 버전 체크
  Future<void> _checkAppVersion() async {
    try {
      final versionRepository = ref.read(appVersionRepositoryProvider);
      final currentVersion = await _appVersionService.getCurrentVersion();
      final platform = _appVersionService.getPlatform();

      final result = await versionRepository.checkVersion(
        platform: platform,
        currentVersion: currentVersion,
      );

      switch (result) {
        case Success(:final value):
          if (value.forceUpdate && mounted) {
            await ForceUpdateDialog.show(
              context,
              updateMessage: value.updateMessage,
            );
          }
          break;
        case Failure(:final error):
          await _crashlytics.log('Version check failed: $error');
          break;
      }
    } catch (e) {
      await _crashlytics.log('Version check failed: $e');
    }
  }

  Future<void> _initializeApp() async {
    try {
      // 이전 세션에서 크래시가 발생했는지 확인
      final didCrash = await _crashlytics.didCrashOnPreviousExecution();
      if (didCrash) {
        await _crashlytics.log('App crashed in previous session');
      }

      // 앱 버전 체크
      await _checkAppVersion();

      // 1.5초 대기
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      // 스플래시 완료 이벤트 기록
      final duration = DateTime.now().difference(_startTime).inMilliseconds;
      await _analytics.logSplashCompleted(duration);

      if (!mounted) return;

      // 페이드 아웃과 함께 화면 전환
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              _buildMainScreen(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e, stack) {
      // 초기화 중 에러 발생 시 기록
      await _crashlytics.recordError(
        e,
        stack,
        reason: 'Splash initialization failed',
      );
      // 에러가 발생해도 앱은 계속 진행
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => _buildMainScreen()),
        );
      }
    }
  }

  Widget _buildMainScreen() {
    return MainTabScreen(
      tabs: [
        TabItemInfo(
          title: '연차 계산기',
          icon: Image.asset(
            'assets/icons/calculator_outlined.png',
            width: 24,
            height: 24,
          ),
          activeIcon: Image.asset(
            'assets/icons/calculator.png',
            width: 24,
            height: 24,
          ),
          screen: const CalculatorScreen(),
        ),
        TabItemInfo(
          title: '연차 사전',
          icon: Image.asset(
            'assets/icons/dictionary_outlined.png',
            width: 24,
            height: 24,
          ),
          activeIcon: Image.asset(
            'assets/icons/dictionary.png',
            width: 24,
            height: 24,
          ),
          screen: const DictionaryScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Center(
        child: Image.asset(
          'assets/icons/LaunchScreen.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
