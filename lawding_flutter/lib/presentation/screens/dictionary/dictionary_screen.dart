import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/dictionary.dart';
import '../../../infrastructure/services/analytics_service.dart';
import '../../../infrastructure/services/crashlytics_service.dart';
import '../../core/design_system.dart';
import '../../widgets/common/custom_scaffold.dart';
import 'dictionary_guide_dialog.dart';
import 'dictionary_view_model.dart';

/// 탭 활성화 감지를 위한 mixin
mixin TabActivationMixin {
  void onTabActivated();
}

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen>
    with TabActivationMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _categoryScrollController = ScrollController();
  final _analytics = AnalyticsService();
  final _crashlytics = CrashlyticsService();

  // 개발 모드: true로 설정하면 매번 안내 다이얼로그가 표시됩니다
  static const bool _showGuideAlways = false;

  // 최초 접근 체크 완료 여부
  bool _hasCheckedFirstAccess = false;

  @override
  void initState() {
    super.initState();
    _categoryScrollController.addListener(_onCategoryScroll);

    // 데이터 로딩
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(dictionaryViewModelProvider.notifier);
      viewModel.loadDictionaries();
    });
  }

  /// 탭이 활성화되었을 때 호출되는 메서드 (외부에서 호출 가능)
  @override
  void onTabActivated() {
    _checkAndShowGuide();
    _trackScreenView();
  }

  void _trackScreenView() {
    _analytics.logDictionaryScreenViewed();
    _crashlytics.setScreenContext('DictionaryScreen');
  }

  void _checkAndShowGuide() {
    if (_hasCheckedFirstAccess) return;
    _hasCheckedFirstAccess = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final viewModel = ref.read(dictionaryViewModelProvider.notifier);
      final isFirst = _showGuideAlways || await viewModel.isFirstAccess();

      if (isFirst && mounted) {
        await _showGuideDialog();
        if (!_showGuideAlways) {
          await viewModel.markGuideAsShown();
        }
      }
    });
  }

  Future<void> _showGuideDialog() async {
    // 안내 다이얼로그 표시 이벤트 기록
    await _analytics.logDictionaryGuideShown();

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DictionaryGuideDialog(),
    );

    // 안내 다이얼로그 닫기 이벤트 기록
    await _analytics.logDictionaryGuideDismissed();
  }

  @override
  void dispose() {
    _categoryScrollController.removeListener(_onCategoryScroll);
    _categoryScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryScroll() {
    if (!_categoryScrollController.hasClients) return;

    final maxScroll = _categoryScrollController.position.maxScrollExtent;
    final currentScroll = _categoryScrollController.position.pixels;

    ref
        .read(dictionaryViewModelProvider.notifier)
        .updateScrollFadeState(currentScroll > 0, currentScroll < maxScroll);
  }

  void _onBottomButtonPressed() {
    // TODO: 화면 push 구현
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('문의하기 화면으로 이동')));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dictionaryViewModelProvider);

    return CustomScaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBox(state),
              _buildCategoryChips(state),
              Expanded(child: _buildBody(state)),
              // TODO: 하단 버튼 임시로 숨김 기존 높이 80 및 buildBottomButton() 주석 처리
              const SizedBox(height: 0),
            ],
          ),
          // _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildSearchBox(DictionaryState state) {
    final commonBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(500),
      borderSide: BorderSide.none,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          ref.read(dictionaryViewModelProvider.notifier).onSearchChanged(query);

          // 검색 이벤트 기록
          if (query.isNotEmpty) {
            final state = ref.read(dictionaryViewModelProvider);
            _analytics.logDictionarySearchPerformed(
              query: query,
              resultCount: state.filteredDictionaries.length,
            );
          }
        },
        style: pretendard(weight: 600, size: 14, color: AppColors.textGray11),
        decoration: InputDecoration(
          hintText: '궁금한 연차 정보를 검색해보세요.',
          hintStyle: pretendard(
            weight: 600,
            size: 14,
            color: AppColors.textGray99,
          ),
          filled: true,
          fillColor: const Color(0xFFF6F6F6),
          contentPadding: const EdgeInsets.only(
            left: 10,
            top: 12,
            bottom: 12,
            right: 16,
          ),
          border: commonBorder,
          enabledBorder: commonBorder,
          focusedBorder: commonBorder,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 48,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 0),
            child: Image.asset(
              'assets/icons/magnifying.png',
              width: 18,
              height: 18,
              color: state.searchQuery.isEmpty
                  ? AppColors.iconInactive
                  : AppColors.brandColor,
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 48,
          ),
          suffixIcon: state.searchQuery.isEmpty
              ? null
              : GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    ref
                        .read(dictionaryViewModelProvider.notifier)
                        .onSearchChanged('');

                    // 검색 초기화 이벤트 기록
                    _analytics.logDictionarySearchCleared();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Image.asset(
                      'assets/icons/delete.png',
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(DictionaryState state) {
    if (state.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 52,
      child: Stack(
        children: [
          ListView.builder(
            controller: _categoryScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: state.categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCategoryChip(state, null, '전체');
              }
              final category = state.categories[index - 1];
              return _buildCategoryChip(state, category.id, category.name);
            },
          ),
          if (state.showLeftFade)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.background,
                        AppColors.background.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (state.showRightFade)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.background.withValues(alpha: 0),
                        AppColors.background,
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    DictionaryState state,
    int? categoryId,
    String label,
  ) {
    final isSelected = state.selectedCategoryId == categoryId;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) {
            ref
                .read(dictionaryViewModelProvider.notifier)
                .filterByCategory(categoryId);

            // 카테고리 선택 이벤트 기록
            final updatedState = ref.read(dictionaryViewModelProvider);
            _analytics.logDictionaryCategorySelected(
              categoryName: label,
              resultCount: updatedState.filteredDictionaries.length,
            );
          },
          showCheckmark: false,
          backgroundColor: AppColors.backgroundChip,
          selectedColor: AppColors.brandColor,
          labelStyle: pretendard(
            weight: 600,
            size: 14,
            color: isSelected ? Colors.white : AppColors.textGray99,
          ),
          side: const BorderSide(color: Colors.transparent, width: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          pressElevation: 0,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        ),
      ),
    );
  }

  Widget _buildBody(DictionaryState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandColor),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.errorMessage!,
              style: const TextStyle(color: AppColors.textGray99),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 재시도 이벤트 기록
                _analytics.logDictionaryRetryPressed();

                ref
                    .read(dictionaryViewModelProvider.notifier)
                    .loadDictionaries();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandColor,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.filteredDictionaries.isEmpty) {
      return const Center(
        child: Text(
          '검색 결과가 없습니다.',
          style: TextStyle(color: AppColors.textGray99, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: state.filteredDictionaries.length,
      itemBuilder: (context, index) {
        final dictionary = state.filteredDictionaries[index];
        final isExpanded = state.expandedIds.contains(dictionary.id);
        return _buildDictionaryItem(dictionary, isExpanded);
      },
    );
  }

  Widget _buildDictionaryItem(Dictionary dictionary, bool isExpanded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          final willBeExpanded = !isExpanded;

          ref
              .read(dictionaryViewModelProvider.notifier)
              .toggleExpanded(dictionary.id);

          // 펼치기/접기 이벤트 기록
          if (willBeExpanded) {
            _analytics.logDictionaryItemExpanded(
              dictionaryId: dictionary.id,
              question: dictionary.question,
              category: dictionary.category.name,
            );
          } else {
            _analytics.logDictionaryItemCollapsed(dictionary.id);
          }
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(
                left: 20,
                top: 20,
                right: 15,
                bottom: isExpanded ? 12 : 20,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dictionary.category.name,
                          style: pretendard(
                            weight: 600,
                            size: 14,
                            color: AppColors.brandColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          dictionary.question,
                          style: pretendard(
                            weight: 600,
                            size: 16,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textGray99,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.fastOutSlowIn,
              child: isExpanded
                  ? Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        top: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundChip,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Divider(color: AppColors.divider, height: 1),
                          const SizedBox(height: 12),
                          AnimatedOpacity(
                            opacity: isExpanded ? 1.0 : 0.0,
                            duration: Duration(
                              milliseconds: isExpanded ? 250 : 150,
                            ),
                            curve: isExpanded ? Curves.easeIn : Curves.easeOut,
                            child: Text(
                              dictionary.content,
                              style: pretendard(
                                weight: 500,
                                size: 14,
                                color: AppColors.textGray55,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: InkWell(
            onTap: _onBottomButtonPressed,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      color: AppColors.brandLight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: Image.asset(
                              'assets/icons/questionmark.png',
                              color: AppColors.brandColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '연차 관련 궁금한 사항이 있나요?',
                                  style: pretendard(
                                    weight: 600,
                                    size: 14,
                                    color: AppColors.brandColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '연차에 대해 궁금하신 점을 질문해주세요.\n노무사가 직접 답변해드립니다.',
                                  style: pretendard(
                                    weight: 400,
                                    size: 12,
                                    color: AppColors.primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 72,
                    color: AppColors.brandColor,
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
