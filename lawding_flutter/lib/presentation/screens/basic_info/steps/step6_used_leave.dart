import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design_system.dart';

class Step6UsedLeave extends StatefulWidget {
  final void Function(bool) onValidChanged;
  final void Function(double)? onDataChanged;
  final double? totalDays;

  const Step6UsedLeave({
    super.key,
    required this.onValidChanged,
    this.onDataChanged,
    this.totalDays,
  });

  @override
  State<Step6UsedLeave> createState() => _Step6UsedLeaveState();
}

class _Step6UsedLeaveState extends State<Step6UsedLeave>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  double? get _usedDays => double.tryParse(_controller.text);

  bool get _isValid {
    final u = _usedDays;
    if (u == null || u < 0) return false;
    final total = widget.totalDays;
    if (total != null && u > total) return false;
    return true;
  }

  double? get _remainingDays {
    final total = widget.totalDays;
    final used = _usedDays;
    if (total == null || used == null) return null;
    return total - used;
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusLost);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusLost);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusLost() {
    if (_focusNode.hasFocus) return;
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    final total = widget.totalDays;
    final used = _usedDays;
    if (total == null || used == null || used <= total) return;
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('입력 오류'),
        content: Text(
          '사용한 연차가 총 발생 연차(${_fmt(total)})를 초과할 수 없습니다',
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _notify() {
    setState(() {});
    widget.onValidChanged(_isValid);
    if (_isValid) {
      widget.onDataChanged?.call(_usedDays!);
    }
  }

  static String _fmt(double? days) {
    if (days == null) return '--';
    return days % 1 == 0 ? '${days.toInt()}일' : '${days.toStringAsFixed(1)}일';
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
              '사용한 연차를 입력해주세요',
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
            child: _buildSummaryCard(),
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
            '현재까지 사용한 연차 일 수',
            style: pretendard(
              weight: 600,
              size: 20,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '반차는 0.5일로 입력해주세요.',
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
                focusNode: _focusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [_DecimalInputFormatter()],
                onChanged: (_) => _notify(),
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

  Widget _buildSummaryCard() {
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
        children: [
          _buildRow(
            label: '총 발생 연차',
            value: _fmt(widget.totalDays),
            labelStyle: pretendard(
              weight: 700,
              size: 12,
              color: const Color(0xFF777777),
            ),
            valueStyle: pretendard(
              weight: 700,
              size: 14,
              color: const Color(0xFF777777),
            ),
          ),
          const SizedBox(height: 14),
          _buildRow(
            label: '사용한 연차',
            value: _fmt(_usedDays),
            labelStyle: pretendard(
              weight: 700,
              size: 12,
              color: const Color(0xFF777777),
            ),
            valueStyle: pretendard(
              weight: 700,
              size: 14,
              color: const Color(0xFF777777),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE1E1E1), height: 1, thickness: 1),
          const SizedBox(height: 11),
          _buildRow(
            label: '남은 연차',
            value: _fmt(_remainingDays),
            labelStyle: pretendard(
              weight: 700,
              size: 15,
              color: const Color(0xFF111111),
            ),
            valueStyle: pretendard(
              weight: 700,
              size: 14,
              color: const Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    required TextStyle labelStyle,
    required TextStyle valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
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
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) return oldValue;
    return newValue;
  }
}
