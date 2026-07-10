import 'package:flutter/material.dart';

import '../../core/design_system.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.actions,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final routeDepth = ModalRoute.of(context)?.settings.name != null ? 2 : 1;
    final shouldShowBackButton = canPop || routeDepth >= 2;

    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.background,
      surfaceTintColor: backgroundColor ?? AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: shouldShowBackButton ? 90 : null,
      leading: shouldShowBackButton
          ? GestureDetector(
              onTap: onBack ?? () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Image.asset(
                    'assets/icons/back.png',
                    width: 18,
                    height: 18,
                    color: AppColors.brandColor,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '뒤로',
                    style: pretendard(
                      weight: 700,
                      size: 20,
                      color: AppColors.brandColor,
                    ),
                  ),
                ],
              ),
            )
          : null,
      title: Text(
        title,
        style: pretendard(weight: 700, size: 20, color: AppColors.brandColor),
      ),
      centerTitle: true,
      actions: actions,
    );
  }
}
