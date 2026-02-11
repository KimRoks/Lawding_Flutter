import '../../domain/entities/annual_leave.dart';
import '../../domain/entities/non_working_period.dart';
import '../../domain/repositories/annual_leave_repository.dart';
import 'calculator_params.dart';
import 'calculator_response.dart';

/// CalculatorResponse를 AnnualLeave Entity로 변환
extension CalculatorResponseMapper on CalculatorResponse {
  AnnualLeave toDomain() {
    return AnnualLeave(
      calculationId: calculationId,
      calculationType: calculationType,
      fiscalYear: fiscalYear,
      hireDate: DateTime.parse(hireDate),
      referenceDate: DateTime.parse(referenceDate),
      nonWorkingPeriods: nonWorkingPeriod
          ?.map(
            (p) => NonWorkingPeriodEntity(
              type: p.type,
              startDate: DateTime.parse(p.startDate),
              endDate: DateTime.parse(p.endDate),
            ),
          )
          .toList(),
      companyHolidays: companyHolidays?.map(DateTime.parse).toList(),
      leaveType: leaveType.value,
      serviceYears: calculationDetail.serviceYears,
      totalDays: calculationDetail.totalLeaveDays,
      baseAnnualLeave: calculationDetail.baseAnnualLeave,
      additionalLeave: calculationDetail.additionalLeave,
      attendanceRate: calculationDetail.attendanceRate?.rate,
      prescribedWorkingRatio: calculationDetail.prescribedWorkingRatio != null
          ? RatioEntity(
              numerator: calculationDetail.prescribedWorkingRatio!.numerator,
              denominator: calculationDetail.prescribedWorkingRatio!.denominator,
              rate: calculationDetail.prescribedWorkingRatio!.rate,
            )
          : null,
      explanations: explanations,
      nonWorkingExplanations: nonWorkingExplanations,
      accrualPeriod: calculationDetail.accrualPeriod != null
          ? PeriodEntity(
              startDate: calculationDetail.accrualPeriod!.startDate,
              endDate: calculationDetail.accrualPeriod!.endDate,
            )
          : null,
      availablePeriod: calculationDetail.availablePeriod != null
          ? PeriodEntity(
              startDate: calculationDetail.availablePeriod!.startDate,
              endDate: calculationDetail.availablePeriod!.endDate,
            )
          : null,
      monthlyDetail: _buildMonthlyDetail(leaveType, calculationDetail),
      proratedDetail: calculationDetail.proratedDetail != null
          ? LeaveDetailEntity(
              accrualPeriod: PeriodEntity(
                startDate:
                    calculationDetail.proratedDetail!.accrualPeriod.startDate,
                endDate:
                    calculationDetail.proratedDetail!.accrualPeriod.endDate,
              ),
              availablePeriod: PeriodEntity(
                startDate:
                    calculationDetail.proratedDetail!.availablePeriod.startDate,
                endDate:
                    calculationDetail.proratedDetail!.availablePeriod.endDate,
              ),
              totalLeaveDays: calculationDetail.proratedDetail!.totalLeaveDays,
              attendanceRate:
                  calculationDetail.proratedDetail!.attendanceRate != null
                      ? RatioEntity(
                          numerator: calculationDetail
                              .proratedDetail!.attendanceRate!.numerator,
                          denominator: calculationDetail
                              .proratedDetail!.attendanceRate!.denominator,
                          rate: calculationDetail
                              .proratedDetail!.attendanceRate!.rate,
                        )
                      : null,
              prescribedWorkingRatio: calculationDetail
                          .proratedDetail!.prescribedWorkingRatio !=
                      null
                  ? RatioEntity(
                      numerator: calculationDetail
                          .proratedDetail!.prescribedWorkingRatio!.numerator,
                      denominator: calculationDetail.proratedDetail!
                          .prescribedWorkingRatio!.denominator,
                      rate: calculationDetail
                          .proratedDetail!.prescribedWorkingRatio!.rate,
                    )
                  : null,
              serviceYears: calculationDetail.proratedDetail!.serviceYears,
              prescribedWorkingRatioForProrated: calculationDetail
                  .proratedDetail!.prescribedWorkingRatioForProrated,
              records: calculationDetail.proratedDetail!.records
                  ?.map(
                    (r) => RecordEntity(
                      period: PeriodEntity(
                        startDate: r.period.startDate,
                        endDate: r.period.endDate,
                      ),
                      monthlyLeave: r.monthlyLeave,
                    ),
                  )
                  .toList(),
            )
          : null,
    );
  }
}

