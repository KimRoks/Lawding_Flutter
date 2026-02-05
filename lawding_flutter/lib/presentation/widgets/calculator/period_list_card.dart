import 'package:flutter/material.dart';

import '../../core/design_system.dart';
import '../common/add_button.dart';
import '../common/badge_label.dart';
import '../common/card_container.dart';
import '../common/help_button.dart';
import 'period_list_item.dart';

class PeriodListCard extends StatelessWidget {
  final String title;
  final List<PeriodItem> items;
  final VoidCallback onAddTap;
  final ValueChanged<int> onDeleteItem;
  final VoidCallback? onHelpTap;

  const PeriodListCard({
    super.key,
    required this.title,
    required this.items,
    required this.onAddTap,
    required this.onDeleteItem,
    this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    // items가 없을 때 Stack 내부 컨텐츠 높이
    // = title font(20) + spacing(4) + badge(16) + 하단spacing(2)
    const double emptyContentHeight = 20 + 4 + 16 + 2; // = 42
    const double buttonHeight = 26;

    return CardContainer(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title, style: pretendard(weight: 700, size: 20)),
                  const SizedBox(width: 8),
                  HelpButton(onTap: onHelpTap),
                  const SizedBox(width: 80), // AddButton 공간 확보
                ],
              ),
              const SizedBox(height: 4),
              const BadgeLabel(text: '선택사항'),
              if (items.isEmpty) const SizedBox(height: 2), // 하단 여백 22px 맞추기
              if (items.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...List.generate(items.length, (index) {
                  final item = items[index];
                  return Padding(
                    padding: EdgeInsets.only(top: index > 0 ? 8 : 0),
                    child: PeriodListItem(
                      title: item.title,
                      duration: item.duration,
                      onDelete: () => onDeleteItem(index),
                    ),
                  );
                }),
              ],
            ],
          ),
          // items가 없을 때 컨텐츠 높이의 centerY에 버튼 배치
          // items가 추가되어도 이 위치에 고정
          Positioned(
            right: 0,
            top: emptyContentHeight / 2 - buttonHeight / 2, // = 21 - 13 = 8
            child: AddButton(text: '추가하기', onTap: onAddTap),
          ),
        ],
      ),
    );
  }
}

class PeriodItem {
  final String title;
  final String duration;

  const PeriodItem({required this.title, required this.duration});
}
