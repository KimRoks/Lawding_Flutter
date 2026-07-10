import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system.dart';
import '../../providers/providers.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/toast_message.dart';
import '../basic_info/basic_info_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: const CustomAppBar(
        title: '설정',
        backgroundColor: Color(0xFFFBFBFB),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 35),
            const _SettingRow(title: '계정 센터'),
            _SettingRow(
              title: '연차 정보 수정',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BasicInfoScreen(
                    isEditMode: true,
                    onCompleted: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
            // const _SettingRow(title: '알림설정(Beta)'),
            // const _SettingRow(title: '캘린더 설정'),
            // const _SettingRow(title: '데이터 설정'),
            // const _SettingRow(title: '기타'),
            const SizedBox(height: 40),
            const _LogoutButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// 메뉴 row — 각각 독립 위젯이므로 불필요한 항목은 자유롭게 제거 가능
// ──────────────────────────────────────────────────────────

class _SettingRow extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _SettingRow({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          SizedBox(
            height: 70,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: pretendard(
                    weight: 500,
                    size: 17,
                    color: const Color(0xFF999999),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Container(height: 1, color: const Color(0xFFE1E1E1)),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// 로그아웃 버튼
// ──────────────────────────────────────────────────────────

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showCupertinoDialog<bool>(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('로그아웃'),
            content: const Text('로그아웃 하시겠습니까?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('로그아웃'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await ref.read(authRepositoryProvider).clearTokens();
          if (!context.mounted) return;
          ref.read(calendarAuthStateProvider.notifier).state = false;
          ToastManager().show(context, '로그아웃 되었습니다');
          ref.read(activeTabIndexProvider.notifier).state = 0;
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '로그아웃',
            style: pretendard(
              weight: 700,
              size: 16,
              color: const Color(0xFF999999),
            ),
          ),
        ),
      ),
    );
  }
}
