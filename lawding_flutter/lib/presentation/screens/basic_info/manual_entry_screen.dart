import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design_system.dart';

class ManualEntryResult {
  final double totalLeave;

  const ManualEntryResult({required this.totalLeave});
}

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _controller = TextEditingController();

  bool get _isValid {
    final v = double.tryParse(_controller.text);
    return v != null && v >= 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (!_isValid) return;
    Navigator.of(
      context,
    ).pop(ManualEntryResult(totalLeave: double.parse(_controller.text)));
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 19),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildTotalLeaveCard(),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: _buildConfirmButton(),
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
              onTap: () => Navigator.of(context).pop(),
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
            '수동 입력',
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

  Widget _buildTotalLeaveCard() {
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
            '연차 발생 개수',
            style: pretendard(
              weight: 600,
              size: 20,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '자신의 연차 개수를 직접 입력하세요',
            style: pretendard(
              weight: 600,
              size: 11,
              color: AppColors.textGray99,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [_DecimalInputFormatter()],
                onChanged: (_) => setState(() {}),
                style: pretendard(
                  weight: 500,
                  size: 15,
                  color: const Color(0xFF555555),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: pretendard(
                    weight: 500,
                    size: 15,
                    color: AppColors.textGray99,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final canProceed = _isValid;
    return GestureDetector(
      onTap: canProceed ? _onConfirm : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 48,
        decoration: BoxDecoration(
          color: canProceed ? AppColors.brandColor : const Color(0xFFBEC1C8),
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
            color: Colors.white.withValues(alpha: canProceed ? 1.0 : 0.7),
          ),
          child: const Text('다음'),
        ),
      ),
    );
  }
}

class _DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    // 소수점 최대 3자리
    if (!RegExp(r'^\d*\.?\d{0,3}$').hasMatch(text)) return oldValue;
    // 정수 부분 50 이하
    final intPart = text.split('.').first;
    if (intPart.isNotEmpty) {
      final intValue = int.tryParse(intPart);
      if (intValue != null && intValue >= 50) return oldValue;
    }
    return newValue;
  }
}
