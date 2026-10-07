import 'dart:io';

import 'package:home_widget/home_widget.dart';

class WidgetService {
  /// iOS home_widget 0.7.0은 null(NSNull)을 UserDefaults에 넣으면 크래시나므로
  /// iOS에서는 null 대신 빈 문자열을 저장한다. 위젯 extension의 loadEntry가 ""를 nil로 환원한다.
  /// Android는 null이 키 삭제로 정상 동작하므로 그대로 전달한다.
  static Future<bool?> save(String key, Object? value) {
    if (value == null && Platform.isIOS) {
      return HomeWidget.saveWidgetData<String>(key, '');
    }
    return HomeWidget.saveWidgetData(key, value);
  }
}
