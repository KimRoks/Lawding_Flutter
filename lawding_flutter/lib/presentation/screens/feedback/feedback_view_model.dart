import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/network/network_error.dart';
import '../../../domain/core/result.dart';
import '../../../domain/entities/feedback.dart';
import '../../../infrastructure/services/analytics_service.dart';
import '../../providers/providers.dart';

part 'feedback_view_model.g.dart';

@riverpod
class FeedbackViewModel extends _$FeedbackViewModel {
  final _analytics = AnalyticsService();

  @override
  FeedbackState build() {
    return FeedbackState();
  }

  void setFeedbackType(int index) {
    final category = switch (index) {
      0 => FeedbackCategory.errorReport,
      1 => FeedbackCategory.question,
      2 => FeedbackCategory.improvement,
      3 => FeedbackCategory.other,
      _ => FeedbackCategory.other,
    };
    state = state.copyWith(category: category);
  }

  void setContent(String content) {
    state = state.copyWith(content: content);
  }

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  void setIncludeCalculationData(bool include) {
    state = state.copyWith(includeCalculationData: include);
  }

  void setCalculationId(String? calculationId) {
    state = state.copyWith(calculationId: calculationId);
  }

  /// 피드백 제출 검증
  String? validateFeedback() {
    if (state.content.length < 5) {
      return '내용을 최소 5자 이상 입력해주세요.';
    }

    if (state.email.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(state.email)) {
      return '올바른 이메일 형식을 입력해주세요.';
    }

    return null;
  }

  /// 피드백 제출
  Future<void> submitFeedback() async {
    // Analytics: 피드백 제출 시작 이벤트
    final feedbackTypeString = _getFeedbackTypeString(state.category);
    await _analytics.logFeedbackSubmitStarted(
      feedbackType: feedbackTypeString,
      includeCalculationData: state.includeCalculationData,
    );

    state = state.copyWith(isLoading: true, error: null);

    final useCase = ref.read(submitFeedbackUseCaseProvider);

    final feedback = Feedback(
      category: state.category,
      content: state.content,
      email: state.email,
      calculationId: state.includeCalculationData ? state.calculationId : null,
    );

    final result = await useCase.execute(feedback);

    result.fold(
      onSuccess: (_) {
        state = state.copyWith(isLoading: false, isSubmitted: true);

        // Analytics: 피드백 제출 성공 이벤트
        _analytics.logFeedbackSubmitted(
          feedbackType: feedbackTypeString,
          includeCalculationData: state.includeCalculationData,
        );
      },
      onFailure: (error) {
        final errorMessage = switch (error) {
          ServerError(message: final msg) => msg,
          TimeoutError() => '요청 시간이 초과되었습니다.',
          NetworkConnectionError() => '네트워크 연결을 확인해주세요.',
          UnauthorizedError() => '인증에 실패했습니다.',
          _ => '피드백 전송에 실패했습니다.',
        };
        state = state.copyWith(isLoading: false, error: errorMessage);

        // Analytics: 피드백 제출 실패 이벤트
        _analytics.logFeedbackSubmitFailed(
          feedbackType: feedbackTypeString,
          errorMessage: errorMessage,
        );
      },
    );
  }

  String _getFeedbackTypeString(FeedbackCategory category) {
    return switch (category) {
      FeedbackCategory.errorReport => 'error_report',
      FeedbackCategory.question => 'question',
      FeedbackCategory.improvement => 'improvement',
      FeedbackCategory.satisfaction => 'satisfaction',
      FeedbackCategory.other => 'other',
    };
  }
}

/// FeedbackScreen의 상태
class FeedbackState {
  final FeedbackCategory category;
  final String content;
  final String email;
  final bool includeCalculationData;
  final String? calculationId;
  final bool isLoading;
  final bool isSubmitted;
  final String? error;

  FeedbackState({
    this.category = FeedbackCategory.errorReport,
    this.content = '',
    this.email = '',
    this.includeCalculationData = false,
    this.calculationId,
    this.isLoading = false,
    this.isSubmitted = false,
    this.error,
  });

  FeedbackState copyWith({
    FeedbackCategory? category,
    String? content,
    String? email,
    bool? includeCalculationData,
    String? calculationId,
    bool? isLoading,
    bool? isSubmitted,
    String? error,
  }) {
    return FeedbackState(
      category: category ?? this.category,
      content: content ?? this.content,
      email: email ?? this.email,
      includeCalculationData:
          includeCalculationData ?? this.includeCalculationData,
      calculationId: calculationId ?? this.calculationId,
      isLoading: isLoading ?? this.isLoading,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      error: error,
    );
  }
}
