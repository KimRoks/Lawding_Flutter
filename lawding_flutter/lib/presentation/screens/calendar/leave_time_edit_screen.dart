import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../domain/core/result.dart';
import '../../../domain/entities/user_me.dart';
import '../../core/design_system.dart';
import '../../providers/providers.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/toast_message.dart';

class LeaveTimeEditScreen extends ConsumerStatefulWidget {
  const LeaveTimeEditScreen({super.key});

  @override
  ConsumerState<LeaveTimeEditScreen> createState() =>
      _LeaveTimeEditScreenState();
}

class _LeaveTimeEditScreenState extends ConsumerState<LeaveTimeEditScreen> {
  UserMe? _userMe;
  bool _isLoading = true;
  bool _isSubmitting = false;
  double? _editedDays;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final result = await ref.read(getUserMeUseCaseProvider).execute();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result case Success(:final value)) {
        _userMe = value;
      }
    });
  }

  void _showEditModal() {
    if (_isLoading) return;
    final balance = _userMe?.leaveBalance;
    final avgHours = (balance?.avgDailyWorkHours ?? 0) > 0
        ? balance!.avgDailyWorkHours
        : 8.0;
    showDialog<void>(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (ctx) => _LeaveEditSheet(
        initialDays: _editedDays ?? balance?.remainingLeaveDays,
        avgDailyWorkHours: avgHours,
        onConfirm: (days) => setState(() => _editedDays = days),
      ),
    );
  }

  Future<void> _submit() async {
    final balance = _userMe?.leaveBalance;
    final days = _editedDays ?? balance?.remainingLeaveDays;
    if (days == null) return;

    final avgHours = (balance?.avgDailyWorkHours ?? 0) > 0
        ? balance!.avgDailyWorkHours
        : 8.0;
    final remainingMinutes = (days * avgHours * 60).round();

    setState(() => _isSubmitting = true);
    final result = await ref
        .read(updateRemainingLeaveMinutesUseCaseProvider)
        .execute(remainingLeaveMinutes: remainingMinutes);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result case Success()) {
      ref.read(leaveDataRefreshProvider.notifier).state++;
      Navigator.of(context).pop();
    } else {
      ToastManager().show(context, '저장에 실패했습니다. 다시 시도해주세요.');
    }
  }

  bool get _canSubmit {
    if (_isLoading || _isSubmitting) return false;
    return (_editedDays ?? _userMe?.leaveBalance.remainingLeaveDays) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: const CustomAppBar(
        title: '남은 연차 설정',
        backgroundColor: Color(0xFFFBFBFB),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  children: [
                    _buildCurrentLeaveCard(),
                    const SizedBox(height: 18),
                    _buildInfoCard(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: _buildSubmitButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLeaveCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          Text(
            '현재 남은 연차',
            style: pretendard(
              weight: 700,
              size: 20,
              color: AppColors.textGray11,
            ),
          ),
          const SizedBox(height: 19),
          GestureDetector(
            onTap: _showEditModal,
            child: SizedBox(
              height: 48,
              child: Center(child: _buildDaysDisplay()),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _showEditModal,
            child: Container(
              width: 62,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '수정하기',
                style: pretendard(
                  weight: 700,
                  size: 12,
                  color: const Color(0xFF555555),
                  letterSpacing: -0.36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysDisplay() {
    if (_isLoading) return const CircularProgressIndicator();
    final days = _editedDays ?? _userMe?.leaveBalance.remainingLeaveDays;
    return Text(
      days != null ? '${days.toStringAsFixed(3)}일' : '--',
      style: pretendard(weight: 700, size: 40, color: AppColors.brandColor),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: BoxDecoration(
        color: const Color(0xFFCFE6FF),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: Column(
        children: [
          _buildDocumentIcon(),
          const SizedBox(height: 20),
          Text(
            '놓치기 쉬운 법정 최소 연차!',
            textAlign: TextAlign.center,
            style: pretendard(
              weight: 700,
              size: 24,
              color: AppColors.brandColor,
              letterSpacing: -0.72,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'LawDing의 연차 계산기를 통해 법적으로 보장해주는 최소 연차를 계산해보세요!',
            textAlign: TextAlign.center,
            style: pretendard(
              weight: 400,
              size: 15,
              color: AppColors.textGray11,
              letterSpacing: -0.45,
            ),
          ),
          const SizedBox(height: 20),
          _buildCalcButton(),
        ],
      ),
    );
  }

  Widget _buildDocumentIcon() {
    return SvgPicture.asset(
      'assets/icons/calendar+calculator.svg',
      width: 56,
      height: 68,
    );
  }

  Widget _buildCalcButton() {
    return GestureDetector(
      onTap: () {
        ref.read(activeTabIndexProvider.notifier).state = 1;
        Navigator.of(context).pop();
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.brandColor,
          border: Border.all(color: AppColors.brandColor),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '계산하러 가기',
              style: pretendard(weight: 700, size: 15, color: Colors.white),
            ),
            const SizedBox(width: 6),
            Image.asset(
              'assets/icons/ic_next_black.png',
              width: 6,
              height: 12,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _canSubmit ? _submit : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 48,
        decoration: BoxDecoration(
          color: _canSubmit ? AppColors.brandColor : const Color(0xFFBEC1C8),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                '등록하기',
                style: pretendard(weight: 700, size: 15, color: Colors.white),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 연차 수정 바텀시트
// ─────────────────────────────────────────────────────────────────────────────

class _LeaveEditSheet extends StatefulWidget {
  final double? initialDays;
  final double avgDailyWorkHours;
  final void Function(double) onConfirm;

  const _LeaveEditSheet({
    required this.initialDays,
    required this.avgDailyWorkHours,
    required this.onConfirm,
  });

  @override
  State<_LeaveEditSheet> createState() => _LeaveEditSheetState();
}

class _LeaveEditSheetState extends State<_LeaveEditSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (_ctrl.text.isEmpty) return widget.initialDays != null;
    final v = double.tryParse(_ctrl.text);
    return v != null && v > 0;
  }

  void _confirm() {
    final parsed = _ctrl.text.isEmpty
        ? widget.initialDays
        : double.tryParse(_ctrl.text);
    if (parsed == null) return;

    widget.onConfirm(parsed);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 핸들 바
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 63,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // 닫기 버튼
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF6F6F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                ),
                // 연차 발생 개수 섹션
                Text(
                  '연차 발생 개수',
                  style: pretendard(
                    weight: 600,
                    size: 20,
                    color: const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '자신의 연차 개수를 직접 입력하세요',
                  style: pretendard(
                    weight: 600,
                    size: 11,
                    color: AppColors.textGray99,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 35,
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _ctrl,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [_DecimalInputFormatter()],
                      style: pretendard(
                        weight: 500,
                        size: 15,
                        color: const Color(0xFF555555),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: widget.initialDays != null
                            ? widget.initialDays!.toStringAsFixed(3)
                            : '0',
                        hintStyle: pretendard(
                          weight: 500,
                          size: 15,
                          color: AppColors.textGray99,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE1E1E1)),
                const SizedBox(height: 20),
                // 확인 버튼
                GestureDetector(
                  onTap: _isValid ? _confirm : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isValid
                          ? AppColors.brandColor
                          : const Color(0xFFBEC1C8),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '확인',
                      style: pretendard(
                        weight: 700,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
    if (!RegExp(r'^\d*\.?\d{0,3}$').hasMatch(text)) return oldValue;
    final intPart = text.split('.').first;
    if (intPart.isNotEmpty) {
      final intValue = int.tryParse(intPart);
      if (intValue != null && intValue >= 50) return oldValue;
    }
    return newValue;
  }
}
