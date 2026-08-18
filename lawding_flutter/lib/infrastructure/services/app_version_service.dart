import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppVersionService {
  static final AppVersionService _instance = AppVersionService._internal();
  factory AppVersionService() => _instance;
  AppVersionService._internal();

  /// 현재 앱 버전 가져오기
  Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version; // 예: "1.2.0"
  }

  /// 현재 빌드 번호 가져오기
  Future<String> getCurrentBuildNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber; // 예: "1"
  }

  /// 플랫폼 확인 (ios 또는 android)
  String getPlatform() {
    if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isAndroid) {
      return 'android';
    } else {
      return 'unknown';
    }
  }

  // 앱 스토어 ID
  static const String _iosAppId = '6751892414';
  static const String _androidPackageName = 'com.lawding.annualleavecalculator';

  /// 앱 스토어로 이동
  /// 플랫폼에 맞는 스토어 URL을 자동으로 생성하여 이동
  Future<bool> openAppStore() async {
    Uri storeUrl;

    if (Platform.isIOS) {
      // iOS App Store URL
      storeUrl = Uri.parse('https://apps.apple.com/app/id$_iosAppId');
    } else if (Platform.isAndroid) {
      // Android Play Store URL
      storeUrl = Uri.parse('https://play.google.com/store/apps/details?id=$_androidPackageName');
    } else {
      return false;
    }

    if (await canLaunchUrl(storeUrl)) {
      return await launchUrl(
        storeUrl,
        mode: LaunchMode.externalApplication,
      );
    }

    return false;
  }

  /// 버전 비교 (a < b 이면 음수 반환)
  /// 예: compareVersions("1.2.0", "1.3.0") => -1
  /// 예: compareVersions("1.3.0", "1.2.0") => 1
  /// 예: compareVersions("1.2.0", "1.2.0") => 0
  int compareVersions(String currentVersion, String minimumVersion) {
    final current = currentVersion.split('.').map(int.parse).toList();
    final minimum = minimumVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final currentPart = i < current.length ? current[i] : 0;
      final minimumPart = i < minimum.length ? minimum[i] : 0;

      if (currentPart < minimumPart) return -1;
      if (currentPart > minimumPart) return 1;
    }

    return 0;
  }

  /// 강제 업데이트 필요 여부 확인
  /// [minimumVersion]: 서버에서 받아온 최소 버전 (예: "1.3.0")
  /// 반환: true이면 업데이트 필요, false이면 불필요
  Future<bool> isUpdateRequired(String minimumVersion) async {
    final currentVersion = await getCurrentVersion();
    return compareVersions(currentVersion, minimumVersion) < 0;
  }
}
