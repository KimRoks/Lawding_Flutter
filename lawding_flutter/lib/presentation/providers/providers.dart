import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/annual_leave_calculator/calculator_repository_impl.dart';
import '../../data/app_version/app_version_repository_impl.dart';
import '../../data/dictionary/dictionary_repository_impl.dart';
import '../../data/feedback/feedback_repository_impl.dart';
import '../../data/network/dio_client.dart';
import '../../domain/repositories/annual_leave_repository.dart';
import '../../domain/repositories/app_version_repository.dart';
import '../../domain/repositories/dictionary_repository.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../../domain/usecases/calculate_annual_leave_usecase.dart';
import '../../domain/usecases/get_dictionaries_usecase.dart';
import '../../domain/usecases/search_dictionary_usecase.dart';
import '../../domain/usecases/submit_feedback_usecase.dart';

part 'providers.g.dart';

// ============================================================================
// Infrastructure Layer (Network)
// ============================================================================

/// DioClient Provider
/// 네트워크 통신을 위한 DioClient 인스턴스 제공
@riverpod
DioClient dioClient(Ref ref) {
  final baseUrl = dotenv.env['BASE_URL'] ?? 'https://api.default.com';
  return DioClient(baseUrl: baseUrl);
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
