import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/core/result.dart';
import '../../core/design_system.dart';
import '../../providers/providers.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/submit_button.dart';
import '../../widgets/common/toast_message.dart';

class ChangeNicknameScreen extends ConsumerStatefulWidget {
  const ChangeNicknameScreen({super.key});

  @override
  ConsumerState<ChangeNicknameScreen> createState() =>
      _ChangeNicknameScreenState();
}

class _ChangeNicknameScreenState extends ConsumerState<ChangeNicknameScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nickname = _controller.text.trim();
    setState(() => _isLoading = true);
    final result = await ref
        .read(updateProfileUseCaseProvider)
        .execute(nickname: nickname);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result case Failure()) {
      ToastManager().show(context, '닉네임 변경 중 오류가 발생했습니다. 다시 시도해주세요.');
      return;
    }
    ToastManager().show(context, '닉네임이 변경되었습니다');
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: const CustomAppBar(
        title: '닉네임 변경',
        backgroundColor: Color(0xFFFBFBFB),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 44),
            _buildNameCard(),
            const Spacer(),
            SubmitButton(
              text: '확인',
              onPressed: _canSubmit ? _submit : null,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNameCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '표시될 이름 설정',
            style: pretendard(
              weight: 600,
              size: 20,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '최대 6자 입력 가능',
            style: pretendard(
              weight: 600,
              size: 11,
              color: AppColors.textGray99,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? AppColors.brandColor
                    : AppColors.border,
                width: _focusNode.hasFocus ? 1.5 : 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLength: 6,
                  onChanged: (_) => setState(() {}),
                  inputFormatters: [LengthLimitingTextInputFormatter(6)],
                  style: pretendard(
                    weight: 500,
                    size: 15,
                    color: const Color(0xFF555555),
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
