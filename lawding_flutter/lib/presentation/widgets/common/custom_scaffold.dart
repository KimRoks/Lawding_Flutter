import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import 'logo_app_bar.dart';

/// 모든 화면에서 사용하는 공용 Scaffold
///
/// 기본적으로 LogoAppBar를 자동으로 추가하며,
/// appBar 파라미터를 null로 설정하면 AppBar를 숨길 수 있습니다.
///
/// 키보드 관리:
/// - 화면의 빈 공간을 터치하면 키보드가 자동으로 숨겨집니다
/// - 키보드가 나타나면 화면이 자동으로 조정됩니다 (resizeToAvoidBottomInset)
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
  final bool resizeToAvoidBottomInset;
  final bool dismissKeyboardOnTap;

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
    this.resizeToAvoidBottomInset = true,
    this.dismissKeyboardOnTap = true,
  });

  @override
  Widget build(BuildContext context) {
    // appBar가 명시적으로 전달되었으면 그것을 사용
    // 그렇지 않으면 useDefaultAppBar에 따라 기본 LogoAppBar 사용 여부 결정
    final effectiveAppBar = appBar ?? (useDefaultAppBar ? const LogoAppBar() : null);

    return GestureDetector(
      onTap: dismissKeyboardOnTap
          ? () {
              // 키보드가 열려있으면 숨김
              final currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            }
          : null,
      // 빈 공간도 터치 이벤트를 받을 수 있도록 설정
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: backgroundColor ?? AppColors.background,
        appBar: effectiveAppBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        floatingActionButtonLocation: floatingActionButtonLocation,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      ),
    );
  }
}
