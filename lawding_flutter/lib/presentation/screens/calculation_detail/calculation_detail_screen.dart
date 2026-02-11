import 'package:flutter/material.dart';

import '../../../domain/entities/annual_leave.dart';
import '../../../infrastructure/services/analytics_service.dart';
import '../../core/design_system.dart';
import '../../widgets/common/card_container.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_scaffold.dart';

class CalculationDetailScreen extends StatefulWidget {
  final AnnualLeave result;

  const CalculationDetailScreen({super.key, required this.result});

  @override
  State<CalculationDetailScreen> createState() =>
      _CalculationDetailScreenState();
}

class _CalculationDetailScreenState extends State<CalculationDetailScreen> {
  final _analytics = AnalyticsService();
  int _selectedSegmentIndex = 0; // 0: 월차, 1: 비례연차

  bool get _showSegment => widget.result.leaveType == 'MONTHLY_AND_PRORATED';

  @override
  void initState() {
    super.initState();
    // Analytics: 화면 진입 이벤트
    _analytics.logScreenView('CalculationDetailScreen');
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: '계산 기준 설명'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showSegment) ...[
              _buildSegmentedControl(),
              const SizedBox(height: 12),
            ],
            _DetailCard(
              result: widget.result,
              selectedSegmentIndex: _selectedSegmentIndex,
            ),
            const SizedBox(height: 16),
            _RecordsCard(
              result: widget.result,
              selectedSegmentIndex: _selectedSegmentIndex,
            ),
            const SizedBox(height: 16),
            _ExplanationCard(result: widget.result),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: _selectedSegmentIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedSegmentIndex = 0);
                    // Analytics: 세그먼트 변경 이벤트
                    _analytics.logDetailSegmentChanged('monthly');
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: pretendard(
                        weight: 700,
                        size: 16,
                        color: _selectedSegmentIndex == 0
                            ? AppColors.textGray11
                            : AppColors.secondaryTextColor,
                      ),
                      child: const Text('월차'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedSegmentIndex = 1);
                    // Analytics: 세그먼트 변경 이벤트
                    _analytics.logDetailSegmentChanged('prorated');
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: pretendard(
                        weight: 700,
                        size: 16,
                        color: _selectedSegmentIndex == 1
                            ? AppColors.textGray11
                            : AppColors.secondaryTextColor,
                      ),
                      child: const Text('비례연차'),
                    ),
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

/// 상세 정보 카드
class _DetailCard extends StatelessWidget {
  final AnnualLeave result;
  final int selectedSegmentIndex;

  const _DetailCard({required this.result, required this.selectedSegmentIndex});

  String _formatPercent(double value) {
    final percent = value <= 1.0 ? value * 100.0 : value;
    // 소수점이 없으면 정수로, 있으면 소수점 둘째자리까지 표시
    if (percent == percent.roundToDouble()) {
      return '${percent.toInt()}%';
    } else {
      return '${percent.toStringAsFixed(2)}%';
    }
  }

  String _formatNumber(double value) {
    // 소수점이 없으면 정수로, 있으면 소수점 둘째자리까지 표시
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMonthlyAndProrated =
        result.leaveType == 'MONTHLY_AND_PRORATED';

    if (isMonthlyAndProrated) {
      return selectedSegmentIndex == 0
          ? _buildMonthlyDetail()
          : _buildProratedDetail();
    } else if (result.leaveType == 'MONTHLY') {
      return _buildMonthlyOnlyDetail();
    } else if (result.leaveType == 'PRORATED') {
      return _buildProratedOnlyDetail();
    } else {
      return _buildDefaultDetail();
    }
  }

