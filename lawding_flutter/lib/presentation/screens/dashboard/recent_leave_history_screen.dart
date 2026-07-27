import 'package:flutter/material.dart';

import '../../../domain/entities/leave_dashboard.dart';
import '../../core/design_system.dart';
import '../../widgets/common/custom_app_bar.dart';

class RecentLeaveHistoryScreen extends StatelessWidget {
  final List<RecentLeaveUsage> usages;

  const RecentLeaveHistoryScreen({super.key, required this.usages});

  String _formatMonthDay(String isoDatetime) {
    final dateStr = isoDatetime.split('T').first;
    final parts = dateStr.split('-');
    if (parts.length != 3) return isoDatetime;
    final month = int.tryParse(parts[1]) ?? 0;
    final day = int.tryParse(parts[2]) ?? 0;
    return '$month월 $day일';
  }

  String _hoursLabel(int minutes) {
    final h = (minutes / 60).round();
    return '연차($h시간)';
  }

  int _monthsCount() {
    if (usages.isEmpty) return 0;
    final oldest = usages.reduce(
      (a, b) => a.startDatetime.compareTo(b.startDatetime) < 0 ? a : b,
    );
    final oldestDate = DateTime.parse(oldest.startDatetime.split('T').first);
    final now = DateTime.now();
    return (now.year - oldestDate.year) * 12 + (now.month - oldestDate.month);
  }

  @override
  Widget build(BuildContext context) {
    if (usages.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: '최근 연차 사용 내역'),
        body: Center(
          child: Text(
            '최근 사용된 연차가 없습니다',
            style: pretendard(
              weight: 500,
              size: 13,
              color: AppColors.textGray55,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: '최근 연차 사용 내역'),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: usages.length,
              separatorBuilder: (_, _) => const Divider(
                color: Color(0xFFF1F1F1),
                thickness: 1,
                height: 1,
              ),
              itemBuilder: (_, i) => _buildItem(usages[i]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              '최근 ${_monthsCount()}개월간의 사용내역입니다.',
              style: pretendard(
                weight: 500,
                size: 16,
                color: AppColors.textGray99,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(RecentLeaveUsage usage) {
    final startDate = _formatMonthDay(usage.startDatetime);
    final endDate = _formatMonthDay(usage.endDatetime);
    final dateLabel = startDate == endDate ? startDate : '$startDate-$endDate';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              dateLabel,
              style: pretendard(
                weight: 600,
                size: 16,
                color: const Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildBadge(_hoursLabel(usage.usedLeaveMinutes)),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFCFE6FF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: pretendard(weight: 700, size: 8, color: AppColors.brandColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}
