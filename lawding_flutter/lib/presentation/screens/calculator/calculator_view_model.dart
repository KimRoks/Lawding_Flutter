import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/network/network_error.dart';
import '../../../domain/core/result.dart';
import '../../../domain/entities/annual_leave.dart';
import '../../../domain/entities/company_holiday.dart';
import '../../../domain/entities/non_working_period.dart';
import '../../../domain/repositories/annual_leave_repository.dart';
import '../../../infrastructure/services/analytics_service.dart';
import '../../../infrastructure/services/crashlytics_service.dart';
import '../../core/design_system.dart';
import '../../providers/providers.dart';

part 'calculator_view_model.g.dart';

@riverpod
class CalculatorViewModel extends _$CalculatorViewModel {
  final _analytics = AnalyticsService();
  final _crashlytics = CrashlyticsService();

  @override
  CalculatorState build() {
    return CalculatorState();
  }

  void setCalculationType(int index) {
    final calculationType = index == 0
        ? CalculationType.standard
        : CalculationType.proRated;

    state = state.copyWith(calculationType: calculationType);

    // Analytics 이벤트 기록
    _analytics.logCalculationTypeSelected(
      calculationType == CalculationType.standard ? 'standard' : 'pro_rated',
    );
  }

  void setHireDate(DateTime date) {
    state = state.copyWith(hireDate: date);

    // Analytics 이벤트 기록
    _analytics.logHireDateSelected(date.toIso8601String());
  }

  void setReferenceDate(DateTime date) {
    state = state.copyWith(referenceDate: date);

    // Analytics 이벤트 기록
    _analytics.logReferenceDateSelected(date.toIso8601String());
  }

  void setFiscalYearStartMonth(int month) {
    // 회계연도 시작 월 저장
    state = state.copyWith(fiscalYearStartMonth: month);

    // Analytics 이벤트 기록
    _analytics.logFiscalYearStartMonthSelected(month);
  }

  /// 특이사항 추가 가능 여부 검증
  String? canAddNonWorkingPeriod() {
    // 1. 최대 3개 제한
    if (state.nonWorkingPeriods.length >= 3) {
      return '특이 사항은 최대 3개까지 추가할 수 있습니다.';
    }
    return null;
  }

  /// 특이사항 기간 검증
  String? validateNonWorkingPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // 4. 시작일이 종료일보다 이후인지 검증
    if (startDate.isAfter(endDate)) {
      return '시작일은 종료일보다 이전이어야 합니다.';
    }

    // 3. 특이사항이 산정방식 기간 내에 포함되는지 검증
    final hireDate = state.hireDate;
    final referenceDate = state.referenceDate;

    if (hireDate != null && referenceDate != null) {
      if (startDate.isBefore(hireDate) || endDate.isAfter(referenceDate)) {
        return '특이 사항은 입사일과 계산 기준일 사이에 있어야 합니다.';
      }
    }

    // 5. 기존 특이사항과 기간이 겹치는지 검증
    for (final existingPeriod in state.nonWorkingPeriods) {
      // 새로운 기간이 기존 기간과 겹치는지 확인
      // 겹치는 조건: (새 시작일 <= 기존 종료일) AND (새 종료일 >= 기존 시작일)
      if (startDate.isBefore(
            existingPeriod.endDate.add(const Duration(days: 1)),
          ) &&
          endDate.isAfter(
            existingPeriod.startDate.subtract(const Duration(days: 1)),
          )) {
        return '특이 사항 기간이 기존 기간(${existingPeriod.displayName})과 겹칩니다.';
      }
    }

