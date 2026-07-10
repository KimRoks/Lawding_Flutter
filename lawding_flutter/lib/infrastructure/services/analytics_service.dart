import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  // 화면 조회 이벤트
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // 계산 타입 선택 이벤트
  Future<void> logCalculationTypeSelected(String calculationType) async {
    await _analytics.logEvent(
      name: 'calculation_type_selected',
      parameters: {'type': calculationType},
    );
  }

  // 입사일 선택 이벤트
  Future<void> logHireDateSelected(String date) async {
    await _analytics.logEvent(
      name: 'hire_date_selected',
      parameters: {'date': date},
    );
  }

  // 기준일 선택 이벤트
  Future<void> logReferenceDateSelected(String date) async {
    await _analytics.logEvent(
      name: 'reference_date_selected',
      parameters: {'date': date},
    );
  }

  // 회계연도 시작월 선택 이벤트
  Future<void> logFiscalYearStartMonthSelected(int month) async {
    await _analytics.logEvent(
      name: 'fiscal_year_start_month_selected',
      parameters: {'month': month},
    );
  }

  // 특이사항 기간 추가 이벤트
  Future<void> logNonWorkingPeriodAdded(String type) async {
    await _analytics.logEvent(
      name: 'non_working_period_added',
      parameters: {'type': type},
    );
  }

  // 특이사항 기간 삭제 이벤트
  Future<void> logNonWorkingPeriodRemoved(String type) async {
    await _analytics.logEvent(
      name: 'non_working_period_removed',
      parameters: {'type': type},
    );
  }

  // 회사 휴무일 추가 이벤트
  Future<void> logCompanyHolidayAdded(String displayName) async {
    await _analytics.logEvent(
      name: 'company_holiday_added',
      parameters: {'name': displayName},
    );
  }

  // 회사 휴무일 삭제 이벤트
  Future<void> logCompanyHolidayRemoved(String displayName) async {
    await _analytics.logEvent(
      name: 'company_holiday_removed',
      parameters: {'name': displayName},
    );
  }

  // 계산 시작 이벤트
  Future<void> logCalculationStarted(String calculationType) async {
    await _analytics.logEvent(
      name: 'calculation_started',
      parameters: {'type': calculationType},
    );
  }

  // 계산 완료 이벤트
  Future<void> logCalculationCompleted({
    required String calculationType,
    required String leaveType,
    required double totalDays,
    required int serviceYears,
  }) async {
    await _analytics.logEvent(
      name: 'calculation_completed',
      parameters: {
        'calculation_type': calculationType,
        'leave_type': leaveType,
        'total_days': totalDays,
        'service_years': serviceYears,
      },
    );
  }

  // 계산 실패 이벤트
  Future<void> logCalculationFailed({
    required String calculationType,
    required String errorMessage,
  }) async {
    await _analytics.logEvent(
      name: 'calculation_failed',
      parameters: {
        'calculation_type': calculationType,
        'error_message': errorMessage,
      },
    );
  }

  // 계산 기준 설명 보기 이벤트
  Future<void> logCalculationDetailViewed(String leaveType) async {
    await _analytics.logEvent(
      name: 'calculation_detail_viewed',
      parameters: {'leave_type': leaveType},
    );
  }

  // 월차/비례연차 세그먼트 변경 이벤트
  Future<void> logDetailSegmentChanged(String segmentType) async {
    await _analytics.logEvent(
      name: 'detail_segment_changed',
      parameters: {'segment': segmentType},
    );
  }

  // 도움말 버튼 클릭 이벤트
  Future<void> logHelpButtonClicked(String helpType) async {
    await _analytics.logEvent(
      name: 'help_button_clicked',
      parameters: {'type': helpType},
    );
  }

  // 도움말 시트 확장 이벤트
  Future<void> logHelpSheetExpanded(String helpType) async {
    await _analytics.logEvent(
      name: 'help_sheet_expanded',
      parameters: {'type': helpType},
    );
  }

  // 외부 링크 클릭 이벤트
  Future<void> logExternalLinkClicked(String linkType, String url) async {
    await _analytics.logEvent(
      name: 'external_link_clicked',
      parameters: {'link_type': linkType, 'url': url},
    );
  }

  // 피드백 화면 진입 이벤트
  Future<void> logFeedbackScreenOpened({String? calculationId}) async {
    await _analytics.logEvent(
      name: 'feedback_screen_opened',
      parameters: {'has_calculation_id': calculationId != null},
    );
  }

  // 피드백 타입 선택 이벤트
  Future<void> logFeedbackTypeSelected(String feedbackType) async {
    await _analytics.logEvent(
      name: 'feedback_type_selected',
      parameters: {'type': feedbackType},
    );
  }

  // 피드백 제출 시작 이벤트
  Future<void> logFeedbackSubmitStarted({
    required String feedbackType,
    required bool includeCalculationData,
  }) async {
    await _analytics.logEvent(
      name: 'feedback_submit_started',
      parameters: {
        'type': feedbackType,
        'include_calculation_data': includeCalculationData,
      },
    );
  }

  // 피드백 제출 성공 이벤트
  Future<void> logFeedbackSubmitted({
    required String feedbackType,
    required bool includeCalculationData,
  }) async {
    await _analytics.logEvent(
      name: 'feedback_submitted',
      parameters: {
        'type': feedbackType,
        'include_calculation_data': includeCalculationData,
      },
    );
  }

  // 피드백 제출 실패 이벤트
  Future<void> logFeedbackSubmitFailed({
    required String feedbackType,
    required String errorMessage,
  }) async {
    await _analytics.logEvent(
      name: 'feedback_submit_failed',
      parameters: {'type': feedbackType, 'error_message': errorMessage},
    );
  }

  // 웹뷰 화면 열기 이벤트
  Future<void> logWebViewOpened(String url, String title) async {
    await _analytics.logEvent(
      name: 'webview_opened',
      parameters: {'url': url, 'title': title},
    );
  }

  // 약관 동의 이벤트
  Future<void> logTermsAgreed() async {
    await _analytics.logEvent(name: 'terms_agreed');
  }

  // 개인정보처리방침 보기 이벤트
  Future<void> logPrivacyPolicyViewed() async {
    await _analytics.logEvent(name: 'privacy_policy_viewed');
  }

  // 앱 시작 이벤트
  Future<void> logAppLaunched() async {
    await _analytics.logEvent(name: 'app_launched');
  }

  // 인앱 리뷰 요청 노출 이벤트
  Future<void> logInAppReviewRequested({required String trigger}) async {
    await _analytics.logEvent(
      name: 'in_app_review_requested',
      parameters: {'trigger': trigger},
    );
  }

  // 스플래시 화면 완료 이벤트
  Future<void> logSplashCompleted(int durationMs) async {
    await _analytics.logEvent(
      name: 'splash_completed',
      parameters: {'duration_ms': durationMs},
    );
  }

  // 사용자 속성 설정
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // 사용자 ID 설정
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  // 용어 사전 화면 조회 이벤트
  Future<void> logDictionaryScreenViewed() async {
    await _analytics.logEvent(name: 'dictionary_screen_viewed');
  }

  // 용어 사전 안내 다이얼로그 표시 이벤트
  Future<void> logDictionaryGuideShown() async {
    await _analytics.logEvent(name: 'dictionary_guide_shown');
  }

  // 용어 사전 안내 다이얼로그 닫기 이벤트
  Future<void> logDictionaryGuideDismissed() async {
    await _analytics.logEvent(name: 'dictionary_guide_dismissed');
  }

  // 용어 사전 검색 이벤트
  Future<void> logDictionarySearchPerformed({
    required String query,
    required int resultCount,
  }) async {
    await _analytics.logEvent(
      name: 'dictionary_search_performed',
      parameters: {'query_length': query.length, 'result_count': resultCount},
    );
  }

  // 용어 사전 검색 초기화 이벤트
  Future<void> logDictionarySearchCleared() async {
    await _analytics.logEvent(name: 'dictionary_search_cleared');
  }

  // 용어 사전 카테고리 선택 이벤트
  Future<void> logDictionaryCategorySelected({
    required String categoryName,
    required int resultCount,
  }) async {
    await _analytics.logEvent(
      name: 'dictionary_category_selected',
      parameters: {'category': categoryName, 'result_count': resultCount},
    );
  }

  // 용어 사전 항목 펼치기 이벤트
  Future<void> logDictionaryItemExpanded({
    required int dictionaryId,
    required String question,
    required String category,
  }) async {
    await _analytics.logEvent(
      name: 'dictionary_item_expanded',
      parameters: {
        'dictionary_id': dictionaryId,
        'question_length': question.length,
        'category': category,
      },
    );
  }

  // 용어 사전 항목 접기 이벤트
  Future<void> logDictionaryItemCollapsed(int dictionaryId) async {
    await _analytics.logEvent(
      name: 'dictionary_item_collapsed',
      parameters: {'dictionary_id': dictionaryId},
    );
  }

  // 용어 사전 데이터 로딩 성공 이벤트
  Future<void> logDictionaryDataLoaded({
    required int totalCount,
    required int categoryCount,
  }) async {
    await _analytics.logEvent(
      name: 'dictionary_data_loaded',
      parameters: {'total_count': totalCount, 'category_count': categoryCount},
    );
  }

  // 용어 사전 데이터 로딩 실패 이벤트
  Future<void> logDictionaryDataLoadFailed(String errorMessage) async {
    await _analytics.logEvent(
      name: 'dictionary_data_load_failed',
      parameters: {'error_message': errorMessage},
    );
  }

  // 용어 사전 재시도 버튼 클릭 이벤트
  Future<void> logDictionaryRetryPressed() async {
    await _analytics.logEvent(name: 'dictionary_retry_pressed');
  }
}
