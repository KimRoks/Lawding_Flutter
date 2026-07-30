import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/core/result.dart';
import '../../core/design_system.dart';
import '../../providers/providers.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/toast_message.dart';
import 'change_nickname_screen.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // TODO: 연차 정보 수정 기능은 현재 사용하지 않으므로 주석 처리
            // _SettingRow(
            //   title: '연차 정보 수정',
            //   onTap: () => Navigator.of(context).push(
            //     MaterialPageRoute(
            //       builder: (_) => BasicInfoScreen(
            //         isEditMode: true,
            //         onCompleted: () async {
            //           Navigator.of(context).pop();
            //           final result = await ref
            //               .read(getLeaveSummaryUseCaseProvider)
            //               .execute();
            //           if (result case Success(:final value)) {
            //             ref.read(avgDailyWorkHoursProvider.notifier).state =
            //                 value.avgDailyWorkHours;
            //           }
            //           ref.read(leaveDataRefreshProvider.notifier).state++;
            //         },
            //       ),
            //     ),
            //   ),
            // ),
            _SettingRow(
              title: '닉네임 변경',
              onTap: () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const ChangeNicknameScreen(),
                  ),
                );
                if (changed == true) {
                  ref.read(leaveDataRefreshProvider.notifier).state++;
                }
              },
            ),
            _SettingRow(
              title: '계정 탈퇴',
              textColor: const Color(0xFFFF5252),
              onTap: () async {
                final confirmed = await showCupertinoDialog<bool>(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: const Text('계정 탈퇴'),
                    content: const Text(
                      '탈퇴하시면 모든 데이터가 삭제되며\n복구할 수 없습니다.\n정말 탈퇴하시겠습니까?',
                    ),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('취소'),
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('탈퇴'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;
                final result = await ref
                    .read(deleteAccountUseCaseProvider)
                    .execute();
                if (!context.mounted) return;
                if (result case Failure()) {
                  ToastManager().show(
                    context,
                    '탈퇴 처리 중 오류가 발생했습니다. 다시 시도해주세요.',
                  );
                  return;
                }
                await ref.read(authRepositoryProvider).clearTokens();
                if (!context.mounted) return;
                ref.read(calendarAuthStateProvider.notifier).state = false;
                ref.read(activeTabIndexProvider.notifier).state = 0;
                Navigator.of(context).popUntil((route) => route.isFirst);
                ToastManager().show(context, '탈퇴가 완료되었습니다');
              },
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
  final Color? textColor;

  const _SettingRow({required this.title, this.onTap, this.textColor});

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
                    color: textColor ?? const Color(0xFF999999),
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
