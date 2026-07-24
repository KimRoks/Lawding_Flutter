import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../domain/core/result.dart';
import '../../../domain/entities/leave_dashboard.dart';
import '../../core/design_system.dart';
import '../../providers/providers.dart';
import '../../widgets/common/logo_app_bar.dart';
import 'recent_leave_history_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final VoidCallback? onAuthRequired;
  const DashboardScreen({super.key, this.onAuthRequired});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  LeaveDashboard? _dashboard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    final result = await ref.read(getLeaveDashboardUseCaseProvider).execute();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result case Success(:final value)) {
        _dashboard = value;
      }
    });
  }

  double _toDays(int minutes) {
    final d = _dashboard;
    if (d == null || d.avgDailyWorkHours <= 0) return 0;
    return (minutes / 60) / d.avgDailyWorkHours;
  }

  String _formatDays(double days) => '${days.toStringAsFixed(3)}일';

  /// "YYYY-MM-DD" → "M월 D일"
  String _formatMonthDay(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    final month = int.tryParse(parts[1]) ?? 0;
    final day = int.tryParse(parts[2]) ?? 0;
    return '$month월 $day일';
  }

  @override
  Widget build(BuildContext context) {
    final isCalendarLinked = ref.watch(calendarAuthStateProvider);

    ref.listen(calendarAuthStateProvider, (prev, next) {
      if (prev == next) return;
      if (next) {
        setState(() => _isLoading = true);
        _fetchDashboard();
      } else {
        setState(() {
          _dashboard = null;
          _isLoading = false;
        });
      }
    });

    ref.listen(leaveDataRefreshProvider, (prev, next) {
      if (prev == next) return;
      setState(() => _isLoading = true);
      _fetchDashboard();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LogoAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMainCard(),
                  const SizedBox(height: 18),
                  _buildQuickActions(),
                  const SizedBox(height: 16),
                  _buildInfoCardsRow(isCalendarLinked),
                  const SizedBox(height: 16),
                  _buildRecentHistoryCard(isCalendarLinked),
                  // TODO: 추천 일정 API 준비 후 활성화
                  // const SizedBox(height: 13),
                  // _buildRecommendCard(),
                ],
              ),
            ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // 연차 대시보드 메인 카드
  // ────────────────────────────────────────────────────────────────
  Widget _buildMainCard() {
    final d = _dashboard;
    final availableDays = d != null ? _toDays(d.availableLeaveMinutes) : 0.0;
    final totalDays = d != null ? _toDays(d.totalLeaveMinutes) : 0.0;
    final usageRate = (d != null && d.totalLeaveMinutes > 0)
        ? (d.totalLeaveMinutes - d.availableLeaveMinutes) / d.totalLeaveMinutes
        : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(17, 20, 17, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '사용 가능 연차',
                style: pretendard(
                  weight: 700,
                  size: 20,
                  color: AppColors.textGray11,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textGray99),
                  borderRadius: BorderRadius.circular(12.5),
                ),
                child: Text(
                  d?.leaveAccrualBasis == 2 ? '회계연도 기준' : '입사일 기준',
                  style: pretendard(
                    weight: 700,
                    size: 11,
                    color: AppColors.textGray99,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            d != null ? _formatDays(availableDays) : '--일',
            style: pretendard(
              weight: 700,
              size: 40,
              color: AppColors.brandColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '총 발생 연차',
            style: pretendard(
              weight: 500,
              size: 12,
              color: AppColors.textGray99,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            d != null ? _formatDays(totalDays) : '--일',
            style: pretendard(
              weight: 700,
              size: 18,
              color: AppColors.textGray99,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '연차 사용률',
                style: pretendard(
                  weight: 700,
                  size: 14,
                  color: AppColors.brandColor,
                ),
              ),
              Text(
                '${(usageRate * 100).toStringAsFixed(1)}%',
                style: pretendard(
                  weight: 700,
                  size: 14,
                  color: AppColors.brandColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          _buildProgressBar(usageRate),
          if (d != null) ...[
            const SizedBox(height: 8),
            Text(
              '사용가능기간 : ${d.leavePeriodStartDate} ~ ${d.leavePeriodEndDate}',
              style: pretendard(
                weight: 600,
                size: 12,
                color: AppColors.textGray99,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(double ratio) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            Container(
              height: 10,
              width: constraints.maxWidth * ratio.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: AppColors.brandColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────────────
  // 빠른 액션 버튼 2개
  // ────────────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: '연차 계산하기',
            onTap: () => ref.read(activeTabIndexProvider.notifier).state = 1,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            label: '캘린더 보기',
            onTap: () => ref.read(activeTabIndexProvider.notifier).state = 3,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: pretendard(weight: 700, size: 16, color: AppColors.brandColor),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // 다음 예정 연차 + 소멸 예정 연차 (딤 대상)
  // ────────────────────────────────────────────────────────────────
  Widget _buildInfoCardsRow(bool isLinked) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildNextLeaveCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildExpiringLeaveCard()),
      ],
    );
    return _wrapWithDim(isLinked: isLinked, child: row);
  }

  Widget _buildNextLeaveCard() {
    final nextEvent = ref.watch(nextLeaveEventProvider);

    String mainText;
    String subText;

    if (nextEvent != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final eventDay = DateTime(
        nextEvent.startDatetime.year,
        nextEvent.startDatetime.month,
        nextEvent.startDatetime.day,
      );
      final daysUntil = eventDay.difference(today).inDays;
      final hours = (nextEvent.usedLeaveMinutes / 60).round();
      final datePart =
          '${nextEvent.startDatetime.month}월 ${nextEvent.startDatetime.day}일';

      mainText = 'D-$daysUntil';
      subText = hours > 0 ? '$datePart $hours시간 사용 예정' : '$datePart 사용 예정';
    } else {
      mainText = '-';
      subText = '예정된 연차가 없습니다';
    }

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '다음 예정 연차',
            style: pretendard(
              weight: 700,
              size: 18,
              color: AppColors.textGray11,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            mainText,
            style: pretendard(
              weight: 700,
              size: 26,
              color: AppColors.textGray11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subText,
            style: pretendard(
              weight: 500,
              size: 13,
              color: AppColors.textGray55,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringLeaveCard() {
    final d = _dashboard;
    final expiringDays = d != null ? _toDays(d.expiringLeaveMinutes) : null;
    final expiryLabel = d != null
        ? '미사용시 ${_formatMonthDay(d.leavePeriodEndDate)} 소멸'
        : null;

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '소멸 예정 연차',
            style: pretendard(
              weight: 700,
              size: 18,
              color: AppColors.textGray11,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            expiringDays != null ? _formatDays(expiringDays) : '—',
            style: pretendard(
              weight: 700,
              size: 26,
              color: AppColors.textGray11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            expiryLabel ?? '—',
            style: pretendard(
              weight: 600,
              size: 11,
              color: AppColors.textGray55,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // 최근 연차 사용 내역 (딤 대상)
  // ────────────────────────────────────────────────────────────────
  Widget _buildRecentHistoryCard(bool isLinked) {
    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 연차 사용 내역',
                  style: pretendard(
                    weight: 700,
                    size: 20,
                    color: AppColors.textGray11,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecentLeaveHistoryScreen(
                        usages: _dashboard?.recentLeaveUsages ?? [],
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '상세보기',
                        style: pretendard(
                          weight: 700,
                          size: 14,
                          color: AppColors.textGray99,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppColors.textGray99,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, thickness: 1, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: _buildRecentUsageRows(),
          ),
        ],
      ),
    );
    return _wrapWithDim(isLinked: isLinked, child: card);
  }

  Widget _buildRecentUsageRows() {
    final usages = _dashboard?.recentLeaveUsages;
    if (usages == null || usages.isEmpty) {
      return Center(
        child: Text(
          '최근 사용된 연차가 없습니다',
          style: pretendard(weight: 500, size: 13, color: AppColors.textGray55),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Column(
      children: usages.take(3).toList().asMap().entries.map((entry) {
        final i = entry.key;
        final u = entry.value;
        final startDate = _formatMonthDay(u.startDatetime.split('T').first);
        final endDate = _formatMonthDay(u.endDatetime.split('T').first);
        final dateLabel = startDate == endDate
            ? startDate
            : '$startDate - $endDate';
        final hours = (u.usedLeaveMinutes / 60).toStringAsFixed(1);
        return Padding(
          padding: EdgeInsets.only(bottom: i < usages.length - 1 ? 16 : 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateLabel,
                style: pretendard(
                  weight: 700,
                  size: 14,
                  color: AppColors.textGray55,
                ),
              ),
              Text(
                '$hours시간',
                style: pretendard(
                  weight: 700,
                  size: 14,
                  color: AppColors.textGray55,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // 추천 일정 (API 준비 전 비활성화)
  // ────────────────────────────────────────────────────────────────
  // Widget _buildRecommendCard() {
  //   return Container(
  //     height: 67,
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(10),
  //       boxShadow: const [
  //         BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 2),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Text(
  //           '추천 일정',
  //           style: pretendard(weight: 700, size: 18, color: AppColors.brandColor),
  //         ),
  //         const SizedBox(width: 22),
  //         Expanded(
  //           child: Text(
  //             '8월 15일(토) - 8월 17일(월) 황금연휴',
  //             style: pretendard(weight: 700, size: 13, color: AppColors.textGray55),
  //             textAlign: TextAlign.right,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ────────────────────────────────────────────────────────────────
  // 딤 처리 래퍼
  // ────────────────────────────────────────────────────────────────
  Widget _wrapWithDim({required bool isLinked, required Widget child}) {
    if (isLinked) return child;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: GestureDetector(
                onTap: () => widget.onAuthRequired?.call(),
                child: Container(
                  color: const Color(0xB3000000),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/lock.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '로그인 시 이용가능',
                        style: pretendard(
                          weight: 700,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
