import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/core/result.dart';
import '../../../infrastructure/services/analytics_service.dart';
import '../../../infrastructure/services/app_version_service.dart';
import '../../../infrastructure/services/crashlytics_service.dart';
import '../../core/design_system.dart';
import '../../providers/providers.dart';
import '../../widgets/force_update_dialog.dart';
import '../auth/login_screen.dart';
import '../basic_info/basic_info_screen.dart';
import '../calendar/calendar_screen.dart';
import '../calendar/calendar_tutorial_screen.dart';
import '../calculator/calculator_screen.dart';
import '../dashboard/dashboard_screen.dart';
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
  final _dictionaryScreenKey = GlobalKey();
  final _calendarScreenKey = GlobalKey<_CalendarTabScreenState>();

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

  Future<void> _restoreAuthState() async {
    final hasToken = await ref.read(authRepositoryProvider).isLoggedIn();
    if (!hasToken) return;

    final result = await ref.read(getUserMeUseCaseProvider).execute();
    result.fold(
      onSuccess: (me) {
        ref.read(dailyWorkMinutesProvider.notifier).state =
            me.leavePolicy.dailyWorkMinutes;
        if (me.user.onboardingCompleted) {
          ref.read(calendarAuthStateProvider.notifier).state = true;
        }
      },
      onFailure: (_) {},
    );
  }

  Future<void> _initializeApp() async {
    try {
      // 저장된 토큰 확인 및 로그인 상태 복원
      final authRepo = ref.read(authRepositoryProvider);
      final accessToken = await authRepo.getAccessToken();
      debugPrint('[Splash] accessToken: $accessToken');

      await _restoreAuthState();

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
          title: '나의 연차',
          icon: Image.asset(
            'assets/icons/dashboard_tabbar_black.png',
            width: 24,
            height: 24,
          ),
          activeIcon: Image.asset(
            'assets/icons/dashboard_tabbar.png',
            width: 24,
            height: 24,
          ),
          screen: DashboardScreen(
            onAuthRequired: () =>
                _calendarScreenKey.currentState?.showTutorialIfNeeded(),
          ),
        ),
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
          screen: DictionaryScreen(key: _dictionaryScreenKey),
          onTabActivated: () {
            // 탭이 활성화되면 DictionaryScreen의 onTabActivated 메서드 호출
            final state = _dictionaryScreenKey.currentState;
            if (state != null && state.mounted) {
              (state as TabActivationMixin).onTabActivated();
            }
          },
        ),
        TabItemInfo(
          title: '연차 캘린더',
          icon: Image.asset(
            'assets/icons/calendar_tabbar_black.png',
            width: 24,
            height: 24,
          ),
          activeIcon: Image.asset(
            'assets/icons/calendar_tabbar.png',
            width: 24,
            height: 24,
          ),
          screen: _CalendarTabScreen(key: _calendarScreenKey),
          onTabActivated: () {
            _calendarScreenKey.currentState?.showTutorialIfNeeded();
            _calendarScreenKey.currentState?.refreshCalendar();
          },
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

// 캘린더 탭 진입 시 로그인 여부를 확인하고 적절한 화면을 표시하는 래퍼
class _CalendarTabScreen extends ConsumerStatefulWidget {
  const _CalendarTabScreen({super.key});

  @override
  ConsumerState<_CalendarTabScreen> createState() => _CalendarTabScreenState();
}

class _CalendarTabScreenState extends ConsumerState<_CalendarTabScreen> {
  bool _tutorialShown = false;
  bool _isLoading = false;

  static const _tutorialKey = 'calendar_tutorial_shown';

  @override
  void initState() {
    super.initState();
    _loadTutorialShown();
  }

  Future<void> _loadTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) _tutorialShown = prefs.getBool(_tutorialKey) ?? false;
  }

  Future<void> showTutorialIfNeeded() async {
    if (!mounted) return;
    if (ref.read(calendarAuthStateProvider)) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final hasToken = await ref.read(authRepositoryProvider).isLoggedIn();
      if (!mounted) return;

      if (hasToken) {
        debugPrint('[Calendar] GET /v1/users/me 호출');
        final result = await ref.read(getUserMeUseCaseProvider).execute();
        if (!mounted) return;

        result.fold(
          onSuccess: (me) {
            debugPrint('[Calendar] me 응답:');
            debugPrint('  id                  : ${me.user.id}');
            debugPrint('  nickname            : ${me.user.nickname}');
            debugPrint('  onboardingCompleted : ${me.user.onboardingCompleted}');
            ref.read(dailyWorkMinutesProvider.notifier).state =
                me.leavePolicy.dailyWorkMinutes;
            if (me.user.onboardingCompleted) {
              ref.read(calendarAuthStateProvider.notifier).state = true;
              setState(() => _isLoading = false);
            } else {
              setState(() => _isLoading = false);
              _showBasicInfoScreen();
            }
          },
          onFailure: (error) {
            debugPrint('[Calendar] me 실패: $error');
            setState(() => _isLoading = false);
            _showLoginScreen();
          },
        );
        return;
      }

      // 비로그인: 튜토리얼(최초 1회) → 로그인 화면
      setState(() => _isLoading = false);
      if (!_tutorialShown) {
        _tutorialShown = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_tutorialKey, true);
        if (!mounted) return;
        bool proceeded = false;
        await Navigator.of(context, rootNavigator: true).push(
          PageRouteBuilder(
            opaque: true,
            pageBuilder: (context, animation, secondaryAnimation) =>
                CalendarTutorialScreen(
                  onFinished: () {
                    proceeded = true;
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        );
        if (!mounted) return;
        if (proceeded) _showLoginScreen();
      } else {
        _showLoginScreen();
      }
    } catch (e) {
      debugPrint('[Calendar] showTutorialIfNeeded 에러: $e');
      if (mounted) setState(() => _isLoading = false);
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showBasicInfoScreen() {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            BasicInfoScreen(onCompleted: _onUserInfoCompleted),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _showLoginScreen() {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            LoginScreen(onLoginSuccess: _onLoginSuccess),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  Future<void> _fetchUserMe() async {
    final result = await ref.read(getUserMeUseCaseProvider).execute();
    result.fold(
      onSuccess: (me) {
        ref.read(dailyWorkMinutesProvider.notifier).state =
            me.leavePolicy.dailyWorkMinutes;
      },
      onFailure: (error) => debugPrint('[UserMe] 실패: $error'),
    );
  }

  void _onLoginSuccess(bool onboardingCompleted) {
    Navigator.of(context, rootNavigator: true).pop();

    if (onboardingCompleted) {
      _fetchUserMe();
      ref.read(calendarAuthStateProvider.notifier).state = true;
    } else {
      Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) =>
              BasicInfoScreen(onCompleted: _onUserInfoCompleted),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) =>
                  FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  }

  void refreshCalendar() {
    ref.read(leaveDataRefreshProvider.notifier).state++;
  }

  void _onUserInfoCompleted() {
    Navigator.of(context, rootNavigator: true).pop();
    _fetchUserMe();
    ref.read(calendarAuthStateProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(calendarAuthStateProvider);
    if (isLoggedIn) return const CalendarScreen();
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return _buildLoginPrompt();
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '로그인이 필요한 서비스입니다.',
            style: pretendard(
              weight: 600,
              size: 16,
              color: AppColors.textGray55,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: showTutorialIfNeeded,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.brandColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '로그인하기',
                style: pretendard(
                  weight: 700,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
