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

  // ── 로그인 ────────────────────────────────────────────────────────────────

  // 로그인 화면 진입
  Future<void> logLoginScreenViewed() async {
    await _analytics.logEvent(name: 'login_screen_viewed');
  }

  // OAuth 버튼 탭
  Future<void> logLoginMethodTapped(String method) async {
    await _analytics.logEvent(
      name: 'login_method_tapped',
      parameters: {'method': method}, // 'apple' | 'google' | 'kakao'
    );
  }

  // 건너뛰기 탭
  Future<void> logLoginSkipTapped() async {
    await _analytics.logEvent(name: 'login_skip_tapped');
  }

  // 로그인 성공 (OAuth 콜백 수신 후)
  Future<void> logLoginSucceeded({required bool onboardingCompleted}) async {
    await _analytics.logEvent(
      name: 'login_succeeded',
      parameters: {'onboarding_completed': onboardingCompleted ? 1 : 0},
    );
  }

  // OAuth URL 실행 실패
  Future<void> logLoginFailed({
    required String method,
    required String errorMessage,
  }) async {
    await _analytics.logEvent(
      name: 'login_failed',
      parameters: {'method': method, 'error_message': errorMessage},
    );
  }

  // ── 회원가입 정보 입력 (UserInfo) ──────────────────────────────────────────

  // 화면 진입
  Future<void> logUserInfoScreenViewed() async {
    await _analytics.logEvent(name: 'user_info_screen_viewed');
  }

  // 전체 약관 토글
  Future<void> logUserInfoAllTermsToggled({required bool agreed}) async {
    await _analytics.logEvent(
      name: 'user_info_all_terms_toggled',
      parameters: {'agreed': agreed ? 1 : 0},
    );
  }

  // 개별 약관 토글
  Future<void> logUserInfoTermToggled({
    required int termIndex,
    required bool agreed,
  }) async {
    await _analytics.logEvent(
      name: 'user_info_term_toggled',
      parameters: {'term_index': termIndex, 'agreed': agreed ? 1 : 0},
    );
  }

  // 다음 버튼 탭
  Future<void> logUserInfoNextTapped() async {
    await _analytics.logEvent(name: 'user_info_next_tapped');
  }

  // ── 튜토리얼 ──────────────────────────────────────────────────────────────

  // 튜토리얼 화면 진입
  Future<void> logTutorialScreenViewed() async {
    await _analytics.logEvent(name: 'tutorial_screen_viewed');
  }

  // 페이지 이동 (스와이프 or 버튼)
  Future<void> logTutorialPageChanged(int page) async {
    await _analytics.logEvent(
      name: 'tutorial_page_changed',
      parameters: {'page': page}, // 0-based
    );
  }

  // 마지막 페이지 "시작하기" 탭 → 튜토리얼 완료
  Future<void> logTutorialFinished() async {
    await _analytics.logEvent(name: 'tutorial_finished');
  }

  // ── 기본 정보 입력 (BasicInfo) ────────────────────────────────────────────

  // 화면 진입
  Future<void> logBasicInfoScreenViewed({required bool isEditMode}) async {
    await _analytics.logEvent(
      name: 'basic_info_screen_viewed',
      parameters: {'is_edit_mode': isEditMode ? 1 : 0},
    );
  }

  // 스텝 진입 (onPageChanged)
  Future<void> logBasicInfoStepViewed(int step) async {
    await _analytics.logEvent(
      name: 'basic_info_step_viewed',
      parameters: {'step': step}, // 0-based (0=이름/약관 … 5=사용연차)
    );
  }

  // 뒤로 버튼 탭
  Future<void> logBasicInfoBackTapped(int fromStep) async {
    await _analytics.logEvent(
      name: 'basic_info_back_tapped',
      parameters: {'from_step': fromStep},
    );
  }

  // 제출 성공
  Future<void> logBasicInfoSubmitSucceeded({required bool isEditMode}) async {
    await _analytics.logEvent(
      name: 'basic_info_submit_succeeded',
      parameters: {'is_edit_mode': isEditMode ? 1 : 0},
    );
  }

  // 제출 실패
  Future<void> logBasicInfoSubmitFailed(String errorMessage) async {
    await _analytics.logEvent(
      name: 'basic_info_submit_failed',
      parameters: {'error_message': errorMessage},
    );
  }

  // 수동 연차 입력 버튼 탭 (Step5)
  Future<void> logBasicInfoManualEntryTapped() async {
    await _analytics.logEvent(name: 'basic_info_manual_entry_tapped');
  }

  // 수동 연차 입력 결과 확정 (Step5)
  Future<void> logBasicInfoManualResultEntered(double totalDays) async {
    await _analytics.logEvent(
      name: 'basic_info_manual_result_entered',
      parameters: {'total_days': totalDays},
    );
  }

  // 수동 입력 화면 진입
  Future<void> logManualEntryScreenViewed() async {
    await _analytics.logEvent(name: 'manual_entry_screen_viewed');
  }

  // 수동 입력 확인 ("다음" 탭)
  Future<void> logManualEntryConfirmed(double totalLeave) async {
    await _analytics.logEvent(
      name: 'manual_entry_confirmed',
      parameters: {'total_leave': totalLeave},
    );
  }

  // ── 캘린더 ────────────────────────────────────────────────────────────────

  // 캘린더 화면 진입
  Future<void> logCalendarScreenViewed() async {
    await _analytics.logEvent(name: 'calendar_screen_viewed');
  }

  // 캘린더 날짜 탭 (날짜 포커스)
  Future<void> logCalendarDateTapped() async {
    await _analytics.logEvent(name: 'calendar_date_tapped');
  }

  // 캘린더 날짜 포커스 해제 (같은 날짜 재탭)
  Future<void> logCalendarDateUnfocused() async {
    await _analytics.logEvent(name: 'calendar_date_unfocused');
  }

  // 캘린더 월 이동
  Future<void> logCalendarMonthChanged(String direction) async {
    await _analytics.logEvent(
      name: 'calendar_month_changed',
      parameters: {'direction': direction}, // 'prev' | 'next'
    );
  }

  // 일정 추가 버튼 탭 (+ 버튼)
  Future<void> logCalendarAddEventTapped() async {
    await _analytics.logEvent(name: 'calendar_add_event_tapped');
  }

  // 이벤트 카드 3-dot 메뉴 열기
  Future<void> logCalendarEventOptionsOpened(String eventType) async {
    await _analytics.logEvent(
      name: 'calendar_event_options_opened',
      parameters: {'event_type': eventType}, // 'annual_leave' | 'other_leave'
    );
  }

  // 이벤트 수정 탭
  Future<void> logCalendarEventEditTapped(String eventType) async {
    await _analytics.logEvent(
      name: 'calendar_event_edit_tapped',
      parameters: {'event_type': eventType},
    );
  }

  // 이벤트 삭제 확인 탭
  Future<void> logCalendarEventDeleteConfirmed(String eventType) async {
    await _analytics.logEvent(
      name: 'calendar_event_delete_confirmed',
      parameters: {'event_type': eventType},
    );
  }

  // 이벤트 삭제 성공
  Future<void> logCalendarEventDeleted(String eventType) async {
    await _analytics.logEvent(
      name: 'calendar_event_deleted',
      parameters: {'event_type': eventType},
    );
  }

  // 이벤트 삭제 실패
  Future<void> logCalendarEventDeleteFailed(String errorMessage) async {
    await _analytics.logEvent(
      name: 'calendar_event_delete_failed',
      parameters: {'error_message': errorMessage},
    );
  }

  // 일정 등록/수정 화면 진입
  Future<void> logCalendarEventFormScreenViewed({required bool isEdit}) async {
    await _analytics.logEvent(
      name: 'calendar_event_form_screen_viewed',
      parameters: {'is_edit': isEdit ? 1 : 0},
    );
  }

  // 날짜 선택 완료 (단일 or 기간)
  Future<void> logCalendarEventDateSelected({required bool isRange}) async {
    await _analytics.logEvent(
      name: 'calendar_event_date_selected',
      parameters: {'is_range': isRange ? 1 : 0},
    );
  }

  // 시간 선택 완료
  Future<void> logCalendarEventTimeSet(String timeType) async {
    await _analytics.logEvent(
      name: 'calendar_event_time_set',
      parameters: {'time_type': timeType}, // 'start' | 'end'
    );
  }

  // 연차/일반 토글
  Future<void> logCalendarEventLeaveTypeToggled({required bool isLeaveEvent}) async {
    await _analytics.logEvent(
      name: 'calendar_event_leave_type_toggled',
      parameters: {'is_leave_event': isLeaveEvent ? 1 : 0},
    );
  }

  // 종일/시간 토글
  Future<void> logCalendarEventAllDayToggled({required bool isAllDay}) async {
    await _analytics.logEvent(
      name: 'calendar_event_allday_toggled',
      parameters: {'is_all_day': isAllDay ? 1 : 0},
    );
  }

  // 등록/수정 버튼 탭
  Future<void> logCalendarEventSubmitTapped({required bool isEdit}) async {
    await _analytics.logEvent(
      name: 'calendar_event_submit_tapped',
      parameters: {'is_edit': isEdit ? 1 : 0},
    );
  }

  // 등록/수정 차단 (유효성 검사 실패)
  Future<void> logCalendarEventSubmitBlocked(String reason) async {
    await _analytics.logEvent(
      name: 'calendar_event_submit_blocked',
      // 'no_date' | 'all_holiday' | 'no_work_overlap' | 'break_time_only'
      parameters: {'reason': reason},
    );
  }

  // 등록 성공
  Future<void> logCalendarEventRegistered({
    required bool isAllDay,
    required bool isRange,
  }) async {
    await _analytics.logEvent(
      name: 'calendar_event_registered',
      parameters: {'is_all_day': isAllDay ? 1 : 0, 'is_range': isRange ? 1 : 0},
    );
  }

  // 등록 실패
  Future<void> logCalendarEventRegisterFailed(String errorMessage) async {
    await _analytics.logEvent(
      name: 'calendar_event_register_failed',
      parameters: {'error_message': errorMessage},
    );
  }

  // 수정 성공
  Future<void> logCalendarEventUpdated() async {
    await _analytics.logEvent(name: 'calendar_event_updated');
  }

  // 수정 실패
  Future<void> logCalendarEventUpdateFailed(String errorMessage) async {
    await _analytics.logEvent(
      name: 'calendar_event_update_failed',
      parameters: {'error_message': errorMessage},
    );
  }

  // ── 대시보드 ──────────────────────────────────────────────────────────────

  // 대시보드 화면 진입
  Future<void> logDashboardScreenViewed() async {
    await _analytics.logEvent(name: 'dashboard_screen_viewed');
  }

  // 빠른 액션 버튼 탭 ('calculator' | 'calendar')
  Future<void> logDashboardActionTapped(String action) async {
    await _analytics.logEvent(
      name: 'dashboard_action_tapped',
      parameters: {'action': action},
    );
  }

  // 최근 연차 내역 상세 탭
  Future<void> logDashboardLeaveHistoryTapped() async {
    await _analytics.logEvent(name: 'dashboard_leave_history_tapped');
  }

  // ── 설정 ──────────────────────────────────────────────────────────────────

  // 설정 화면 진입
  Future<void> logSettingScreenViewed() async {
    await _analytics.logEvent(name: 'setting_screen_viewed');
  }

  // 닉네임 변경 탭
  Future<void> logSettingNicknameTapped() async {
    await _analytics.logEvent(name: 'setting_nickname_tapped');
  }

  // 로그아웃 확인
  Future<void> logSettingLogoutConfirmed() async {
    await _analytics.logEvent(name: 'setting_logout_confirmed');
  }

  // 계정 탈퇴 확인
  Future<void> logSettingDeleteAccountConfirmed() async {
    await _analytics.logEvent(name: 'setting_delete_account_confirmed');
  }

  // 계정 탈퇴 실패
  Future<void> logSettingDeleteAccountFailed(String errorMessage) async {
    await _analytics.logEvent(
      name: 'setting_delete_account_failed',
      parameters: {'error_message': errorMessage},
    );
  }

  // ── 닉네임 변경 ───────────────────────────────────────────────────────────

  // 닉네임 변경 화면 진입
  Future<void> logChangeNicknameScreenViewed() async {
    await _analytics.logEvent(name: 'change_nickname_screen_viewed');
  }

  // 닉네임 변경 성공
  Future<void> logNicknameChangeSucceeded() async {
    await _analytics.logEvent(name: 'nickname_change_succeeded');
  }

  // 닉네임 변경 실패
  Future<void> logNicknameChangeFailed(String errorMessage) async {
    await _analytics.logEvent(
      name: 'nickname_change_failed',
      parameters: {'error_message': errorMessage},
    );
  }

  // ── 최근 연차 사용 내역 ────────────────────────────────────────────────────

  // 최근 연차 사용 내역 화면 진입
  Future<void> logRecentLeaveHistoryScreenViewed() async {
    await _analytics.logEvent(name: 'recent_leave_history_screen_viewed');
  }

  // ── 남은 연차 설정 ─────────────────────────────────────────────────────────

  // 남은 연차 설정 화면 진입
  Future<void> logLeaveTimeEditScreenViewed() async {
    await _analytics.logEvent(name: 'leave_time_edit_screen_viewed');
  }

  // 수정하기 모달 열기
  Future<void> logLeaveTimeEditModalOpened() async {
    await _analytics.logEvent(name: 'leave_time_edit_modal_opened');
  }

  // 등록하기 성공
  Future<void> logLeaveTimeEditSubmitSucceeded() async {
    await _analytics.logEvent(name: 'leave_time_edit_submit_succeeded');
  }

  // 등록하기 실패
  Future<void> logLeaveTimeEditSubmitFailed(String errorMessage) async {
    await _analytics.logEvent(
      name: 'leave_time_edit_submit_failed',
      parameters: {'error_message': errorMessage},
    );
  }

  // 계산하러 가기 탭
  Future<void> logLeaveTimeEditCalculatorTapped() async {
    await _analytics.logEvent(name: 'leave_time_edit_calculator_tapped');
  }

  // ── 탭 전환 ────────────────────────────────────────────────────────────────

  // 탭 변경 (index: 0=대시보드, 1=계산기, 2=사전, 3=캘린더)
  Future<void> logTabChanged({
    required int index,
    required String tabName,
  }) async {
    await _analytics.logEvent(
      name: 'tab_changed',
      parameters: {'index': index, 'tab_name': tabName},
    );
  }
}
