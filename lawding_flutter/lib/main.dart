import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'infrastructure/services/analytics_service.dart';
import 'infrastructure/services/crashlytics_service.dart';
import 'presentation/core/app_colors.dart';
import 'presentation/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await CrashlyticsService().initialize();

  await AnalyticsService().logAppLaunched();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        // 테마 brightness 기반으로 status bar 아이콘 색상 자동 결정
        // 라이트 모드 → 다크 아이콘 / 다크 모드 → 라이트 아이콘
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          child: child!,
        );
      },
      navigatorObservers: [AnalyticsService().getAnalyticsObserver()],
      home: const SplashScreen(),
    );
  }
}
