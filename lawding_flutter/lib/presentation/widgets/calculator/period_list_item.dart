import 'package:flutter/material.dart';

import '../../core/design_system.dart';

class PeriodListItem extends StatelessWidget {
  final String title;
  final String duration;
  final VoidCallback onDelete;

  const PeriodListItem({
    super.key,
    required this.title,
    required this.duration,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: pretendard(weight: 700, size: 12)),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: pretendard(
                    size: 12,
                    weight: 500,
                    color: AppColors.textGray99,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Text(
                '삭제',
                style: pretendard(
                  size: 12,
                  weight: 700,
                  color: AppColors.textGrayDA,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
