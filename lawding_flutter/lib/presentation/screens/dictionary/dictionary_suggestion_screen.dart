import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system.dart';
import '../../widgets/common/card_container.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_scaffold.dart';
import '../../widgets/common/submit_button.dart';
import 'dictionary_suggestion_view_model.dart';

class DictionarySuggestionScreen extends ConsumerStatefulWidget {
  const DictionarySuggestionScreen({super.key});

  @override
  ConsumerState<DictionarySuggestionScreen> createState() =>
      _DictionarySuggestionScreenState();
}

class _DictionarySuggestionScreenState
    extends ConsumerState<DictionarySuggestionScreen> {
  final _contentController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final viewModel = ref.read(dictionarySuggestionViewModelProvider.notifier);

    final error = viewModel.validate();
    if (error != null) {
      UiHelpers.showSnackBar(context, error);
      return;
    }

    await viewModel.submit();

    if (!mounted) return;

    final state = ref.read(dictionarySuggestionViewModelProvider);
    if (state.isSubmitted) {
      UiHelpers.showToast(context, '소중한 의견 감사합니다.');
      Navigator.pop(context);
    } else if (state.error != null) {
      UiHelpers.showError(context, state.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dictionarySuggestionViewModelProvider);

    return CustomScaffold(
      appBar: const CustomAppBar(title: '건의하기'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '내용',
                      style: pretendard(
                        weight: 700,
                        size: 20,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _contentController,
                        onChanged: (value) => ref
                            .read(
                              dictionarySuggestionViewModelProvider.notifier,
                            )
                            .setContent(value),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: pretendard(
                          weight: 500,
                          size: 15,
                          color: AppColors.primaryTextColor,
                        ),
                        decoration: InputDecoration(
                          hintText: '연차 관련 궁금한 사항을 적어주세요.(최소 5자)',
                          hintStyle: pretendard(
                            weight: 400,
                            size: 14,
                            color: AppColors.textGray99,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '이메일',
                      style: pretendard(
                        weight: 700,
                        size: 20,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      height: 35,
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _emailController,
                          onChanged: (value) => ref
                              .read(
                                dictionarySuggestionViewModelProvider.notifier,
                              )
                              .setEmail(value),
                          keyboardType: TextInputType.emailAddress,
                          textAlignVertical: TextAlignVertical.center,
                          style: pretendard(
                            weight: 400,
                            size: 14,
                            color: AppColors.primaryTextColor,
                          ),
                          decoration: InputDecoration(
                            hintText: '예) example@email.com',
                            hintStyle: pretendard(
                              weight: 400,
                              size: 14,
                              color: AppColors.textGray99,
                            ),
                            isCollapsed: true,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              SubmitButton(
                text: '보내기',
                isLoading: state.isLoading,
                onPressed: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