    return null;
  }

  /// 특이사항 추가 (파싱 및 검증 포함)
  String? addNonWorkingPeriodFromMap(Map<String, dynamic> data) {
    try {
      final startDate = DateTime.parse(data['startDate'] as String);
      final endDate = DateTime.parse(data['endDate'] as String);
      final type = data['type'] as int;
      final displayName = data['displayName'] as String;

      // 검증
      final validationError = validateNonWorkingPeriod(
        startDate: startDate,
        endDate: endDate,
      );

      if (validationError != null) {
        return validationError;
      }

      // 객체 생성 및 추가
      final period = NonWorkingPeriod(
        type: type,
        startDate: startDate,
        endDate: endDate,
        displayName: displayName,
      );

      final updated = [...state.nonWorkingPeriods, period];
      state = state.copyWith(nonWorkingPeriods: updated);

      // Analytics 이벤트 기록
      _analytics.logNonWorkingPeriodAdded(displayName);

      return null;
    } catch (e) {
      return '데이터 처리 중 오류가 발생했습니다.';
    }
  }

  void removeNonWorkingPeriod(int index) {
    final removedPeriod = state.nonWorkingPeriods[index];
    final updated = List<NonWorkingPeriod>.from(state.nonWorkingPeriods)
      ..removeAt(index);
    state = state.copyWith(nonWorkingPeriods: updated);

    // Analytics 이벤트 기록
    _analytics.logNonWorkingPeriodRemoved(removedPeriod.displayName);
  }

  /// 회사휴일 추가 가능 여부 검증
  String? canAddCompanyHoliday() {
    // 1. 최대 3개 제한
    if (state.companyHolidays.length >= 3) {
      return '회사휴일은 최대 3개까지 추가할 수 있습니다.';
    }
    return null;
  }

  /// 회사휴일 날짜 검증
  String? validateCompanyHoliday({required DateTime date}) {
    // 2. 회사휴일이 입사일과 계산 기준일 사이에 포함되는지 검증
    final hireDate = state.hireDate;
    final referenceDate = state.referenceDate;

    if (hireDate != null && referenceDate != null) {
      if (date.isBefore(hireDate) || date.isAfter(referenceDate)) {
        return '회사휴일은 입사일과 계산 기준일 사이에 있어야 합니다.';
      }
    }

    return null;
  }

  /// 회사휴일 추가 (파싱 및 검증 포함)
  String? addCompanyHolidayFromMap(Map<String, dynamic> data) {
    try {
      final date = DateTime.parse(data['date'] as String);
      final displayName = data['displayName'] as String;

      // 검증
      final validationError = validateCompanyHoliday(date: date);

      if (validationError != null) {
        return validationError;
      }

      // 객체 생성 및 추가
      final holiday = CompanyHoliday(date: date, displayName: displayName);

      final updated = [...state.companyHolidays, holiday];
      state = state.copyWith(companyHolidays: updated);

      // Analytics 이벤트 기록
      _analytics.logCompanyHolidayAdded(displayName);

      return null;
    } catch (e) {
      return '데이터 처리 중 오류가 발생했습니다.';
    }
  }

  void removeCompanyHoliday(int index) {
    final removedHoliday = state.companyHolidays[index];
    final updated = List<CompanyHoliday>.from(state.companyHolidays)
      ..removeAt(index);
    state = state.copyWith(companyHolidays: updated);

    // Analytics 이벤트 기록
    _analytics.logCompanyHolidayRemoved(removedHoliday.displayName);
  }

  /// 계산하기 검증
  String? validateCalculation() {
    // 필수사항 검증
    if (state.hireDate == null) {
      return '입사일을 선택해주세요.';
    }

    if (state.referenceDate == null) {
      return '계산 기준일을 선택해주세요.';
    }

    // 2. 입사일이 계산 기준일보다 이후인지 검증
    if (state.hireDate!.isAfter(state.referenceDate!)) {
      return '입사일은 계산 기준일보다 이전이어야 합니다.';
    }

    // 3. 계산 기준일은 2017년 5월 30일 이후여야 함
    final minReferenceDate = DateTime(2017, 5, 30);
    if (state.referenceDate!.isBefore(minReferenceDate)) {
      return '계산 기준일은 2017년 5월 30일 이후여야 합니다.';
    }

    // 1. 특이사항이 입사일과 계산 기준일 사이에 포함되는지 검증
    for (final period in state.nonWorkingPeriods) {
      if (period.startDate.isBefore(state.hireDate!) ||
          period.endDate.isAfter(state.referenceDate!)) {
        return '특이 사항은 입사일과 계산 기준일 사이에 있어야 합니다.';
      }
    }

    return null;
  }

  Future<void> calculate() async {
    final hireDate = state.hireDate;
    final referenceDate = state.referenceDate;

    if (hireDate == null || referenceDate == null) {
      state = state.copyWith(error: '입사일과 계산 기준일을 모두 선택해주세요.');
      return;
    }

    // 입사일 > 계산 기준일 검증
    if (hireDate.isAfter(referenceDate)) {
      state = state.copyWith(error: '입사일은 계산 기준일보다 이전이어야 합니다.');
      return;
    }

    // fiscalYear 계산
    final fiscalYear = state.calculationType == CalculationType.proRated
        ? DateFormatter.toMonthDayFormat(state.fiscalYearStartMonth)
        : null;

    // Analytics: 계산 시작 이벤트
    final calculationTypeString =
        state.calculationType == CalculationType.standard ? 'standard' : 'pro_rated';
    await _analytics.logCalculationStarted(calculationTypeString);

    // Crashlytics 컨텍스트 설정
    await _crashlytics.setCalculationContext(
      calculationType: calculationTypeString,
      hireDate: hireDate.toIso8601String(),
      referenceDate: referenceDate.toIso8601String(),
    );

    state = state.copyWith(isLoading: true, error: null);

    final useCase = ref.read(calculateAnnualLeaveUseCaseProvider);
    final result = await useCase.execute(
      calculationType: state.calculationType,
      hireDate: hireDate,
      referenceDate: referenceDate,
      fiscalYear: fiscalYear,
      nonWorkingPeriods: state.nonWorkingPeriods,
      companyHolidays: state.companyHolidays.map((h) => h.date).toList(),
    );

    switch (result) {
      case Success(:final value):
        state = state.copyWith(isLoading: false, result: value);

        // Analytics: 계산 완료 이벤트
        final serviceYears = referenceDate.difference(hireDate).inDays ~/ 365;
        await _analytics.logCalculationCompleted(
          calculationType: calculationTypeString,
          leaveType: value.leaveType,
          totalDays: value.totalDays,
          serviceYears: serviceYears,
        );

      case Failure(:final error):
        final errorMessage = switch (error) {
          ServerError(:final message) => message,
          UnauthorizedError() => '인증이 필요합니다',
          TimeoutError() => '요청 시간이 초과되었습니다',
          NetworkConnectionError() => '네트워크 연결을 확인해주세요',
          _ => '알 수 없는 오류가 발생했습니다',
        };

        state = state.copyWith(isLoading: false, error: errorMessage);

        // Analytics: 계산 실패 이벤트
        await _analytics.logCalculationFailed(
          calculationType: calculationTypeString,
          errorMessage: errorMessage,
        );

        // Crashlytics: 계산 에러 기록
        await _crashlytics.recordCalculationError(
          calculationType: calculationTypeString,
          error: error,
          additionalData: {
            'hire_date': hireDate.toIso8601String(),
            'reference_date': referenceDate.toIso8601String(),
          },
        );
    }
  }
}

