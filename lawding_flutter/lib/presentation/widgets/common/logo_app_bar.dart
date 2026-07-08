import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system.dart';
import '../../screens/setting/setting_screen.dart';

/// LawDing 로고를 표시하는 공용 AppBar
class LogoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Color? backgroundColor;

  const LogoAppBar({
    super.key,
    this.actions,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.background,
      surfaceTintColor: backgroundColor ?? AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: 150,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'LawDing',
            style: pretendard(
              weight: 700,
              size: 20,
              color: AppColors.brandColor,
            ),
          ),
        ),
      ),
      actions: [
        ...?actions,
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: SvgPicture.asset(
              'assets/icons/setting.svg',
              width: 24,
              height: 24,
            ),
          ),
        ),
      ],
    );
  }
}
