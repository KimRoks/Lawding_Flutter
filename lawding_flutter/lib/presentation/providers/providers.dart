import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/annual_leave_calculator/calculator_repository_impl.dart';
import '../../data/app_version/app_version_repository_impl.dart';
import '../../data/dictionary/dictionary_repository_impl.dart';
import '../../data/feedback/feedback_repository_impl.dart';
import '../../data/holiday/holiday_repository_impl.dart';
import '../../data/auth/auth_repository_impl.dart';
import '../../data/calendar_event/calendar_event_repository_impl.dart';
import '../../data/leave_dashboard/leave_dashboard_repository_impl.dart';
import '../../data/leave_policy/leave_policy_repository_impl.dart';
import '../../data/network/dio_client.dart';
import '../../data/user/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/annual_leave_repository.dart';
import '../../domain/repositories/app_version_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/calendar_event_repository.dart';
import '../../domain/repositories/dictionary_repository.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../../domain/repositories/holiday_repository.dart';
import '../../domain/repositories/leave_dashboard_repository.dart';
import '../../domain/repositories/leave_policy_repository.dart';
import '../../domain/usecases/calculate_annual_leave_usecase.dart';
import '../../domain/usecases/create_calendar_event_usecase.dart';
import '../../domain/usecases/delete_calendar_event_usecase.dart';
import '../../domain/usecases/get_calendar_event_usecase.dart';
import '../../domain/usecases/get_calendar_events_usecase.dart';
import '../../domain/usecases/get_dictionaries_usecase.dart';
import '../../domain/usecases/get_holidays_usecase.dart';
import '../../domain/usecases/get_leave_summary_usecase.dart';
import '../../domain/usecases/get_user_dashboard_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/search_dictionary_usecase.dart';
import '../../domain/usecases/submit_feedback_usecase.dart';
import '../../domain/usecases/get_leave_policy_usecase.dart';
import '../../domain/usecases/submit_leave_policy_usecase.dart';
import '../../domain/usecases/update_leave_policy_usecase.dart';
import '../../domain/usecases/update_calendar_event_usecase.dart';
import '../../domain/usecases/get_leave_dashboard_usecase.dart';

part 'providers.g.dart';

/// 현재 활성 탭 인덱스 — 탭 외부(설정 등)에서 탭 전환이 필요할 때 사용
final activeTabIndexProvider = StateProvider<int>((ref) => 0);

/// 캘린더 탭 로그인 상태 — 로그아웃 시 외부에서 false로 리셋 가능
final calendarAuthStateProvider = StateProvider<bool>((ref) => false);

/// 캘린더 refresh 신호 — increment 시 CalendarScreen이 이벤트 목록을 재조회
final calendarRefreshProvider = StateProvider<int>((ref) => 0);

// ============================================================================
// Infrastructure Layer (Network)
// ============================================================================

/// AuthRepository Provider
/// 토큰 저장/조회/삭제 Repository 구현체 제공
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl();
}

/// DioClient Provider — 공개 API용 (토큰 없음)
@riverpod
DioClient dioClient(Ref ref) {
  final baseUrl = dotenv.env['BASE_URL'] ?? 'https://api.default.com';
  return DioClient(baseUrl: baseUrl);
}

/// Auth DioClient Provider — 로그인 필요 API용 (Bearer 토큰 주입 + 401 재시도)
@riverpod
DioClient authDioClient(Ref ref) {
  final baseUrl = dotenv.env['BASE_URL'] ?? 'https://api.default.com';
  final auth = ref.watch(authRepositoryProvider);
  return DioClient(baseUrl: baseUrl, authRepository: auth);
}

/// baseUrl Provider
/// .env의 BASE_URL 제공
@riverpod
String baseUrl(Ref ref) {
  return dotenv.env['BASE_URL'] ?? 'https://api.default.com';
}

// ============================================================================
// Data Layer (Repositories)
// ============================================================================

