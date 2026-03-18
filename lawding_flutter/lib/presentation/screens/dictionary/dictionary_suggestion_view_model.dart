import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/network/network_error.dart';
import '../../../domain/core/result.dart';
import '../../../domain/entities/feedback.dart';
import '../../providers/providers.dart';

part 'dictionary_suggestion_view_model.g.dart';

@riverpod
class DictionarySuggestionViewModel extends _$DictionarySuggestionViewModel {
  @override
  DictionarySuggestionState build() {
    return DictionarySuggestionState();
  }

  void setContent(String content) {
    state = state.copyWith(content: content);
  }

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  String? validate() {
    if (state.content.trim().length < 5) {
      return '내용을 최소 5자 이상 입력해주세요.';
    }
    if (state.email.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(state.email)) {
      return '올바른 이메일 형식을 입력해주세요.';
    }
    return null;
  }

  Future<void> submit() async {
    state = state.copyWith(isLoading: true, error: null);

    final useCase = ref.read(submitFeedbackUseCaseProvider);

    final feedback = Feedback(
      category: FeedbackCategory.question,
      content: state.content,
      email: state.email.isEmpty ? null : state.email,
      rating: null,
      calculationId: null,
    );

    final result = await useCase.execute(feedback);

    result.fold(
      onSuccess: (_) {
        state = state.copyWith(isLoading: false, isSubmitted: true);
      },
      onFailure: (error) {
        final message = switch (error) {
          ServerError(message: final msg, statusCode: final code) =>
            'HTTP $code — $msg',
          TimeoutError() => '요청 시간이 초과되었습니다.',
          NetworkConnectionError() => '네트워크 연결을 확인해주세요.',
          UnauthorizedError() => '인증에 실패했습니다.',
          _ => '제출에 실패했습니다.',
        };
        state = state.copyWith(isLoading: false, error: message);
      },
    );
  }
}

class DictionarySuggestionState {
  final String content;
  final String email;
  final bool isLoading;
  final bool isSubmitted;
  final String? error;

  DictionarySuggestionState({
    this.content = '',
    this.email = '',
    this.isLoading = false,
    this.isSubmitted = false,
    this.error,
  });

  DictionarySuggestionState copyWith({
    String? content,
    String? email,
    bool? isLoading,
    bool? isSubmitted,
    String? error,
  }) {
    return DictionarySuggestionState(
      content: content ?? this.content,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      error: error,
    );
  }
}
