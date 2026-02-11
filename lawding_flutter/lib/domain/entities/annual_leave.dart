/// 연차 정보를 나타내는 Domain Entity
class AnnualLeave {
  /// 계산 고유 ID
  final String calculationId;

  /// 계산 방식 (standard/prorated)
  final String calculationType;

  /// 회계연도
  final String? fiscalYear;

  /// 입사일
  final DateTime hireDate;

  /// 기준일
  final DateTime referenceDate;

  /// 휴직 기간
  final List<NonWorkingPeriodEntity>? nonWorkingPeriods;

  /// 회사 휴무일
  final List<DateTime>? companyHolidays;

  /// 연차 유형
  final String leaveType;

  /// 근속 연수
  final int serviceYears;

  /// 총 연차 일수
  final double totalDays;

  /// 기본 연차
  final int? baseAnnualLeave;

  /// 가산 연차
  final int? additionalLeave;

  /// 출근율
  final double? attendanceRate;

  /// 소정근로비율 (ANNUAL 타입 등에서 top-level로 사용)
  final RatioEntity? prescribedWorkingRatio;

  /// 설명
  final List<String> explanations;

  /// 휴직 관련 설명
  final List<String>? nonWorkingExplanations;

  /// 산정 기간
  final PeriodEntity? accrualPeriod;

  /// 사용 기간
  final PeriodEntity? availablePeriod;

  /// 월차 상세 정보
  final LeaveDetailEntity? monthlyDetail;

  /// 비례연차 상세 정보
  final LeaveDetailEntity? proratedDetail;

  const AnnualLeave({
    required this.calculationId,
    required this.calculationType,
    this.fiscalYear,
    required this.hireDate,
    required this.referenceDate,
    this.nonWorkingPeriods,
    this.companyHolidays,
    required this.leaveType,
    required this.serviceYears,
    required this.totalDays,
    this.baseAnnualLeave,
    this.additionalLeave,
    this.attendanceRate,
    this.prescribedWorkingRatio,
    required this.explanations,
    this.nonWorkingExplanations,
    this.accrualPeriod,
    this.availablePeriod,
    this.monthlyDetail,
    this.proratedDetail,
  });

  /// 남은 연차 일수 (사용하지 않은 연차, 현재는 totalDays와 동일)
  int get remainingDays => totalDays.toInt();

  /// 연차가 남아있는지 여부
  bool get hasRemainingDays => totalDays > 0;

  @override
  String toString() {
    return 'AnnualLeave(id: $calculationId, type: $calculationType, total: $totalDays, service: $serviceYears년)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnnualLeave && other.calculationId == calculationId;
  }

  @override
  int get hashCode {
    return calculationId.hashCode;
  }
}

/// 휴직 기간 엔티티 (간단한 버전)
class NonWorkingPeriodEntity {
  final int type;
  final DateTime startDate;
  final DateTime endDate;

  const NonWorkingPeriodEntity({
    required this.type,
    required this.startDate,
    required this.endDate,
  });
}

/// 기간 엔티티
class PeriodEntity {
  final String startDate;
  final String endDate;

  const PeriodEntity({required this.startDate, required this.endDate});
}

/// 비율 엔티티
class RatioEntity {
  final int numerator;
  final int denominator;
  final double rate;

  const RatioEntity({
    required this.numerator,
    required this.denominator,
    required this.rate,
  });
}

/// 월별 기록 엔티티
class RecordEntity {
  final PeriodEntity period;
  final double monthlyLeave;

  const RecordEntity({
    required this.period,
    required this.monthlyLeave,
  });
}

/// 연차 상세 정보 엔티티 (월차 또는 비례연차)
class LeaveDetailEntity {
  final PeriodEntity accrualPeriod;
  final PeriodEntity availablePeriod;
  final double totalLeaveDays;
  final RatioEntity? attendanceRate;
  final RatioEntity? prescribedWorkingRatio;
  final int? serviceYears;
  final double? prescribedWorkingRatioForProrated;
  final List<RecordEntity>? records;

  const LeaveDetailEntity({
    required this.accrualPeriod,
    required this.availablePeriod,
    required this.totalLeaveDays,
    this.attendanceRate,
    this.prescribedWorkingRatio,
    this.serviceYears,
    this.prescribedWorkingRatioForProrated,
    this.records,
  });
}
