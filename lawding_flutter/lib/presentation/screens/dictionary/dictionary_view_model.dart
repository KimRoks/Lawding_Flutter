import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/network/network_error.dart';
import '../../../domain/core/result.dart';
import '../../../domain/entities/dictionary.dart';
import '../../providers/providers.dart';

part 'dictionary_view_model.g.dart';

@riverpod
class DictionaryViewModel extends _$DictionaryViewModel {
  @override
  DictionaryState build() {
    return DictionaryState();
  }

  Future<void> loadDictionaries() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(getDictionariesUseCaseProvider);
    final result = await useCase.execute();

    switch (result) {
      case Success(:final value):
        final allCategories = <DictionaryCategory>[];
        final seenCategoryIds = <int>{};

        for (final dict in value.items) {
          if (!seenCategoryIds.contains(dict.category.id)) {
            seenCategoryIds.add(dict.category.id);
            allCategories.add(dict.category);
          }
        }

        state = state.copyWith(
          allDictionaries: value.items,
          filteredDictionaries: value.items,
          categories: allCategories,
          isLoading: false,
        );

      case Failure(:final error):
        final errorMessage = switch (error) {
          ServerError(message: final msg) => msg,
          TimeoutError() => '요청 시간이 초과되었습니다.',
          NetworkConnectionError() => '네트워크 연결을 확인해주세요.',
          UnauthorizedError() => '인증에 실패했습니다.',
          _ => '용어 사전을 불러오는데 실패했습니다.',
        };
        state = state.copyWith(errorMessage: errorMessage, isLoading: false);
    }
  }

  void filterByCategory(int? categoryId) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      filteredDictionaries: _applyFilters(categoryId, state.searchQuery),
    );
  }

  void onSearchChanged(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredDictionaries: _applyFilters(state.selectedCategoryId, query),
    );
  }

  /// 카테고리와 검색어로 필터링된 목록 반환
  List<Dictionary> _applyFilters(int? categoryId, String query) {
    final lowerQuery = query.toLowerCase();

    return state.allDictionaries.where((dict) {
      // 카테고리 필터 체크
      final matchesCategory =
          categoryId == null || dict.category.id == categoryId;

      // 검색어 필터 체크
      final matchesSearch =
          query.isEmpty || dict.question.toLowerCase().contains(lowerQuery);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void toggleExpanded(int id) {
    final expandedIds = Set<int>.from(state.expandedIds);
    if (expandedIds.contains(id)) {
      expandedIds.remove(id);
    } else {
      expandedIds.add(id);
    }
    state = state.copyWith(expandedIds: expandedIds);
  }

  void updateScrollFadeState(bool showLeft, bool showRight) {
    state = state.copyWith(showLeftFade: showLeft, showRightFade: showRight);
  }

  /// 최초 접근 여부 확인
  Future<bool> isFirstAccess() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey('dictionary_guide_shown');
  }

  /// 안내 다이얼로그 표시 완료 표시
  Future<void> markGuideAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dictionary_guide_shown', true);
  }

  /// 안내 다이얼로그 표시 기록 초기화 (테스트용)
  Future<void> resetGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('dictionary_guide_shown');
  }
}

class DictionaryState {
  final List<Dictionary> allDictionaries;
  final List<Dictionary> filteredDictionaries;
  final List<DictionaryCategory> categories;
  final int? selectedCategoryId;
  final Set<int> expandedIds;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final bool showLeftFade;
  final bool showRightFade;

  DictionaryState({
    List<Dictionary>? allDictionaries,
    List<Dictionary>? filteredDictionaries,
    List<DictionaryCategory>? categories,
    this.selectedCategoryId,
    Set<int>? expandedIds,
    this.searchQuery = '',
    this.isLoading = true,
    this.errorMessage,
    this.showLeftFade = false,
    this.showRightFade = true,
  }) : allDictionaries = allDictionaries ?? [],
       filteredDictionaries = filteredDictionaries ?? [],
       categories = categories ?? [],
       expandedIds = expandedIds ?? {};

  DictionaryState copyWith({
    List<Dictionary>? allDictionaries,
    List<Dictionary>? filteredDictionaries,
    List<DictionaryCategory>? categories,
    int? selectedCategoryId,
    Set<int>? expandedIds,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    bool? showLeftFade,
    bool? showRightFade,
  }) {
    return DictionaryState(
      allDictionaries: allDictionaries ?? this.allDictionaries,
      filteredDictionaries: filteredDictionaries ?? this.filteredDictionaries,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      expandedIds: expandedIds ?? this.expandedIds,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      showLeftFade: showLeftFade ?? this.showLeftFade,
      showRightFade: showRightFade ?? this.showRightFade,
    );
  }
}
