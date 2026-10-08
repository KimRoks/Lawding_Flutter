import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design_system.dart';

/// 공용 시간 선택 다이얼로그.
///
/// 사용:
/// ```dart
/// final time = await showLawdingTimePicker(context, initialTime: _startTime);
/// if (time != null) setState(() => _startTime = time);
/// ```
Future<TimeOfDay?> showLawdingTimePicker(
  BuildContext context, {
  TimeOfDay? initialTime,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    barrierColor: const Color(0x80000000),
    builder: (_) => _LawdingTimePicker(
      initialTime: initialTime ?? const TimeOfDay(hour: 9, minute: 0),
    ),
  );
}

class _LawdingTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  const _LawdingTimePicker({required this.initialTime});

  @override
  State<_LawdingTimePicker> createState() => _LawdingTimePickerState();
}

class _LawdingTimePickerState extends State<_LawdingTimePicker> {
  static const double _itemExtent = 37;
  static const int _visibleCount = 5;
  static const double _pickerHeight = _itemExtent * _visibleCount;

  // 시: 유한 스크롤. 인덱스 = 24시간제 시각 (0 = 오전 12시 ~ 23 = 오후 11시)
  static const int _hourItemCount = 24;
  // 분: 유한 스크롤 (0분 ~ 55분, 5분 단위)
  static const int _minuteItemCount = 12;

  late bool _isAm;
  late int _hour;   // 1–12
  late int _minute; // 0, 5, 10, ..., 55

  late int _selectedHourIndex;
  late int _selectedMinuteIndex;

  bool _isProgrammatic = false;

  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minuteCtrl;

  @override
  void initState() {
    super.initState();
    _isAm = widget.initialTime.hour < 12;
    _hour = _hour12(widget.initialTime.hour);
    _minute = ((widget.initialTime.minute / 5).round() * 5) % 60;

    final hourIndex = widget.initialTime.hour;
    final minuteIndex = _minute ~/ 5;

    _selectedHourIndex = hourIndex;
    _selectedMinuteIndex = minuteIndex;

    _hourCtrl = FixedExtentScrollController(initialItem: hourIndex);
    _minuteCtrl = FixedExtentScrollController(initialItem: minuteIndex);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  /// 세그먼트 탭 → 같은 시각의 오전/오후로 ±12 점프
  void _switchAmPm(bool toAm) {
    if (_isAm == toAm) return;
    final current = _hourCtrl.selectedItem;
    final offset = toAm ? -12 : 12;
    final target = (current + offset).clamp(0, _hourItemCount - 1);
    _isProgrammatic = true;
    _hourCtrl.jumpToItem(target);
    HapticFeedback.lightImpact();
    setState(() => _isAm = toAm);
  }

  /// 24시간제 시각(0~23) → 12시간제 표기(12, 1~11)
  static int _hour12(int hour24) => hour24 % 12 == 0 ? 12 : hour24 % 12;

  TimeOfDay get _result {
    final h24 = _isAm
        ? (_hour == 12 ? 0 : _hour)
        : (_hour == 12 ? 12 : _hour + 12);
    return TimeOfDay(hour: h24, minute: _minute);
  }

  @override
  Widget build(BuildContext context) {
    final period = _isAm ? '오전' : '오후';
    final mStr = _minute.toString().padLeft(2, '0');

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들 바
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
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
                onTap: () => Navigator.pop(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
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
            const SizedBox(height: 10),
            // 오전/오후 세그먼트 컨트롤
            _buildAmPmToggle(),
            const SizedBox(height: 16),
            // 선택된 시간 표시
            Text(
              '$period $_hour:$mStr',
              style: pretendard(
                weight: 700,
                size: 24,
                color: AppColors.brandColor,
              ),
            ),
            const SizedBox(height: 12),
            // 드럼 피커
            SizedBox(
              height: _pickerHeight,
              child: Stack(
                children: [
                  // 중앙 하이라이트 바
                  Center(
                    child: Container(
                      height: _itemExtent,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  // 시·분 휠
                  Row(
                    children: [
                      Expanded(flex: 3, child: _buildHourWheel()),
                      Expanded(flex: 2, child: _buildMinuteWheel()),
                    ],
                  ),
                  // 상단 페이드
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: (_pickerHeight - _itemExtent) / 2,
                    child: IgnorePointer(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Color(0x00FFFFFF)],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 하단 페이드
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: (_pickerHeight - _itemExtent) / 2,
                    child: IgnorePointer(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.white, Color(0x00FFFFFF)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 확인 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _result),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '확인',
                  style: pretendard(weight: 700, size: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmPmToggle() {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        border: Border.all(color: const Color(0xFFE1E1E1), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pillWidth = constraints.maxWidth / 2;
          return Stack(
            children: [
              // 슬라이딩 흰 pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                left: _isAm ? 0 : pillWidth,
                top: 0,
                bottom: 0,
                width: pillWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 4,
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                ),
              ),
              // 레이블
              Row(
                children: [
                  _buildSegmentLabel('오전', isActive: _isAm, onTap: () => _switchAmPm(true)),
                  _buildSegmentLabel('오후', isActive: !_isAm, onTap: () => _switchAmPm(false)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegmentLabel(
    String label, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            style: pretendard(
              weight: 700,
              size: 14,
              color: isActive ? const Color(0xFF111111) : const Color(0xFFDADADA),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildHourWheel() {
    return ListWheelScrollView.useDelegate(
      controller: _hourCtrl,
      itemExtent: _itemExtent,
      diameterRatio: 100,
      overAndUnderCenterOpacity: 1.0,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (i) {
        if (!_isProgrammatic) HapticFeedback.selectionClick();
        _isProgrammatic = false;
        setState(() {
          _selectedHourIndex = i;
          _hour = _hour12(i);
          _isAm = i < 12;
        });
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: _hourItemCount,
        builder: (_, i) {
          final h = _hour12(i);
          final period = i < 12 ? '오전' : '오후';
          final selected = _selectedHourIndex == i;
          return Center(
            child: Text(
              '$period $h시',
              style: pretendard(
                weight: 600,
                size: 18,
                color: selected
                    ? const Color(0xFF000000)
                    : const Color(0xFF999999),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMinuteWheel() {
    return ListWheelScrollView.useDelegate(
      controller: _minuteCtrl,
      itemExtent: _itemExtent,
      diameterRatio: 100,
      overAndUnderCenterOpacity: 1.0,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (i) {
        if (!_isProgrammatic) HapticFeedback.selectionClick();
        setState(() {
          _selectedMinuteIndex = i;
          _minute = i * 5;
        });
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: _minuteItemCount,
        builder: (_, i) {
          final m = i * 5;
          final selected = _selectedMinuteIndex == i;
          return Center(
            child: Text(
              '$m분',
              style: pretendard(
                weight: 600,
                size: 18,
                color: selected
                    ? const Color(0xFF000000)
                    : const Color(0xFF999999),
              ),
            ),
          );
        },
      ),
    );
  }
}