/// AnnualLeaveRepository Provider
/// 연차 계산 Repository 구현체 제공
@riverpod
AnnualLeaveRepository annualLeaveRepository(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AnnualLeaveRepositoryImpl(dioClient);
}

/// FeedbackRepository Provider
/// 피드백 제출 Repository 구현체 제공
@riverpod
FeedbackRepository feedbackRepository(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return FeedbackRepositoryImpl(dioClient);
}

/// AppVersionRepository Provider
/// 앱 버전 체크 Repository 구현체 제공
@riverpod
AppVersionRepository appVersionRepository(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AppVersionRepositoryImpl(dioClient);
}

/// HolidayRepository Provider
/// 공휴일 목록 조회 Repository 구현체 제공
@riverpod
HolidayRepository holidayRepository(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return HolidayRepositoryImpl(dioClient);
}

/// GetHolidaysUseCase Provider
/// 공휴일 목록 조회 비즈니스 로직 제공
@riverpod
GetHolidaysUseCase getHolidaysUseCase(Ref ref) {
  final repository = ref.watch(holidayRepositoryProvider);
  return GetHolidaysUseCase(repository);
}

/// CalendarEventRepository Provider
/// 캘린더 이벤트 조회 Repository 구현체 제공 (로그인 필요)
@riverpod
CalendarEventRepository calendarEventRepository(Ref ref) {
  final dioClient = ref.watch(authDioClientProvider);
  return CalendarEventRepositoryImpl(dioClient);
}

// ============================================================================
// Domain Layer (UseCases)
// ============================================================================

/// CalculateAnnualLeaveUseCase Provider
/// 연차 계산 비즈니스 로직 제공
@riverpod
CalculateAnnualLeaveUseCase calculateAnnualLeaveUseCase(Ref ref) {
  final repository = ref.watch(annualLeaveRepositoryProvider);
  return CalculateAnnualLeaveUseCase(repository);
}

/// SubmitFeedbackUseCase Provider
/// 피드백 제출 비즈니스 로직 제공
@riverpod
SubmitFeedbackUseCase submitFeedbackUseCase(Ref ref) {
  final repository = ref.watch(feedbackRepositoryProvider);
  return SubmitFeedbackUseCase(repository);
}

/// DictionaryRepository Provider
/// 용어 사전 Repository 구현체 제공
@riverpod
DictionaryRepository dictionaryRepository(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DictionaryRepositoryImpl(dioClient);
}

/// GetDictionariesUseCase Provider
/// 전체 용어 사전 목록 조회 비즈니스 로직 제공
@riverpod
GetDictionariesUseCase getDictionariesUseCase(Ref ref) {
  final repository = ref.watch(dictionaryRepositoryProvider);
  return GetDictionariesUseCase(repository);
}

/// SearchDictionaryUseCase Provider
/// 용어 사전 검색 비즈니스 로직 제공
@riverpod
SearchDictionaryUseCase searchDictionaryUseCase(Ref ref) {
  final repository = ref.watch(dictionaryRepositoryProvider);
  return SearchDictionaryUseCase(repository);
}

/// UserRepository Provider
/// 유저 정보 조회 Repository 구현체 제공 (로그인 필요)
@riverpod
UserRepository userRepository(Ref ref) {
  final dioClient = ref.watch(authDioClientProvider);
  return UserRepositoryImpl(dioClient);
}

/// GetUserDashboardUseCase Provider
/// 내 대시보드 정보 조회 비즈니스 로직 제공
@riverpod
GetUserDashboardUseCase getUserDashboardUseCase(Ref ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUserDashboardUseCase(repository);
}

/// GetLeaveSummaryUseCase Provider
/// 남은 연차 요약 조회 비즈니스 로직 제공
@riverpod
GetLeaveSummaryUseCase getLeaveSummaryUseCase(Ref ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetLeaveSummaryUseCase(repository);
}

/// GetCalendarEventsUseCase Provider
/// 월별 캘린더 이벤트 목록 조회 비즈니스 로직 제공
@riverpod
GetCalendarEventsUseCase getCalendarEventsUseCase(Ref ref) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return GetCalendarEventsUseCase(repository);
}

