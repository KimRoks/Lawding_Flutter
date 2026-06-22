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
String _$dioClientHash() => r'4b1ec2385cfda68a1e5fde15a563220bce171cd3';

/// DioClient Provider
/// 네트워크 통신을 위한 DioClient 인스턴스 제공
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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
