// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRepositoryHash() => r'a8767550d220ede9bb05149c073a651c4422d5ef';

/// AuthRepository Provider
/// 토큰 저장/조회/삭제 Repository 구현체 제공
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$dioClientHash() => r'1e01a172917b0cd3222effb0bdb534bf02f7346b';

/// DioClient Provider — 공개 API용 (토큰 없음)
///
/// Copied from [dioClient].
@ProviderFor(dioClient)
final dioClientProvider = AutoDisposeProvider<DioClient>.internal(
  dioClient,
  name: r'dioClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dioClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DioClientRef = AutoDisposeProviderRef<DioClient>;
String _$authDioClientHash() => r'851e368a34fe3ee44899b2f53260115ef746d2d9';

/// Auth DioClient Provider — 로그인 필요 API용 (Bearer 토큰 주입 + 401 재시도)
///
/// Copied from [authDioClient].
@ProviderFor(authDioClient)
final authDioClientProvider = AutoDisposeProvider<DioClient>.internal(
  authDioClient,
  name: r'authDioClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authDioClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthDioClientRef = AutoDisposeProviderRef<DioClient>;
String _$baseUrlHash() => r'0678def68d5409a9a974f607bf2eccb6659a8530';

/// baseUrl Provider
/// .env의 BASE_URL 제공
///
/// Copied from [baseUrl].
@ProviderFor(baseUrl)
final baseUrlProvider = AutoDisposeProvider<String>.internal(
  baseUrl,
  name: r'baseUrlProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$baseUrlHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BaseUrlRef = AutoDisposeProviderRef<String>;
String _$annualLeaveRepositoryHash() =>
    r'c853c76be9de247327bf0af1ca1dd380621e29f3';

/// AnnualLeaveRepository Provider
/// 연차 계산 Repository 구현체 제공
///
/// Copied from [annualLeaveRepository].
@ProviderFor(annualLeaveRepository)
final annualLeaveRepositoryProvider =
    AutoDisposeProvider<AnnualLeaveRepository>.internal(
      annualLeaveRepository,
      name: r'annualLeaveRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$annualLeaveRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnnualLeaveRepositoryRef =
    AutoDisposeProviderRef<AnnualLeaveRepository>;
String _$feedbackRepositoryHash() =>
    r'c53d8b8e5f76b60c08b097ff839517bded365a4f';

/// FeedbackRepository Provider
/// 피드백 제출 Repository 구현체 제공
///
/// Copied from [feedbackRepository].
@ProviderFor(feedbackRepository)
final feedbackRepositoryProvider =
    AutoDisposeProvider<FeedbackRepository>.internal(
      feedbackRepository,
      name: r'feedbackRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$feedbackRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedbackRepositoryRef = AutoDisposeProviderRef<FeedbackRepository>;
String _$appVersionRepositoryHash() =>
    r'ff55389fd953efcfa345ff83294c3c2b7b90baea';

/// AppVersionRepository Provider
/// 앱 버전 체크 Repository 구현체 제공
///
/// Copied from [appVersionRepository].
@ProviderFor(appVersionRepository)
final appVersionRepositoryProvider =
    AutoDisposeProvider<AppVersionRepository>.internal(
      appVersionRepository,
      name: r'appVersionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appVersionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppVersionRepositoryRef = AutoDisposeProviderRef<AppVersionRepository>;
String _$holidayRepositoryHash() => r'e55d4225fd66e85a283983b2b0d3383e14185715';

/// HolidayRepository Provider
/// 공휴일 목록 조회 Repository 구현체 제공
///
/// Copied from [holidayRepository].
@ProviderFor(holidayRepository)
final holidayRepositoryProvider =
    AutoDisposeProvider<HolidayRepository>.internal(
      holidayRepository,
      name: r'holidayRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$holidayRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HolidayRepositoryRef = AutoDisposeProviderRef<HolidayRepository>;
String _$getHolidaysUseCaseHash() =>
    r'6626d0fe577e286e8067131d6645ad71edecdbfb';

/// GetHolidaysUseCase Provider
/// 공휴일 목록 조회 비즈니스 로직 제공
///
/// Copied from [getHolidaysUseCase].
@ProviderFor(getHolidaysUseCase)
final getHolidaysUseCaseProvider =
    AutoDisposeProvider<GetHolidaysUseCase>.internal(
      getHolidaysUseCase,
      name: r'getHolidaysUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getHolidaysUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetHolidaysUseCaseRef = AutoDisposeProviderRef<GetHolidaysUseCase>;
String _$calendarEventRepositoryHash() =>
    r'55fa27aa34832343edd28e4aae92f1446aa00384';

/// CalendarEventRepository Provider
/// 캘린더 이벤트 조회 Repository 구현체 제공 (로그인 필요)
///
/// Copied from [calendarEventRepository].
@ProviderFor(calendarEventRepository)
final calendarEventRepositoryProvider =
    AutoDisposeProvider<CalendarEventRepository>.internal(
      calendarEventRepository,
      name: r'calendarEventRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$calendarEventRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalendarEventRepositoryRef =
    AutoDisposeProviderRef<CalendarEventRepository>;
String _$calculateAnnualLeaveUseCaseHash() =>
    r'b8f17d7996bac3a788a250d5a3b68fe30b82be78';

/// CalculateAnnualLeaveUseCase Provider
/// 연차 계산 비즈니스 로직 제공
///
/// Copied from [calculateAnnualLeaveUseCase].
@ProviderFor(calculateAnnualLeaveUseCase)
final calculateAnnualLeaveUseCaseProvider =
    AutoDisposeProvider<CalculateAnnualLeaveUseCase>.internal(
      calculateAnnualLeaveUseCase,
      name: r'calculateAnnualLeaveUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$calculateAnnualLeaveUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalculateAnnualLeaveUseCaseRef =
    AutoDisposeProviderRef<CalculateAnnualLeaveUseCase>;
String _$submitFeedbackUseCaseHash() =>
    r'b26b98a123da817ae8cef5481ac1e53588802608';

/// SubmitFeedbackUseCase Provider
/// 피드백 제출 비즈니스 로직 제공
///
/// Copied from [submitFeedbackUseCase].
@ProviderFor(submitFeedbackUseCase)
final submitFeedbackUseCaseProvider =
    AutoDisposeProvider<SubmitFeedbackUseCase>.internal(
      submitFeedbackUseCase,
      name: r'submitFeedbackUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$submitFeedbackUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubmitFeedbackUseCaseRef =
    AutoDisposeProviderRef<SubmitFeedbackUseCase>;
String _$dictionaryRepositoryHash() =>
    r'65c7b015ebb2095043c46ea655c30107b8ce51f1';

/// DictionaryRepository Provider
/// 용어 사전 Repository 구현체 제공
///
/// Copied from [dictionaryRepository].
@ProviderFor(dictionaryRepository)
final dictionaryRepositoryProvider =
    AutoDisposeProvider<DictionaryRepository>.internal(
      dictionaryRepository,
      name: r'dictionaryRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dictionaryRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DictionaryRepositoryRef = AutoDisposeProviderRef<DictionaryRepository>;
String _$getDictionariesUseCaseHash() =>
    r'39fb7bbbb8daf06bbe48de49201a328006e52b59';

/// GetDictionariesUseCase Provider
/// 전체 용어 사전 목록 조회 비즈니스 로직 제공
///
/// Copied from [getDictionariesUseCase].
@ProviderFor(getDictionariesUseCase)
final getDictionariesUseCaseProvider =
    AutoDisposeProvider<GetDictionariesUseCase>.internal(
      getDictionariesUseCase,
      name: r'getDictionariesUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getDictionariesUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetDictionariesUseCaseRef =
    AutoDisposeProviderRef<GetDictionariesUseCase>;
String _$searchDictionaryUseCaseHash() =>
    r'c56773b49b11a10d2bf4ffcb22bba3b84e235a1b';

/// SearchDictionaryUseCase Provider
/// 용어 사전 검색 비즈니스 로직 제공
///
/// Copied from [searchDictionaryUseCase].
@ProviderFor(searchDictionaryUseCase)
final searchDictionaryUseCaseProvider =
    AutoDisposeProvider<SearchDictionaryUseCase>.internal(
      searchDictionaryUseCase,
      name: r'searchDictionaryUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchDictionaryUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchDictionaryUseCaseRef =
    AutoDisposeProviderRef<SearchDictionaryUseCase>;
String _$userRepositoryHash() => r'279ebf6e1515e36a143ea67c5e60d27741a2f6ef';

/// UserRepository Provider
/// 유저 정보 조회 Repository 구현체 제공 (로그인 필요)
///
/// Copied from [userRepository].
@ProviderFor(userRepository)
final userRepositoryProvider = AutoDisposeProvider<UserRepository>.internal(
  userRepository,
  name: r'userRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRepositoryRef = AutoDisposeProviderRef<UserRepository>;
String _$getUserDashboardUseCaseHash() =>
    r'0c5d89f64057af60266346d67412c9502e798e51';

/// GetUserDashboardUseCase Provider
/// 내 대시보드 정보 조회 비즈니스 로직 제공
///
/// Copied from [getUserDashboardUseCase].
@ProviderFor(getUserDashboardUseCase)
final getUserDashboardUseCaseProvider =
    AutoDisposeProvider<GetUserDashboardUseCase>.internal(
      getUserDashboardUseCase,
      name: r'getUserDashboardUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getUserDashboardUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetUserDashboardUseCaseRef =
    AutoDisposeProviderRef<GetUserDashboardUseCase>;
String _$getLeaveSummaryUseCaseHash() =>
    r'e73f81a55707227e6d1af7b7e4f0f9ba1d3ea74a';

/// GetLeaveSummaryUseCase Provider
/// 남은 연차 요약 조회 비즈니스 로직 제공
///
/// Copied from [getLeaveSummaryUseCase].
@ProviderFor(getLeaveSummaryUseCase)
final getLeaveSummaryUseCaseProvider =
    AutoDisposeProvider<GetLeaveSummaryUseCase>.internal(
      getLeaveSummaryUseCase,
      name: r'getLeaveSummaryUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getLeaveSummaryUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetLeaveSummaryUseCaseRef =
    AutoDisposeProviderRef<GetLeaveSummaryUseCase>;
String _$getCalendarEventsUseCaseHash() =>
    r'6fdcb7d33278ed0ccb6ad6445b336e44947ff433';

/// GetCalendarEventsUseCase Provider
/// 월별 캘린더 이벤트 목록 조회 비즈니스 로직 제공
///
/// Copied from [getCalendarEventsUseCase].
@ProviderFor(getCalendarEventsUseCase)
final getCalendarEventsUseCaseProvider =
    AutoDisposeProvider<GetCalendarEventsUseCase>.internal(
      getCalendarEventsUseCase,
      name: r'getCalendarEventsUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getCalendarEventsUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetCalendarEventsUseCaseRef =
    AutoDisposeProviderRef<GetCalendarEventsUseCase>;
String _$getCalendarEventUseCaseHash() =>
    r'504855cda9a3441172c0d7131d7366603eb7bb7a';

/// GetCalendarEventUseCase Provider
/// 단건 캘린더 이벤트 조회 비즈니스 로직 제공
///
/// Copied from [getCalendarEventUseCase].
@ProviderFor(getCalendarEventUseCase)
final getCalendarEventUseCaseProvider =
    AutoDisposeProvider<GetCalendarEventUseCase>.internal(
      getCalendarEventUseCase,
      name: r'getCalendarEventUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getCalendarEventUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetCalendarEventUseCaseRef =
    AutoDisposeProviderRef<GetCalendarEventUseCase>;
String _$createCalendarEventUseCaseHash() =>
    r'ae607c1f47e531f35c65718ba4da323665ce9e89';

/// CreateCalendarEventUseCase Provider
/// 캘린더 이벤트 생성 비즈니스 로직 제공
///
/// Copied from [createCalendarEventUseCase].
@ProviderFor(createCalendarEventUseCase)
final createCalendarEventUseCaseProvider =
    AutoDisposeProvider<CreateCalendarEventUseCase>.internal(
      createCalendarEventUseCase,
      name: r'createCalendarEventUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createCalendarEventUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateCalendarEventUseCaseRef =
    AutoDisposeProviderRef<CreateCalendarEventUseCase>;
String _$updateCalendarEventUseCaseHash() =>
    r'ae3b35460cc9aac0bc4630213b1a7746fe6486bc';

/// UpdateCalendarEventUseCase Provider
/// 캘린더 이벤트 수정 비즈니스 로직 제공
///
/// Copied from [updateCalendarEventUseCase].
@ProviderFor(updateCalendarEventUseCase)
final updateCalendarEventUseCaseProvider =
    AutoDisposeProvider<UpdateCalendarEventUseCase>.internal(
      updateCalendarEventUseCase,
      name: r'updateCalendarEventUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$updateCalendarEventUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateCalendarEventUseCaseRef =
    AutoDisposeProviderRef<UpdateCalendarEventUseCase>;
String _$deleteCalendarEventUseCaseHash() =>
    r'eec662b33f0e152c201a7ed22d4f3c8511458e37';

/// DeleteCalendarEventUseCase Provider
/// 캘린더 이벤트 삭제 비즈니스 로직 제공
///
/// Copied from [deleteCalendarEventUseCase].
@ProviderFor(deleteCalendarEventUseCase)
final deleteCalendarEventUseCaseProvider =
    AutoDisposeProvider<DeleteCalendarEventUseCase>.internal(
      deleteCalendarEventUseCase,
      name: r'deleteCalendarEventUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteCalendarEventUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteCalendarEventUseCaseRef =
    AutoDisposeProviderRef<DeleteCalendarEventUseCase>;
String _$leavePolicyRepositoryHash() =>
    r'ce22f0a27648bb9119cdeb2e067fa5ad23b08249';

/// LeavePolicyRepository Provider
/// 연차 정책 Repository 구현체 제공 (로그인 필요)
///
/// Copied from [leavePolicyRepository].
@ProviderFor(leavePolicyRepository)
final leavePolicyRepositoryProvider =
    AutoDisposeProvider<LeavePolicyRepository>.internal(
      leavePolicyRepository,
      name: r'leavePolicyRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$leavePolicyRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LeavePolicyRepositoryRef =
    AutoDisposeProviderRef<LeavePolicyRepository>;
String _$submitLeavePolicyUseCaseHash() =>
    r'afe12629b4c0988526db40ba1e7c5cb2eb59c11f';

/// SubmitLeavePolicyUseCase Provider
/// 연차 정책 등록 비즈니스 로직 제공
///
/// Copied from [submitLeavePolicyUseCase].
@ProviderFor(submitLeavePolicyUseCase)
final submitLeavePolicyUseCaseProvider =
    AutoDisposeProvider<SubmitLeavePolicyUseCase>.internal(
      submitLeavePolicyUseCase,
      name: r'submitLeavePolicyUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$submitLeavePolicyUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubmitLeavePolicyUseCaseRef =
    AutoDisposeProviderRef<SubmitLeavePolicyUseCase>;
String _$updateLeavePolicyUseCaseHash() =>
    r'8f455420b74858a946dd415939bbf869972f5e08';

/// UpdateLeavePolicyUseCase Provider
/// 연차 정책 수정 비즈니스 로직 제공
///
/// Copied from [updateLeavePolicyUseCase].
@ProviderFor(updateLeavePolicyUseCase)
final updateLeavePolicyUseCaseProvider =
    AutoDisposeProvider<UpdateLeavePolicyUseCase>.internal(
      updateLeavePolicyUseCase,
      name: r'updateLeavePolicyUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$updateLeavePolicyUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateLeavePolicyUseCaseRef =
    AutoDisposeProviderRef<UpdateLeavePolicyUseCase>;
String _$getLeavePolicyUseCaseHash() =>
    r'679d2676b3bac64e7c110ec4a0c1690e2345386d';

/// GetLeavePolicyUseCase Provider
/// 연차 정책 조회 비즈니스 로직 제공
///
/// Copied from [getLeavePolicyUseCase].
@ProviderFor(getLeavePolicyUseCase)
final getLeavePolicyUseCaseProvider =
    AutoDisposeProvider<GetLeavePolicyUseCase>.internal(
      getLeavePolicyUseCase,
      name: r'getLeavePolicyUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getLeavePolicyUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetLeavePolicyUseCaseRef =
    AutoDisposeProviderRef<GetLeavePolicyUseCase>;
String _$getUserProfileUseCaseHash() =>
    r'e5555ef868f8662f5a68f54f37e12156038623af';

/// GetUserProfileUseCase Provider
/// 유저 프로필 조회 비즈니스 로직 제공
///
/// Copied from [getUserProfileUseCase].
@ProviderFor(getUserProfileUseCase)
final getUserProfileUseCaseProvider =
    AutoDisposeProvider<GetUserProfileUseCase>.internal(
      getUserProfileUseCase,
      name: r'getUserProfileUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getUserProfileUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetUserProfileUseCaseRef =
    AutoDisposeProviderRef<GetUserProfileUseCase>;
String _$leaveDashboardRepositoryHash() =>
    r'7f3589ee3c95e79e19f6f674e94b0e8336e54fc5';

/// LeaveDashboardRepository Provider
/// 연차 대시보드 조회 Repository 구현체 제공 (로그인 필요)
///
/// Copied from [leaveDashboardRepository].
@ProviderFor(leaveDashboardRepository)
final leaveDashboardRepositoryProvider =
    AutoDisposeProvider<LeaveDashboardRepository>.internal(
      leaveDashboardRepository,
      name: r'leaveDashboardRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$leaveDashboardRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LeaveDashboardRepositoryRef =
    AutoDisposeProviderRef<LeaveDashboardRepository>;
String _$getLeaveDashboardUseCaseHash() =>
    r'80629f7eef10dc3331eb8fdea3a5e03bf0cb8709';

/// GetLeaveDashboardUseCase Provider
/// 연차 대시보드 조회 비즈니스 로직 제공
///
/// Copied from [getLeaveDashboardUseCase].
@ProviderFor(getLeaveDashboardUseCase)
final getLeaveDashboardUseCaseProvider =
    AutoDisposeProvider<GetLeaveDashboardUseCase>.internal(
      getLeaveDashboardUseCase,
      name: r'getLeaveDashboardUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getLeaveDashboardUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetLeaveDashboardUseCaseRef =
    AutoDisposeProviderRef<GetLeaveDashboardUseCase>;
String _$updateProfileUseCaseHash() =>
    r'f5f8888e86413364ee3c386db3e5a0aa52f32216';

/// UpdateProfileUseCase Provider
/// 닉네임 수정 비즈니스 로직 제공
///
/// Copied from [updateProfileUseCase].
@ProviderFor(updateProfileUseCase)
final updateProfileUseCaseProvider =
    AutoDisposeProvider<UpdateProfileUseCase>.internal(
      updateProfileUseCase,
      name: r'updateProfileUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$updateProfileUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateProfileUseCaseRef = AutoDisposeProviderRef<UpdateProfileUseCase>;
String _$deleteAccountUseCaseHash() =>
    r'37a78dd0febb734ab3d4057ec3993f4557c034f1';

/// DeleteAccountUseCase Provider
/// 회원 탈퇴 비즈니스 로직 제공
///
/// Copied from [deleteAccountUseCase].
@ProviderFor(deleteAccountUseCase)
final deleteAccountUseCaseProvider =
    AutoDisposeProvider<DeleteAccountUseCase>.internal(
      deleteAccountUseCase,
      name: r'deleteAccountUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteAccountUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteAccountUseCaseRef = AutoDisposeProviderRef<DeleteAccountUseCase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