class CalculatorState {
  final CalculationType calculationType;
  final DateTime? hireDate;
  final DateTime? referenceDate;
  final int fiscalYearStartMonth; // 회계연도 시작 월 (1-12)
  final List<NonWorkingPeriod> nonWorkingPeriods;
  final List<CompanyHoliday> companyHolidays;
  final bool isLoading;
  final AnnualLeave? result;
  final String? error;

  CalculatorState({
    this.calculationType = CalculationType.standard,
    this.hireDate,
    this.referenceDate,
    this.fiscalYearStartMonth = 1, // 기본값 1월
    List<NonWorkingPeriod>? nonWorkingPeriods,
    List<CompanyHoliday>? companyHolidays,
    this.isLoading = false,
    this.result,
    this.error,
  }) : nonWorkingPeriods = nonWorkingPeriods ?? [],
       companyHolidays = companyHolidays ?? [];

  CalculatorState copyWith({
    CalculationType? calculationType,
    DateTime? hireDate,
    DateTime? referenceDate,
    int? fiscalYearStartMonth,
    List<NonWorkingPeriod>? nonWorkingPeriods,
    List<CompanyHoliday>? companyHolidays,
    bool? isLoading,
    AnnualLeave? result,
    String? error,
  }) {
    return CalculatorState(
      calculationType: calculationType ?? this.calculationType,
      hireDate: hireDate ?? this.hireDate,
      referenceDate: referenceDate ?? this.referenceDate,
      fiscalYearStartMonth: fiscalYearStartMonth ?? this.fiscalYearStartMonth,
      nonWorkingPeriods: nonWorkingPeriods ?? this.nonWorkingPeriods,
      companyHolidays: companyHolidays ?? this.companyHolidays,
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
    );
  }
}
