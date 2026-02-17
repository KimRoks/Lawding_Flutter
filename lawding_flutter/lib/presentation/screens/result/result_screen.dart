import 'package:flutter/material.dart';

import '../../../domain/entities/annual_leave.dart';
import '../../../infrastructure/services/analytics_service.dart';
import '../../core/design_system.dart';
import '../../widgets/common/card_container.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_scaffold.dart';
import '../../widgets/common/submit_button.dart';
import '../../widgets/result/result_badge.dart';
import '../calculation_detail/calculation_detail_screen.dart';
import '../feedback/feedback_screen.dart';

class ResultScreen extends StatefulWidget {
  final AnnualLeave result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _analytics = AnalyticsService();

  @override
  void initState() {
    super.initState();
    // Analytics: 화면 진입 이벤트
    _analytics.logScreenView('ResultScreen');
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return CustomScaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: '계산결과'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ResultCard(result: result),
            const SizedBox(height: 22),
            _InfoCard(result: result),
            const SizedBox(height: 22),
            _CalculationDetailSection(result: result),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: () {
                // Analytics: 피드백 링크 클릭 이벤트
                _analytics.logExternalLinkClicked(
                  'feedback_from_result',
                  'internal://feedback',
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FeedbackScreen(calculationId: result.calculationId),
                  ),
                );
              },
              child: RichText(
                text: TextSpan(
                  style: pretendard(
                    weight: 500,
                    size: 12,
                    color: AppColors.secondaryTextColor,
                  ),
                  children: const [
                    TextSpan(text: '여러분의 소중한 의견을 '),
                    TextSpan(
                      text: '피드백',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.brandColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(text: '으로 통해 보내주세요'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SubmitButton(
              text: '처음으로',
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 결과 카드 (상단 계산 결과)
class _ResultCard extends StatelessWidget {
  final AnnualLeave result;

  const _ResultCard({required this.result});

  int _calculateDaysBetween(DateTime start, DateTime end) {
    final difference = end.difference(start).inDays;
    return difference + 1; // 시작일과 종료일 포함
  }

  @override
  Widget build(BuildContext context) {
    final days = _calculateDaysBetween(result.hireDate, result.referenceDate);

    // MONTHLY_AND_PRORATED인 경우에만 비례연차 배지를 따로 표시
    final showProratedBadge =
        result.leaveType == 'MONTHLY_AND_PRORATED' &&
        result.proratedDetail != null;

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('계산 결과', style: pretendard(weight: 700, size: 20)),
              const SizedBox(width: 8),
              ResultBadge(leaveType: result.leaveType),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            '$days일간 열심히 일한 당신의 총 연차는',
            style: pretendard(
              weight: 500,
              size: 12,
              color: AppColors.textGray99,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.brandLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '총 ${result.totalDays}일',
              style: pretendard(
                weight: 700,
                size: 40,
                color: AppColors.brandColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          _buildAvailabilityPeriodBadge(),
          if (showProratedBadge) ...[
            const SizedBox(height: 10),
            _buildProratedAvailablePeriodBadge(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilityPeriodBadge() {
    final String periodText;

    // MONTHLY_AND_PRORATED인 경우: 월차 사용 기간만 표시 (비례는 별도 배지로)
    // MONTHLY만 있는 경우: 월차 사용 기간 표시
    // PRORATED만 있는 경우: 비례연차 사용 기간 표시 (이 케이스는 아래에서 처리 안됨)
    // availablePeriod가 있는 경우 (연차): 사용 기간 표시

    if (result.leaveType == 'MONTHLY_AND_PRORATED' &&
        result.monthlyDetail != null) {
      // 월차 + 비례연차 케이스: 월차 사용 기간만 표시
      final monthlyPeriod = result.monthlyDetail!.availablePeriod;
      periodText =
          '월차 사용 기간:  ${monthlyPeriod.startDate} ~ ${monthlyPeriod.endDate}';
    } else if (result.leaveType == 'MONTHLY' && result.monthlyDetail != null) {
      // 월차만 있는 케이스: 월차 사용 기간 표시
      final monthlyPeriod = result.monthlyDetail!.availablePeriod;
      periodText =
          '월차 사용 기간:  ${monthlyPeriod.startDate} ~ ${monthlyPeriod.endDate}';
    } else if (result.leaveType == 'PRORATED' &&
        result.proratedDetail != null &&
        result.monthlyDetail == null) {
      // 비례연차만 있는 케이스: 비례연차 사용 기간 표시
      final proratedPeriod = result.proratedDetail!.availablePeriod;
      periodText =
          '비례연차 사용 기간:  ${proratedPeriod.startDate} ~ ${proratedPeriod.endDate}';
    } else if (result.availablePeriod != null) {
      // 일반 연차 케이스: 사용 기간 표시
      periodText =
          '사용 기간:  ${result.availablePeriod!.startDate} ~ ${result.availablePeriod!.endDate}';
    } else {
      periodText = '사용 기간 -';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundField,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/icons/calendar.png', width: 16, height: 15),
          const SizedBox(width: 7),
          Text(
            periodText,
            style: pretendard(
              weight: 500,
              size: 11,
              color: AppColors.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProratedAvailablePeriodBadge() {
    if (result.proratedDetail == null) {
      return const SizedBox.shrink();
    }

    final prorated = result.proratedDetail!;
    final periodText =
        '비례 연차 사용 기간:  ${prorated.availablePeriod.startDate} ~ ${prorated.availablePeriod.endDate}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundField,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/icons/calendar.png', width: 16, height: 15),
          const SizedBox(width: 7),
          Text(
            periodText,
            style: pretendard(
              weight: 500,
              size: 11,
              color: AppColors.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// 계산 정보 카드 (세부 계산 정보)
class _InfoCard extends StatelessWidget {
  final AnnualLeave result;

  const _InfoCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final monthlyDetail = result.monthlyDetail;
    final proratedDetail = result.proratedDetail;

    // 케이스별 표시 로직
    final bool showMonthlySection;
    final String monthlyTitle;
    final String monthlyAccrualText;
    final String monthlyAvailableText;

    if (monthlyDetail != null) {
      // 월차가 있으면 월차 기준으로 표기
      showMonthlySection = true;
      monthlyTitle = '월차 합계: ${monthlyDetail.totalLeaveDays}일';
      monthlyAccrualText =
          '월차 산정 기간: ${monthlyDetail.accrualPeriod.startDate} ~ ${monthlyDetail.accrualPeriod.endDate}';
      monthlyAvailableText =
          '월차 사용 기간: ${monthlyDetail.availablePeriod.startDate} ~ ${monthlyDetail.availablePeriod.endDate}';
    } else if (monthlyDetail == null && proratedDetail == null) {
      // 둘 다 없으면 calculationDetail의 정보를 '연차'로 표기
      showMonthlySection = true;
      monthlyTitle = '연차 합계: ${result.totalDays}일';

      if (result.accrualPeriod != null) {
        monthlyAccrualText =
            '연차 산정 기간: ${result.accrualPeriod!.startDate} ~ ${result.accrualPeriod!.endDate}';
      } else {
        monthlyAccrualText = '연차 산정 기간: -';
      }

      if (result.availablePeriod != null) {
        monthlyAvailableText =
            '연차 사용 기간: ${result.availablePeriod!.startDate} ~ ${result.availablePeriod!.endDate}';
      } else {
        monthlyAvailableText = '연차 사용 기간: -';
      }
    } else {
      // 월차가 없고, 비례만 있는 경우 (PRORATED)
      showMonthlySection = false;
      monthlyTitle = '';
      monthlyAccrualText = '';
      monthlyAvailableText = '';
    }

    // MONTHLY_AND_PRORATED일 때만 비례 섹션을 따로 표시
    // PRORATED만 있는 경우도 표시
    final showProratedSection = proratedDetail != null;
    final hasAnySection = showMonthlySection || showProratedSection;

    // MONTHLY_AND_PRORATED가 아니고 섹션이 있으면 총 합계 구분선 표시 안함
    // (월차만 또는 비례연차만 있는 경우)
    final showTotalSeparator =
        result.leaveType == 'MONTHLY_AND_PRORATED' && hasAnySection;

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('계산 정보', style: pretendard(weight: 700, size: 20)),
          const SizedBox(height: 7),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          const SizedBox(height: 17),
          // 월별(월차) 섹션
          if (showMonthlySection) ...[
            _buildSectionTitle(monthlyTitle),
            const SizedBox(height: 4),
            _buildSectionDetail(monthlyAccrualText),
            const SizedBox(height: 4),
            _buildSectionDetail(monthlyAvailableText),
          ],
          // 비례 섹션
          if (showProratedSection) ...[
            if (showMonthlySection) const SizedBox(height: 17),
            _buildSectionTitle('비례연차 합계: ${proratedDetail.totalLeaveDays}일'),
            const SizedBox(height: 4),
            _buildSectionDetail(
              '비례연차 산정 기간: ${proratedDetail.accrualPeriod.startDate} ~ ${proratedDetail.accrualPeriod.endDate}',
            ),
            const SizedBox(height: 4),
            _buildSectionDetail(
              '비례연차 사용 기간: ${proratedDetail.availablePeriod.startDate} ~ ${proratedDetail.availablePeriod.endDate}',
            ),
          ],
          // 하단 구분선: MONTHLY_AND_PRORATED인 경우만 총 합계 구분선 표시
          if (showTotalSeparator) ...[
            const SizedBox(height: 17),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            const SizedBox(height: 7),
            _buildSectionTitle('총 연차 합계: ${result.totalDays}일'),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: pretendard(
        weight: 700,
        size: 14,
        color: AppColors.primaryTextColor,
      ),
    );
  }

  Widget _buildSectionDetail(String text) {
    return Text(
      text,
      style: pretendard(
        weight: 500,
        size: 12,
        color: AppColors.secondaryTextColor,
      ),
    );
  }
}

/// 연차 계산 방법 상세보기 섹션
class _CalculationDetailSection extends StatelessWidget {
  final AnnualLeave result;

  const _CalculationDetailSection({required this.result});

  @override
  Widget build(BuildContext context) {
    final analytics = AnalyticsService();

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '연차 계산 방법 상세보기',
                    style: pretendard(
                      weight: 700,
                      size: 15,
                      color: AppColors.brandColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '계산 기준을 자세히 보려면 여기를 눌러주세요.',
                    style: pretendard(
                      weight: 500,
                      size: 12,
                      color: AppColors.textGray99,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // Analytics: 계산 상세 보기 이벤트
                  analytics.logCalculationDetailViewed(result.leaveType);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CalculationDetailScreen(result: result),
                    ),
                  );
                },
                child: Container(
                  width: 42,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '이동',
                    style: pretendard(
                      weight: 700,
                      size: 12,
                      color: AppColors.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
