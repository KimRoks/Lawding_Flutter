import 'package:flutter/material.dart';

import '../../core/design_system.dart';

enum DateDisplayMode {
  full, // YYYY.MM.DD 형식 + 캘린더 아이콘
  monthDay, // n월 1일 형식, 아이콘 없음
}

class DateButton extends StatelessWidget {
  final String placeholder;
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final DateDisplayMode displayMode;

  const DateButton({
    super.key,
    required this.placeholder,
    this.selectedDate,
    required this.onTap,
    this.displayMode = DateDisplayMode.full,
  });

  String _formatDate(DateTime date) {
    if (displayMode == DateDisplayMode.monthDay) {
      return '${date.month}월 1일'; // 항상 1일로 고정
    }
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hasDate = selectedDate != null;
    final showIcon = displayMode == DateDisplayMode.full;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 144,
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              Image.asset(
                'assets/icons/calendar.png',
                width: 16,
                height: 16,
                color: hasDate
                    ? AppColors.primaryTextColor
                    : AppColors.secondaryTextColor,
              ),
              const SizedBox(width: 7),
            ],
            Flexible(
              child: Text(
                hasDate ? _formatDate(selectedDate!) : placeholder,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: pretendard(weight: 500, size: 15).copyWith(
                  color: hasDate
                      ? AppColors.primaryTextColor
                      : AppColors.secondaryTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
