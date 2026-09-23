import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'firebase_options.dart';
import 'infrastructure/services/analytics_service.dart';
import 'infrastructure/services/crashlytics_service.dart';
import 'presentation/core/app_colors.dart';
import 'presentation/providers/providers.dart';
import 'presentation/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await CrashlyticsService().initialize();

  await AnalyticsService().logAppLaunched();

  HomeWidget.setAppGroupId('group.com.lawding.annualleavecalculator');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  StreamSubscription<Uri>? _deepLinkSub;
  DateTime? _lastAddCalendarHandled;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshWidgets();
    }
  }

  Future<void> _refreshWidgets() async {
    await HomeWidget.updateWidget(androidName: 'LawdingWidgetProvider', iOSName: 'LawdingWidget');
    await HomeWidget.updateWidget(androidName: 'LawdingWidgetMediumProvider', iOSName: 'LawdingWidget');
    await HomeWidget.updateWidget(androidName: 'LawdingWidgetCalendarProvider', iOSName: 'LawdingCalendarWidget');
    await HomeWidget.updateWidget(androidName: 'LawdingWidgetNextProvider', iOSName: 'LawdingNextWidget');
    await HomeWidget.updateWidget(androidName: 'LawdingWidgetLargeProvider', iOSName: 'LawdingLargeWidget');
  }

  Future<void> _initDeepLinks() async {
    final appLinks = AppLinks();
    // cold start: 앱 미실행 상태에서 딥링크로 열린 경우
    final initialLink = await appLinks.getInitialLink();
    if (initialLink != null) _handleDeepLink(initialLink);
    // background/foreground: 앱 실행 중 딥링크 수신
    _deepLinkSub = appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deepLinkSub?.cancel();
    super.dispose();
  }

  void _handleDeepLink(Uri uri) {
    if (uri.host != 'add-calendar') return;
    // cold start 시 getInitialLink + uriLinkStream 중복 수신 방지
    final now = DateTime.now();
    if (_lastAddCalendarHandled != null &&
        now.difference(_lastAddCalendarHandled!).inSeconds < 3) return;
    _lastAddCalendarHandled = now;
    ref.read(activeTabIndexProvider.notifier).state = 3;
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lawding',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryTextColor,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.brandColor,
        fontFamily: 'Pretendard',
      ),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: child!,
        );
      },
      navigatorObservers: [AnalyticsService().getAnalyticsObserver()],
      home: const SplashScreen(),
    );
  }
}