/// 월차 상세 정보 빌드
/// leaveType이 MONTHLY일 때 calculationDetail에서 직접 records를 가져옴
/// leaveType이 MONTHLY_AND_PRORATED일 때 monthlyDetail에서 가져옴
LeaveDetailEntity? _buildMonthlyDetail(
  LeaveType leaveType,
  CalculationDetail calculationDetail,
) {
  // leaveType이 MONTHLY일 때: calculationDetail에 직접 records가 있음
  if (leaveType == LeaveType.monthly && calculationDetail.records != null) {
    return LeaveDetailEntity(
      accrualPeriod: PeriodEntity(
        startDate: calculationDetail.accrualPeriod!.startDate,
        endDate: calculationDetail.accrualPeriod!.endDate,
      ),
      availablePeriod: PeriodEntity(
        startDate: calculationDetail.availablePeriod!.startDate,
        endDate: calculationDetail.availablePeriod!.endDate,
      ),
      totalLeaveDays: calculationDetail.totalLeaveDays,
      attendanceRate: calculationDetail.attendanceRate != null
          ? RatioEntity(
              numerator: calculationDetail.attendanceRate!.numerator,
              denominator: calculationDetail.attendanceRate!.denominator,
              rate: calculationDetail.attendanceRate!.rate,
            )
          : null,
      prescribedWorkingRatio: calculationDetail.prescribedWorkingRatio != null
          ? RatioEntity(
              numerator: calculationDetail.prescribedWorkingRatio!.numerator,
              denominator: calculationDetail.prescribedWorkingRatio!.denominator,
              rate: calculationDetail.prescribedWorkingRatio!.rate,
            )
          : null,
      serviceYears: calculationDetail.serviceYears,
      records: calculationDetail.records!
          .map(
            (r) => RecordEntity(
              period: PeriodEntity(
                startDate: r.period.startDate,
                endDate: r.period.endDate,
              ),
              monthlyLeave: r.monthlyLeave,
            ),
          )
          .toList(),
    );
  }

  // leaveType이 MONTHLY_AND_PRORATED일 때: monthlyDetail이 별도로 있음
  if (calculationDetail.monthlyDetail != null) {
    final monthly = calculationDetail.monthlyDetail!;
    return LeaveDetailEntity(
      accrualPeriod: PeriodEntity(
        startDate: monthly.accrualPeriod.startDate,
        endDate: monthly.accrualPeriod.endDate,
      ),
      availablePeriod: PeriodEntity(
        startDate: monthly.availablePeriod.startDate,
        endDate: monthly.availablePeriod.endDate,
      ),
      totalLeaveDays: monthly.totalLeaveDays,
      attendanceRate: monthly.attendanceRate != null
          ? RatioEntity(
              numerator: monthly.attendanceRate!.numerator,
              denominator: monthly.attendanceRate!.denominator,
              rate: monthly.attendanceRate!.rate,
            )
          : null,
      prescribedWorkingRatio: monthly.prescribedWorkingRatio != null
          ? RatioEntity(
              numerator: monthly.prescribedWorkingRatio!.numerator,
              denominator: monthly.prescribedWorkingRatio!.denominator,
              rate: monthly.prescribedWorkingRatio!.rate,
            )
          : null,
      serviceYears: monthly.serviceYears,
      records: monthly.records
          .map(
            (r) => RecordEntity(
              period: PeriodEntity(
                startDate: r.period.startDate,
                endDate: r.period.endDate,
              ),
              monthlyLeave: r.monthlyLeave,
            ),
          )
          .toList(),
    );
  }

  return null;
}

/// Domain Entity를 CalculatorCalculateParams로 변환
extension AnnualLeaveCalculationMapper on CalculationType {
  CalculatorCalculateParams toParams({
    required DateTime hireDate,
    required DateTime referenceDate,
    String? fiscalYear,
    required List<NonWorkingPeriod> nonWorkingPeriods,
    required List<DateTime> companyHolidays,
  }) {
    return CalculatorCalculateParams(
      calculationType: code,
      hireDate: _formatDate(hireDate),
      referenceDate: _formatDate(referenceDate),
      fiscalYear: fiscalYear,
      nonWorkingPeriods: nonWorkingPeriods
          .map((period) => period.toDataModel())
          .toList(),
      companyHolidays: companyHolidays.map(_formatDate).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// NonWorkingPeriod Entity를 Data Model로 변환
extension NonWorkingPeriodMapper on NonWorkingPeriod {
  NonWorkingPeriodDto toDataModel() {
    return NonWorkingPeriodDto(
      type: type,
      startDate: _formatDate(startDate),
      endDate: _formatDate(endDate),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
