import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design_system.dart';

class Step4WorkerCount extends StatefulWidget {
  final void Function(bool) onValidChanged;
  final void Function(int)? onDataChanged;

  const Step4WorkerCount({
    super.key,
    required this.onValidChanged,
    this.onDataChanged,
  });

  @override
  State<Step4WorkerCount> createState() => _Step4WorkerCountState();
}

class _Step4WorkerCountState extends State<Step4WorkerCount>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _controller = TextEditingController();

  int? get _count => int.tryParse(_controller.text);

  bool get _isValid {
    final c = _count;
    return c != null && c >= 5;
  }

  void _notify() {
    widget.onValidChanged(_isValid);
    if (_isValid) widget.onDataChanged?.call(_count!);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 5인 미만(단, 0 제외)일 때만 에러 메시지
  bool get _hasError {
    final c = _count;
    return c != null && c > 0 && c < 5;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 45),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '상시 근로자 수를 입력해주세요',
              textAlign: TextAlign.center,
              style: pretendard(
                weight: 600,
                size: 23,
                color: AppColors.brandColor,
              ),
            ),
          ),
          const SizedBox(height: 44),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildInputCard(),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildInfoCard(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
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
            '상시근로자 수',
            style: pretendard(
              weight: 600,
              size: 20,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 7),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: pretendard(
              weight: 600,
              size: 11,
              color: _hasError
                  ? const Color(0xFFFF7B7B)
                  : AppColors.textGray99,
            ),
            child: Text(
              _hasError
                  ? '연차유급휴가 발생 대상이 아닙니다'
                  : '하단의 안내문을 확인하세요.',
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
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) {
                  setState(() {});
                  _notify();
                },
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFCFE6FF),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안내 사항',
            style: pretendard(
              weight: 600,
              size: 20,
              color: const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '아래 조건에 해당할 경우 연차유급휴가가 발생하지 않습니다.',
            style: pretendard(
              weight: 600,
              size: 11,
              color: AppColors.brandColor,
            ),
          ),
          const SizedBox(height: 4),
          const Divider(color: AppColors.brandColor, height: 1, thickness: 1),
          const SizedBox(height: 13),
          Text(
            '· 상시근로자 수가 5명 미만인 경우',
            style: pretendard(
              weight: 600,
              size: 12,
              color: const Color(0xFF111111),
            ).copyWith(letterSpacing: -0.36),
          ),
          const SizedBox(height: 7),
          Text(
            '· 1주간 근무시간 평균이 15시간 이하인 경우',
            style: pretendard(
              weight: 600,
              size: 12,
              color: const Color(0xFF111111),
            ).copyWith(letterSpacing: -0.36),
          ),
        ],
      ),
    );
  }
}
