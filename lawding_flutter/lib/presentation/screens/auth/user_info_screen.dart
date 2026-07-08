import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design_system.dart';

class UserInfoScreen extends StatefulWidget {
  final VoidCallback onNext;

  const UserInfoScreen({super.key, required this.onNext});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();
  bool _allAgreed = false;
  bool _term1Agreed = false;
  bool _term2Agreed = false;

  bool get _canProceed =>
      _nameController.text.trim().isNotEmpty && _term1Agreed && _term2Agreed;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _toggleAll(bool value) {
    setState(() {
      _allAgreed = value;
      _term1Agreed = value;
      _term2Agreed = value;
    });
  }

  void _updateTerm(int index, bool value) {
    setState(() {
      if (index == 0) {
        _term1Agreed = value;
      } else {
        _term2Agreed = value;
      }
      _allAgreed = _term1Agreed && _term2Agreed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildProgressBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // top: 112, progress ends at 67 → gap 45
                      const SizedBox(height: 45),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          '이름을 설정하고 약관에 동의해주세요',
                          textAlign: TextAlign.center,
                          style: pretendard(
                            weight: 600,
                            size: 23,
                            color: AppColors.brandColor,
                          ),
                        ),
                      ),
                      // subtitle bottom ~139, name card top 183 → gap 44
                      const SizedBox(height: 44),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildNameCard(),
                      ),
                      // name card bottom 306, terms top 324 → gap 18
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildTermsCard(),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: _buildNextButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 63,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true).pop(),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Icon(
                    Icons.chevron_left,
                    size: 24,
                    color: AppColors.brandColor,
                  ),
                  Text(
                    '뒤로',
                    style: pretendard(
                      weight: 700,
                      size: 20,
                      color: AppColors.brandColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            '기본 정보 입력',
            style: pretendard(
              weight: 700,
              size: 20,
              color: AppColors.brandColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    // 6개 세그먼트, 각 29.42px, 간격 5.15px, 총 203px
    const segmentWidth = 29.42;
    const segmentGap = 5.15;
    const totalWidth = 6 * segmentWidth + 5 * segmentGap; // ≈ 203px

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Center(
        child: SizedBox(
          width: totalWidth,
          height: 4,
          child: Row(
            children: List.generate(6, (i) {
              return Padding(
                padding: EdgeInsets.only(right: i < 5 ? segmentGap : 0),
                child: Container(
                  width: segmentWidth,
                  height: 4,
                  decoration: BoxDecoration(
                    color: i == 0
                        ? AppColors.brandColor
                        : const Color(0xFFE1E1E1),
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
              );
            }),
          ),
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
                color: _nameFocus.hasFocus
                    ? AppColors.brandColor
                    : AppColors.border,
                width: _nameFocus.hasFocus ? 1.5 : 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
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

  Widget _buildTermsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            'LawDing 이용을 위한 약관 동의가 필요해요.',
            style: pretendard(
              weight: 600,
              size: 20,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 18),
          // 전체 약관 동의
          GestureDetector(
            onTap: () => _toggleAll(!_allAgreed),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 47,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _allAgreed ? AppColors.brandColor : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _CircleCheckbox(checked: _allAgreed),
                  const SizedBox(width: 10),
                  Text(
                    '전체 약관 동의',
                    style: pretendard(
                      weight: 500,
                      size: 16,
                      color: const Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _TermRow(
            label: '(필수) 이용 약관 동의',
            checked: _term1Agreed,
            onToggle: () => _updateTerm(0, !_term1Agreed),
            onDetail: () {}, // TODO: 약관 상세 연결
          ),
          const SizedBox(height: 19),
          _TermRow(
            label: '(필수) 이용 약관 및 개인정보취급방침',
            checked: _term2Agreed,
            onToggle: () => _updateTerm(1, !_term2Agreed),
            onDetail: () {}, // TODO: 개인정보취급방침 상세 연결
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final enabled = _canProceed;
    return GestureDetector(
      onTap: enabled ? widget.onNext : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 48,
        decoration: BoxDecoration(
          color: enabled ? AppColors.brandColor : const Color(0xFFBEC1C8),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          style: pretendard(
            weight: 700,
            size: 15,
            color: Colors.white.withValues(alpha: enabled ? 1.0 : 0.7),
          ),
          child: const Text('다음'),
        ),
      ),
    );
  }
}

// ============================================================================
// Sub-widgets
// ============================================================================

class _CircleCheckbox extends StatelessWidget {
  final bool checked;

  const _CircleCheckbox({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? AppColors.brandColor : const Color(0xFFE1E1E1),
      ),
      child: const Icon(Icons.check, size: 11, color: Colors.white),
    );
  }
}

class _TermRow extends StatelessWidget {
  final String label;
  final bool checked;
  final VoidCallback onToggle;
  final VoidCallback onDetail;

  const _TermRow({
    required this.label,
    required this.checked,
    required this.onToggle,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: checked ? AppColors.brandColor : const Color(0xFFE3E3E3),
            ),
            child: const Icon(Icons.check, size: 10, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onToggle,
            child: Text(
              label,
              style: pretendard(
                weight: 400,
                size: 12,
                color: AppColors.textGray99,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: onDetail,
          child: Text(
            '자세히 보기',
            style: pretendard(
              weight: 400,
              size: 14,
              color: AppColors.textGray99,
            ).copyWith(decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}
