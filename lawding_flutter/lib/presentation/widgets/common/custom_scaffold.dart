import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import 'logo_app_bar.dart';

/// 모든 화면에서 사용하는 공용 Scaffold
///
/// 기본적으로 LogoAppBar를 자동으로 추가하며,
/// appBar 파라미터를 null로 설정하면 AppBar를 숨길 수 있습니다.
class CustomScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool useDefaultAppBar;

  const CustomScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.floatingActionButtonLocation,
    this.useDefaultAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: useDefaultAppBar ? (appBar ?? const LogoAppBar()) : appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
