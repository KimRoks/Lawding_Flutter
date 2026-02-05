import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 색상 상수
///
/// 사용법:
/// ```dart
/// import '../../core/app_colors.dart';
///
/// // 자주 사용되는 색상은 const로 정의됨
/// color: AppColors.brandColor
/// color: AppColors.background
///
/// // 일회성 색상은 hex() 함수 사용
/// color: hex('#FF5733')
/// ```
class AppColors {
  AppColors._();

  // ============================================================================
  // Brand Colors
  // ============================================================================
  static const Color brandColor = Color(0xFF0057B8);
  static const Color brandLight = Color(0xFFCFE6FF);

  // ============================================================================
  // Text Colors
  // ============================================================================
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textTertiary = Color(0xFF777777);
  static const Color textDisabled = Color(0xFFCCCCCC);
  static const Color textHint = Color(0xFFDADADA);

  // ============================================================================
  // Background Colors
  // ============================================================================
  static const Color background = Color(0xFFFBFBFB);
  static const Color backgroundLight = Color(0xFFF6F6F6);
  static const Color backgroundCard = Color(0xFFF5F5F5);
  static const Color backgroundField = Color(0xFFF7F7F7);
  static const Color backgroundChip = Color(0xFFF1F1F1);

  // ============================================================================
  // Border & Divider Colors
  // ============================================================================
  static const Color border = Color(0xFFE1E1E1);
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // ============================================================================
  // Misc Colors
  // ============================================================================
  static const Color shadow = Color(0x0A000000); // black 4%
  static const Color overlay = Color(0x80000000); // black 50%
  static const Color switchInactive = Color(0xFFD9D9D9);
  static const Color highlight = Color(0xFFFFFA99);
  static const Color iconInactive = Color(0xFFC9C9C9);

  // ============================================================================
  // Legacy (for backwards compatibility)
  // ============================================================================
  static const Color primaryTextColor = textPrimary;
  static const Color secondaryTextColor = textSecondary;
}

/// Hex 문자열을 Color로 변환
///
/// Example:
/// ```dart
/// Container(color: hex('#FBFBFB'))
/// Text('Hello', style: TextStyle(color: hex('#999999')))
/// ```
Color hex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

/// Color extension for hex conversion
extension HexColor on Color {
  /// #RRGGBB 또는 #AARRGGBB 형식의 Hex 문자열을 Color로 변환
  static Color fromHex(String hexString) => hex(hexString);

  /// Color를 #AARRGGBB 형식의 Hex 문자열로 변환
  String toHex({bool leadingHashSign = true}) {
    final a = (this.a * 255.0).round().clamp(0, 255);
    final r = (this.r * 255.0).round().clamp(0, 255);
    final g = (this.g * 255.0).round().clamp(0, 255);
    final b = (this.b * 255.0).round().clamp(0, 255);

    return '${leadingHashSign ? '#' : ''}'
        '${a.toRadixString(16).padLeft(2, '0')}'
        '${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }
}