/// GetCalendarEventUseCase Provider
/// 단건 캘린더 이벤트 조회 비즈니스 로직 제공
@riverpod
GetCalendarEventUseCase getCalendarEventUseCase(Ref ref) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return GetCalendarEventUseCase(repository);
}

/// CreateCalendarEventUseCase Provider
/// 캘린더 이벤트 생성 비즈니스 로직 제공
@riverpod
CreateCalendarEventUseCase createCalendarEventUseCase(Ref ref) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return CreateCalendarEventUseCase(repository);
}

/// UpdateCalendarEventUseCase Provider
/// 캘린더 이벤트 수정 비즈니스 로직 제공
@riverpod
UpdateCalendarEventUseCase updateCalendarEventUseCase(Ref ref) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return UpdateCalendarEventUseCase(repository);
}

/// DeleteCalendarEventUseCase Provider
/// 캘린더 이벤트 삭제 비즈니스 로직 제공
@riverpod
DeleteCalendarEventUseCase deleteCalendarEventUseCase(Ref ref) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return DeleteCalendarEventUseCase(repository);
}

/// LeavePolicyRepository Provider
/// 연차 정책 Repository 구현체 제공 (로그인 필요)
@riverpod
LeavePolicyRepository leavePolicyRepository(Ref ref) {
  final dioClient = ref.watch(authDioClientProvider);
  return LeavePolicyRepositoryImpl(dioClient);
}

/// SubmitLeavePolicyUseCase Provider
/// 연차 정책 등록 비즈니스 로직 제공
@riverpod
SubmitLeavePolicyUseCase submitLeavePolicyUseCase(Ref ref) {
  final repository = ref.watch(leavePolicyRepositoryProvider);
  return SubmitLeavePolicyUseCase(repository);
}

/// UpdateLeavePolicyUseCase Provider
/// 연차 정책 수정 비즈니스 로직 제공
@riverpod
UpdateLeavePolicyUseCase updateLeavePolicyUseCase(Ref ref) {
  final repository = ref.watch(leavePolicyRepositoryProvider);
  return UpdateLeavePolicyUseCase(repository);
}

/// GetLeavePolicyUseCase Provider
/// 연차 정책 조회 비즈니스 로직 제공
@riverpod
GetLeavePolicyUseCase getLeavePolicyUseCase(Ref ref) {
  final repository = ref.watch(leavePolicyRepositoryProvider);
  return GetLeavePolicyUseCase(repository);
}

/// dailyWorkMinutesProvider — 하루 평균 순 근무시간(분)
/// 로그인 후 fetch된 LeavePolicy에서 계산. 미조회 시 기본값 480(8시간)
final dailyWorkMinutesProvider = StateProvider<int>((ref) => 480);

/// avgDailyWorkHoursProvider — 하루 평균 근무시간(시간 단위)
/// 로그인/정보변경 후 fetch된 LeaveSummary의 avgDailyWorkHours. 미조회 시 기본값 8.0
final avgDailyWorkHoursProvider = StateProvider<double>((ref) => 8.0);

/// GetUserProfileUseCase Provider
/// 유저 프로필 조회 비즈니스 로직 제공
@riverpod
GetUserProfileUseCase getUserProfileUseCase(Ref ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUserProfileUseCase(repository);
}

/// LeaveDashboardRepository Provider
/// 연차 대시보드 조회 Repository 구현체 제공 (로그인 필요)
@riverpod
LeaveDashboardRepository leaveDashboardRepository(Ref ref) {
  final dioClient = ref.watch(authDioClientProvider);
  return LeaveDashboardRepositoryImpl(dioClient);
}

/// GetLeaveDashboardUseCase Provider
/// 연차 대시보드 조회 비즈니스 로직 제공
@riverpod
GetLeaveDashboardUseCase getLeaveDashboardUseCase(Ref ref) {
  final repository = ref.watch(leaveDashboardRepositoryProvider);
  return GetLeaveDashboardUseCase(repository);
}
