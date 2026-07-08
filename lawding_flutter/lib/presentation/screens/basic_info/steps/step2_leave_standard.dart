import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/design_system.dart';
import '../../../widgets/common/date_picker_sheet.dart';
import '../../../widgets/common/submit_button.dart';

enum LeaveStandard { hireDate, fiscalYear }

class Step2Data {
  final LeaveStandard standard;
  final DateTime hireDate;
  // 회계연도 기준일 월 ("1"~"12"), 입사일 기준이면 null
  final String? fiscalMonth;

  const Step2Data({
    required this.standard,
    required this.hireDate,
    this.fiscalMonth,
  });
}

class Step2LeaveStandard extends StatefulWidget {
  final void Function(bool) onValidChanged;
  final void Function(Step2Data)? onDataChanged;

  const Step2LeaveStandard({
    super.key,
    required this.onValidChanged,
    this.onDataChanged,
  });

  @override
  State<Step2LeaveStandard> createState() => _Step2LeaveStandardState();
}

class _Step2LeaveStandardState extends State<Step2LeaveStandard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  LeaveStandard? _selected;
  DateTime? _hireDate;
  final _monthCtrl = TextEditingController(text: '1');

  @override
  void dispose() {
    _monthCtrl.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (_selected == null || _hireDate == null) return false;
    if (_selected == LeaveStandard.fiscalYear) {
      final m = int.tryParse(_monthCtrl.text);
      return m != null && m >= 1 && m <= 12;
    }
    return true;
  }

  void _notify() {
    widget.onValidChanged(_isValid);
    if (_isValid && _selected != null && _hireDate != null) {
      widget.onDataChanged?.call(Step2Data(
        standard: _selected!,
        hireDate: _hireDate!,
        fiscalMonth:
            _selected == LeaveStandard.fiscalYear ? _monthCtrl.text : null,
      ));
    }
  }

  void _selectStandard(LeaveStandard standard) {
    setState(() => _selected = standard);
    _notify();
  }

  Future<void> _pickHireDate() async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          DatePickerSheet(initialDate: _hireDate ?? DateTime.now()),
    );
    if (picked != null && mounted) {
      setState(() => _hireDate = picked);
      _notify();
    }
  }

  Future<void> _pickFiscalMonth() async {
    var tempMonth = int.tryParse(_monthCtrl.text) ?? 1;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return Container(
          height: 310 + bottomInset,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: tempMonth - 1,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    tempMonth = index + 1;
                  },
                  children: List.generate(
                    12,
                    (i) => Center(
                      child: Text(
                        '${i + 1}월',
                        style: pretendard(weight: 500, size: 23),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 30 + bottomInset),
                child: SubmitButton(
                  text: '확인',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (mounted) {
      setState(() => _monthCtrl.text = tempMonth.toString());
      _notify();
    }
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final today = _fmt(DateTime.now());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 45),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '연차 산정 기준을 선택해주세요',
              textAlign: TextAlign.center,
              style: pretendard(
                weight: 600,
                size: 23,
                color: AppColors.brandColor,
              ),
            ),
          ),
          const SizedBox(height: 44),
          // 선택 카드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _StandardCard(
                      title: '입사일 기준',
                      description: '입사일을 기준으로 1년 단위로 연차가 발생하는 방식',
                      isSelected: _selected == LeaveStandard.hireDate,
                      onTap: () => _selectStandard(LeaveStandard.hireDate),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _StandardCard(
                      title: '회계연도 기준',
                      description: '회사에서 정한 특정 기준일을 기준으로 연차를 계산하는 방식',
                      isSelected: _selected == LeaveStandard.fiscalYear,
                      onTap: () => _selectStandard(LeaveStandard.fiscalYear),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 입사일 입력 카드 (공통)
          if (_selected != null) ...[
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildHireDateCard(today),
            ),
          ],
          // 회계연도 기준일 카드 (회계연도 기준 선택 시만)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _selected == LeaveStandard.fiscalYear
                ? Padding(
                    key: const ValueKey('fiscal'),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: _buildFiscalRefCard(),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHireDateCard(String today) {
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
            '입사일',
            style: pretendard(
              weight: 600,
              size: 20,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '현재 날짜는 $today 입니다',
            style: pretendard(
              weight: 600,
              size: 11,
              color: AppColors.textGray99,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: _pickHireDate,
            child: Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                _hireDate != null ? _fmt(_hireDate!) : 'YYYY.MM.DD',
                style: pretendard(
                  weight: 500,
                  size: 15,
                  color: _hireDate != null
                      ? const Color(0xFF555555)
                      : AppColors.textGray99,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiscalRefCard() {
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
            '회계연도 기준일',
            style: pretendard(
              weight: 600,
              size: 20,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: _pickFiscalMonth,
                child: Container(
                  width: 41,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _monthCtrl.text,
                    style: pretendard(
                      weight: 500,
                      size: 15,
                      color: const Color(0xFF555555),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '월',
                  style: pretendard(
                    weight: 500,
                    size: 15,
                    color: AppColors.textGray99,
                  ),
                ),
              ),
              Container(
                width: 41,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1E1E1),
                  border: Border.all(color: const Color(0xFF999999)),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '1',
                  style: pretendard(
                    weight: 500,
                    size: 15,
                    color: const Color(0xFF999999),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '일',
                  style: pretendard(
                    weight: 500,
                    size: 15,
                    color: AppColors.textGray99,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Sub-widgets
// ============================================================================

class _StandardCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _StandardCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3FBFF) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.brandColor : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: pretendard(
                weight: 600,
                size: 20,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: pretendard(
                weight: 400,
                size: 13,
                color: isSelected ? AppColors.brandColor : AppColors.textGray99,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