  // MONTHLY_AND_PRORATED의 월차 탭용 (기본연차/가산연차 숨김)
  Widget _buildMonthlyDetail() {
    final monthly = result.monthlyDetail;
    if (monthly == null) return _buildEmptyCard();

    final items = <Widget>[
      Text('상세 정보', style: pretendard(weight: 700, size: 20)),
      const SizedBox(height: 10),
      const Divider(height: 1, thickness: 1, color: AppColors.divider),
      const SizedBox(height: 12),
    ];

    // 연차 산정 기간
    items.add(
      _buildInfoRow(
        '연차 산정 기간:  ${monthly.accrualPeriod.startDate} ~ ${monthly.accrualPeriod.endDate}',
      ),
    );
    items.add(const SizedBox(height: 10));

    // 연차 사용 기간
    items.add(
      _buildInfoRow(
        '연차 사용 기간:  ${monthly.availablePeriod.startDate} ~ ${monthly.availablePeriod.endDate}',
      ),
    );
    items.add(const SizedBox(height: 10));

    // 근속연수
    if (monthly.serviceYears != null) {
      items.add(_buildInfoRow('근속연수:  ${monthly.serviceYears}년'));
      items.add(const SizedBox(height: 10));
    }

    // 출근율
    if (monthly.attendanceRate != null) {
      items.add(
        _buildInfoRow(
          '출근율:  ${_formatPercent(monthly.attendanceRate!.rate)} (${monthly.attendanceRate!.numerator}일 / ${monthly.attendanceRate!.denominator}일)',
        ),
      );
      items.add(const SizedBox(height: 10));
    }

    // 소정근로비율
    if (monthly.prescribedWorkingRatio != null) {
      items.add(
        _buildInfoRow(
          '소정근로비율:  ${_formatPercent(monthly.prescribedWorkingRatio!.rate)} (${monthly.prescribedWorkingRatio!.numerator}일 / ${monthly.prescribedWorkingRatio!.denominator}일)',
        ),
      );
      items.add(const SizedBox(height: 10));
    }

    // 하단 구분선 및 합계
    items.add(const Divider(height: 1, thickness: 1, color: AppColors.divider));
    items.add(const SizedBox(height: 10));
    items.add(
      Text(
        '연차 합계:  ${_formatNumber(monthly.totalLeaveDays)}일',
        style: pretendard(weight: 700, size: 13, color: AppColors.textGray11),
      ),
    );

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  // MONTHLY only용 (기본연차/가산연차 표시)
  Widget _buildMonthlyOnlyDetail() {
    final monthly = result.monthlyDetail;
    if (monthly == null) return _buildDefaultDetail();

    final items = <Widget>[
      Text(
        '상세 정보',
        style: pretendard(weight: 700, size: 20, color: hex('111111')),
      ),
      const SizedBox(height: 10),
      const Divider(height: 1, thickness: 1, color: AppColors.divider),
      const SizedBox(height: 12),
    ];

    // 연차 산정 기간
    items.add(
      _buildInfoRow(
        '연차 산정 기간:  ${monthly.accrualPeriod.startDate} ~ ${monthly.accrualPeriod.endDate}',
      ),
    );
    items.add(const SizedBox(height: 10));

    // 연차 사용 기간
    items.add(
      _buildInfoRow(
        '연차 사용 기간:  ${monthly.availablePeriod.startDate} ~ ${monthly.availablePeriod.endDate}',
      ),
    );
    items.add(const SizedBox(height: 10));

    // 근속연수
    if (monthly.serviceYears != null) {
      items.add(_buildInfoRow('근속연수:  ${monthly.serviceYears}년'));
      items.add(const SizedBox(height: 10));
    }

    // 출근율
    if (monthly.attendanceRate != null) {
      items.add(
        _buildInfoRow(
          '출근율:  ${_formatPercent(monthly.attendanceRate!.rate)} (${monthly.attendanceRate!.numerator}일 / ${monthly.attendanceRate!.denominator}일)',
        ),
      );
      items.add(const SizedBox(height: 10));
    }

    // 소정근로비율
    if (monthly.prescribedWorkingRatio != null) {
      items.add(
        _buildInfoRow(
          '소정근로비율:  ${_formatPercent(monthly.prescribedWorkingRatio!.rate)} (${monthly.prescribedWorkingRatio!.numerator}일 / ${monthly.prescribedWorkingRatio!.denominator}일)',
        ),
      );
      items.add(const SizedBox(height: 10));
    }

    // 기본연차/가산연차 (맨 아래 배치, 간격 20)
    final hasBaseOrAdditional =
        result.baseAnnualLeave != null || result.additionalLeave != null;
    if (hasBaseOrAdditional) {
      items.add(const SizedBox(height: 10)); // 추가 간격
    }

    if (result.baseAnnualLeave != null) {
      items.add(_buildInfoRow('기본 연차:  ${result.baseAnnualLeave}일'));
      items.add(const SizedBox(height: 10));
    }

    if (result.additionalLeave != null) {
      items.add(_buildInfoRow('가산 연차:  ${result.additionalLeave}일'));
      items.add(const SizedBox(height: 10));
    }

    // 하단 구분선 및 합계
    items.add(const Divider(height: 1, thickness: 1, color: AppColors.divider));
    items.add(const SizedBox(height: 10));
    items.add(
      Text(
        '월차 합계:  ${_formatNumber(monthly.totalLeaveDays)}일',
        style: pretendard(weight: 700, size: 13, color: AppColors.textGray11),
      ),
    );

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  // MONTHLY_AND_PRORATED의 비례연차 탭용 (기본연차/가산연차 숨김)
  Widget _buildProratedDetail() {
    final prorated = result.proratedDetail;
    if (prorated == null) return _buildEmptyCard();

    final items = <Widget>[
      Text('상세 정보', style: pretendard(weight: 700, size: 15)),
      const SizedBox(height: 10),
      const Divider(height: 1, thickness: 1, color: AppColors.divider),
      const SizedBox(height: 12),
    ];

    // 비례연차 산정 기간
    items.add(
      _buildInfoRow(
        '비례연차 산정 기간:  ${prorated.accrualPeriod.startDate} ~ ${prorated.accrualPeriod.endDate}',
      ),
    );
    items.add(const SizedBox(height: 10));

    // 비례연차 사용 기간
    items.add(
      _buildInfoRow(
        '비례연차 사용 기간:  ${prorated.availablePeriod.startDate} ~ ${prorated.availablePeriod.endDate}',
      ),
    );
    items.add(const SizedBox(height: 10));

    // 근속연수
    if (prorated.serviceYears != null) {
      items.add(_buildInfoRow('근속연수:  ${prorated.serviceYears}년'));
      items.add(const SizedBox(height: 10));
    }

    // 출근율
    if (prorated.attendanceRate != null) {
      items.add(
        _buildInfoRow(
          '출근율:  ${_formatPercent(prorated.attendanceRate!.rate)} (${prorated.attendanceRate!.numerator}일 / ${prorated.attendanceRate!.denominator}일)',
        ),
      );
      items.add(const SizedBox(height: 10));
    }

    // 소정근로비율
    if (prorated.prescribedWorkingRatio != null) {
      items.add(
        _buildInfoRow(
          '소정근로비율:  ${_formatPercent(prorated.prescribedWorkingRatio!.rate)} (${prorated.prescribedWorkingRatio!.numerator}일 / ${prorated.prescribedWorkingRatio!.denominator}일)',
        ),
      );
      items.add(const SizedBox(height: 10));
    }

    // 비례율
    if (prorated.prescribedWorkingRatioForProrated != null) {
      items.add(
        _buildInfoRow(
          '비례율:  ${_formatPercent(prorated.prescribedWorkingRatioForProrated!)}',
        ),
      );
      items.add(const SizedBox(height: 10));
    }

    // 하단 구분선 및 합계
    items.add(const Divider(height: 1, thickness: 1, color: AppColors.divider));
    items.add(const SizedBox(height: 10));
    items.add(
      Text(
        '비례연차 합계:  ${_formatNumber(prorated.totalLeaveDays)}일',
        style: pretendard(weight: 700, size: 13, color: AppColors.textGray11),
      ),
    );

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  // PRORATED only용 (기본연차/가산연차 표시)
  Widget _buildProratedOnlyDetail() {
    final prorated = result.proratedDetail;
    if (prorated == null) return _buildDefaultDetail();

    final items = <Widget>[
      Text('상세 정보', style: pretendard(weight: 700, size: 15)),
      const SizedBox(height: 10),
      const Divider(height: 1, thickness: 1, color: AppColors.divider),
      const SizedBox(height: 12),
    ];

    // 비례연차 산정 기간
    items.add(
      _buildInfoRow(
        '비례연차 산정 기간:  ${prorated.accrualPeriod.startDate} ~ ${prorated.accrualPeriod.endDate}',
      ),
    );
    items.add(const SizedBox(height: 10));

    // 비례연차 사용 기간
    items.add(
      _buildInfoRow(
        '비례연차 사용 기간:  ${prorated.availablePeriod.startDate} ~ ${prorated.availablePeriod.endDate}',
      ),
    );
    items.add(const SizedBox(height: 10));

    // 근속연수
    if (prorated.serviceYears != null) {
      items.add(_buildInfoRow('근속연수:  ${prorated.serviceYears}년'));
      items.add(const SizedBox(height: 10));
    }

    // 출근율
    if (prorated.attendanceRate != null) {
      items.add(
        _buildInfoRow(
          '출근율:  ${_formatPercent(prorated.attendanceRate!.rate)} (${prorated.attendanceRate!.numerator}일 / ${prorated.attendanceRate!.denominator}일)',
        ),
      );
      items.add(const SizedBox(height: 10));
    }

    // 소정근로비율
    if (prorated.prescribedWorkingRatio != null) {
      items.add(
        _buildInfoRow(
          '소정근로비율:  ${_formatPercent(prorated.prescribedWorkingRatio!.rate)} (${prorated.prescribedWorkingRatio!.numerator}일 / ${prorated.prescribedWorkingRatio!.denominator}일)',
        ),
      );
      items.add(const SizedBox(height: 10));
    }

    // 비례율
    if (prorated.prescribedWorkingRatioForProrated != null) {
      items.add(
        _buildInfoRow(
          '비례율:  ${_formatPercent(prorated.prescribedWorkingRatioForProrated!)}',
        ),
      );
      items.add(const SizedBox(height: 10));
    }

    // 기본연차/가산연차 (맨 아래 배치, 간격 20)
    final hasBaseOrAdditional =
        result.baseAnnualLeave != null || result.additionalLeave != null;
    if (hasBaseOrAdditional) {
      items.add(const SizedBox(height: 10)); // 추가 간격
    }

    if (result.baseAnnualLeave != null) {
      items.add(_buildInfoRow('기본 연차:  ${result.baseAnnualLeave}일'));
      items.add(const SizedBox(height: 10));
    }

    if (result.additionalLeave != null) {
      items.add(_buildInfoRow('가산 연차:  ${result.additionalLeave}일'));
      items.add(const SizedBox(height: 10));
    }

    // 하단 구분선 및 합계
    items.add(const Divider(height: 1, thickness: 1, color: AppColors.divider));
    items.add(const SizedBox(height: 10));
    items.add(
      Text(
        '비례연차 합계:  ${_formatNumber(prorated.totalLeaveDays)}일',
        style: pretendard(weight: 700, size: 13, color: AppColors.textGray11),
      ),
    );

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  Widget _buildDefaultDetail() {
    final items = <Widget>[
      Text('상세 정보', style: pretendard(weight: 700, size: 15)),
      const SizedBox(height: 10),
      const Divider(height: 1, thickness: 1, color: AppColors.divider),
      const SizedBox(height: 12),
    ];

    // 연차 산정 기간
    if (result.accrualPeriod != null) {
      items.add(
        _buildInfoRow(
          '연차 산정 기간:  ${result.accrualPeriod!.startDate} ~ ${result.accrualPeriod!.endDate}',
        ),
      );
      items.add(const SizedBox(height: 10));
    }

    // 연차 사용 기간
    if (result.availablePeriod != null) {
      items.add(
        _buildInfoRow(
          '연차 사용 기간:  ${result.availablePeriod!.startDate} ~ ${result.availablePeriod!.endDate}',
        ),
      );
      items.add(const SizedBox(height: 10));
    }

    // 근속연수
    items.add(_buildInfoRow('근속연수:  ${result.serviceYears}년'));
    items.add(const SizedBox(height: 10));

    // 출근율
    if (result.attendanceRate != null) {
      items.add(
        _buildInfoRow('출근율:  ${_formatPercent(result.attendanceRate!)}'),
      );
      items.add(const SizedBox(height: 10));
    }

    // 소정근로비율
    if (result.prescribedWorkingRatio != null) {
      items.add(
        _buildInfoRow(
          '소정근로비율:  ${_formatPercent(result.prescribedWorkingRatio!.rate)} (${result.prescribedWorkingRatio!.numerator}일 / ${result.prescribedWorkingRatio!.denominator}일)',
        ),
      );
      items.add(const SizedBox(height: 10));
    }

    // 기본연차/가산연차 (맨 아래 배치, 간격 20)
    final hasBaseOrAdditional =
        result.baseAnnualLeave != null || result.additionalLeave != null;
    if (hasBaseOrAdditional) {
      items.add(const SizedBox(height: 10)); // 추가 간격
    }

    if (result.baseAnnualLeave != null) {
      items.add(_buildInfoRow('기본 연차:  ${result.baseAnnualLeave}일'));
      items.add(const SizedBox(height: 10));
    }

    if (result.additionalLeave != null) {
      items.add(_buildInfoRow('가산 연차:  ${result.additionalLeave}일'));
      items.add(const SizedBox(height: 10));
    }

    // 하단 구분선 및 합계
    items.add(const Divider(height: 1, thickness: 1, color: AppColors.divider));
    items.add(const SizedBox(height: 10));
    items.add(
      Text(
        '총 발생 연차:  ${_formatNumber(result.totalDays)}일',
        style: pretendard(weight: 700, size: 12, color: AppColors.textGray11),
      ),
    );

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  Widget _buildEmptyCard() {
    return CardContainer(
      child: Text('상세 정보 없음', style: pretendard(weight: 400, size: 13)),
    );
  }

  Widget _buildInfoRow(String text) {
    return Text(
      text,
      style: pretendard(weight: 500, size: 12, color: AppColors.textGray99),
    );
  }
}

/// 월별 발생 현황 카드
class _RecordsCard extends StatelessWidget {
  final AnnualLeave result;
  final int selectedSegmentIndex;

  const _RecordsCard({
    required this.result,
    required this.selectedSegmentIndex,
  });

  String _formatNumber(double value) {
    // 소수점이 없으면 정수로, 있으면 소수점 둘째자리까지 표시
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMonthlyAndProrated =
        result.leaveType == 'MONTHLY_AND_PRORATED';

    List<dynamic>? records;
    if (isMonthlyAndProrated) {
      if (selectedSegmentIndex == 0) {
        records = result.monthlyDetail?.records;
      } else {
        records = result.proratedDetail?.records;
      }
    } else {
      records = result.monthlyDetail?.records;
    }

    if (records == null || records.isEmpty) {
      return const SizedBox.shrink();
    }

    double totalDays = 0;
    for (final record in records) {
      totalDays += record.monthlyLeave as double;
    }

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('월별 발생 현황', style: pretendard(weight: 700, size: 15)),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          ...records.map((record) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    '${record.period.startDate} ~ ${record.period.endDate}',
                    style: pretendard(
                      weight: 500,
                      size: 12,
                      color: AppColors.textGray99,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_formatNumber(record.monthlyLeave)}일',
                    style: pretendard(weight: 700, size: 13),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 2),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          const SizedBox(height: 10),
          Text(
            '월별 합계: ${_formatNumber(totalDays)}일',
            style: pretendard(weight: 700, size: 14),
          ),
        ],
      ),
    );
  }
}

/// 계산 기준 설명 카드
class _ExplanationCard extends StatelessWidget {
  final AnnualLeave result;

  const _ExplanationCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final hasExplanations = result.explanations.isNotEmpty;
    final hasNonWorkingExplanations =
        result.nonWorkingExplanations?.isNotEmpty ?? false;

    if (!hasExplanations && !hasNonWorkingExplanations) {
      return const SizedBox.shrink();
    }

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasExplanations) ...[
            Text('계산 기준 설명', style: pretendard(weight: 700, size: 15)),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: AppColors.divider),
            const SizedBox(height: 12),
            ...result.explanations.map((text) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  text,
                  style: pretendard(
                    weight: 500,
                    size: 12,
                    color: AppColors.textGray99,
                  ),
                ),
              );
            }),
          ],
          if (hasExplanations && hasNonWorkingExplanations)
            const SizedBox(height: 16),
          if (hasNonWorkingExplanations) ...[
            Text('특이사항 관련 설명', style: pretendard(weight: 700, size: 15)),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: AppColors.divider),
            const SizedBox(height: 12),
            ...result.nonWorkingExplanations!.map((text) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  text,
                  style: pretendard(
                    weight: 500,
                    size: 12,
                    color: AppColors.textGray99,
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
