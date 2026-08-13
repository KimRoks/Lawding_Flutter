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
import '../../domain/usecases/search_dictionary_usecase.dart';
import '../../domain/usecases/submit_feedback_usecase.dart';
import '../../domain/usecases/submit_leave_policy_usecase.dart';
import '../../domain/usecases/update_calendar_event_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/update_remaining_leave_minutes_usecase.dart';
import '../../domain/usecases/get_leave_dashboard_usecase.dart';
import '../../domain/usecases/get_user_me_usecase.dart';

part 'providers.g.dart';

/// 현재 활성 탭 인덱스 — 탭 외부(설정 등)에서 탭 전환이 필요할 때 사용
final activeTabIndexProvider = StateProvider<int>((ref) => 0);

/// 캘린더 탭 로그인 상태 — 로그아웃 시 외부에서 false로 리셋 가능
final calendarAuthStateProvider = StateProvider<bool>((ref) => false);

/// 연차 데이터 refresh 신호 — increment 시 캘린더/대시보드가 데이터를 재조회
final leaveDataRefreshProvider = StateProvider<int>((ref) => 0);

/// dailyWorkMinutesProvider — 하루 평균 순 근무시간(분)
/// 로그인 후 getUserMeUseCase에서 설정. 미조회 시 기본값 480(8시간)
final dailyWorkMinutesProvider = StateProvider<int>((ref) => 480);

// ============================================================================
// Infrastructure Layer (Network)
// ============================================================================

/// AuthRepository Provider — keepAlive: 앱 전체에서 단일 인스턴스 유지
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final impl = AuthRepositoryImpl();
  ref.onDispose(impl.dispose);
  return impl;
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
@riverpod
String baseUrl(Ref ref) {
  return dotenv.env['BASE_URL'] ?? 'https://api.default.com';
}

// ============================================================================
// Data Layer (Repositories)
// ============================================================================

@riverpod
AnnualLeaveRepository annualLeaveRepository(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AnnualLeaveRepositoryImpl(dioClient);
}

@riverpod
FeedbackRepository feedbackRepository(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return FeedbackRepositoryImpl(dioClient);
}

@riverpod
AppVersionRepository appVersionRepository(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AppVersionRepositoryImpl(dioClient);
}

@riverpod
HolidayRepository holidayRepository(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return HolidayRepositoryImpl(dioClient);
}

@riverpod
DictionaryRepository dictionaryRepository(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DictionaryRepositoryImpl(dioClient);
}

@riverpod
CalendarEventRepository calendarEventRepository(Ref ref) {
  final dioClient = ref.watch(authDioClientProvider);
  return CalendarEventRepositoryImpl(dioClient);
}

@riverpod
LeavePolicyRepository leavePolicyRepository(Ref ref) {
  final dioClient = ref.watch(authDioClientProvider);
  return LeavePolicyRepositoryImpl(dioClient);
}

@riverpod
UserRepository userRepository(Ref ref) {
  final dioClient = ref.watch(authDioClientProvider);
  return UserRepositoryImpl(dioClient);
}

@riverpod
LeaveDashboardRepository leaveDashboardRepository(Ref ref) {
  final dioClient = ref.watch(authDioClientProvider);
  return LeaveDashboardRepositoryImpl(dioClient);
}

// ============================================================================
// Domain Layer (UseCases)
// ============================================================================

@riverpod
CalculateAnnualLeaveUseCase calculateAnnualLeaveUseCase(Ref ref) {
  final repository = ref.watch(annualLeaveRepositoryProvider);
  return CalculateAnnualLeaveUseCase(repository);
}

@riverpod
SubmitFeedbackUseCase submitFeedbackUseCase(Ref ref) {
  final repository = ref.watch(feedbackRepositoryProvider);
  return SubmitFeedbackUseCase(repository);
}

@riverpod
GetDictionariesUseCase getDictionariesUseCase(Ref ref) {
  final repository = ref.watch(dictionaryRepositoryProvider);
  return GetDictionariesUseCase(repository);
}

@riverpod
SearchDictionaryUseCase searchDictionaryUseCase(Ref ref) {
  final repository = ref.watch(dictionaryRepositoryProvider);
  return SearchDictionaryUseCase(repository);
}

@riverpod
GetHolidaysUseCase getHolidaysUseCase(Ref ref) {
  final repository = ref.watch(holidayRepositoryProvider);
  return GetHolidaysUseCase(repository);
}

@riverpod
GetCalendarEventsUseCase getCalendarEventsUseCase(Ref ref) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return GetCalendarEventsUseCase(repository);
}

@riverpod
GetCalendarEventUseCase getCalendarEventUseCase(Ref ref) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return GetCalendarEventUseCase(repository);
}

@riverpod
CreateCalendarEventUseCase createCalendarEventUseCase(Ref ref) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return CreateCalendarEventUseCase(repository);
}

@riverpod
UpdateCalendarEventUseCase updateCalendarEventUseCase(Ref ref) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return UpdateCalendarEventUseCase(repository);
}

@riverpod
DeleteCalendarEventUseCase deleteCalendarEventUseCase(Ref ref) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return DeleteCalendarEventUseCase(repository);
}

@riverpod
SubmitLeavePolicyUseCase submitLeavePolicyUseCase(Ref ref) {
  final repository = ref.watch(leavePolicyRepositoryProvider);
  return SubmitLeavePolicyUseCase(repository);
}

@riverpod
GetLeaveDashboardUseCase getLeaveDashboardUseCase(Ref ref) {
  final repository = ref.watch(leaveDashboardRepositoryProvider);
  return GetLeaveDashboardUseCase(repository);
}

@riverpod
UpdateProfileUseCase updateProfileUseCase(Ref ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateProfileUseCase(repository);
}

@riverpod
UpdateRemainingLeaveMinutesUseCase updateRemainingLeaveMinutesUseCase(Ref ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateRemainingLeaveMinutesUseCase(repository);
}

@riverpod
DeleteAccountUseCase deleteAccountUseCase(Ref ref) {
  final repository = ref.watch(userRepositoryProvider);
  return DeleteAccountUseCase(repository);
}

/// GetUserMeUseCase Provider
/// 내 전체 정보 조회 비즈니스 로직 제공 (유저 + 연차 정책 + 연차 잔여)
@riverpod
GetUserMeUseCase getUserMeUseCase(Ref ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUserMeUseCase(repository);
}
