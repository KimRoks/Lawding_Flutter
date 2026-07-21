import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design_system.dart';
import '../../../widgets/common/submit_button.dart';

class Step3Data {
  // 선택된 요일별 근무 시작/종료 시간 (1=월~7=일)
  final Map<int, TimeOfDay> workStarts;
  final Map<int, TimeOfDay> workEnds;
  // 휴게시간 (비활성화된 요일은 포함되지 않음)
  final Map<int, TimeOfDay> breakStarts;
  final Map<int, TimeOfDay> breakEnds;

  const Step3Data({
    required this.workStarts,
    required this.workEnds,
    required this.breakStarts,
    required this.breakEnds,
  });
}

class Step3WorkSchedule extends StatefulWidget {
  final void Function(bool) onValidChanged;
  final void Function(Step3Data)? onDataChanged;

  const Step3WorkSchedule({
    super.key,
    required this.onValidChanged,
    this.onDataChanged,
  });

  @override
  State<Step3WorkSchedule> createState() => _Step3WorkScheduleState();
}

class _Step3WorkScheduleState extends State<Step3WorkSchedule>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  // 1=월 ~ 7=일, 기본값: 월~금
  final Set<int> _selectedDays = {1, 2, 3, 4, 5};

  bool _unifyWorkTime = true;
  bool _unifyBreakTime = true;

  // 통일 시간
  TimeOfDay _workStart = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _workEnd = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _breakStart = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _breakEnd = const TimeOfDay(hour: 13, minute: 0);

  // 요일별 개별 시간 (통일 OFF 시)
  final Map<int, TimeOfDay> _perWorkStart = {};
  final Map<int, TimeOfDay> _perWorkEnd = {};
  final Map<int, TimeOfDay> _perBreakStart = {};
  final Map<int, TimeOfDay> _perBreakEnd = {};

  // 휴게시간 비활성화된 요일 (원형 버튼으로 개별 토글)
  final Set<int> _daysWithoutBreak = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
  }

  bool get _isValid {
    if (_selectedDays.isEmpty) return false;
    if (!_unifyWorkTime) {
      for (final day in _selectedDays) {
        if (!_perWorkStart.containsKey(day) || !_perWorkEnd.containsKey(day)) {
          return false;
        }
      }
    }
    return true;
  }

  void _notify() {
    widget.onValidChanged(_isValid);
    if (_isValid) {
      final starts = <int, TimeOfDay>{};
      final ends = <int, TimeOfDay>{};
      final breakStarts = <int, TimeOfDay>{};
      final breakEnds = <int, TimeOfDay>{};
      for (final day in _selectedDays) {
        starts[day] = _getTime(day: day, isStart: true, isWork: true);
        ends[day] = _getTime(day: day, isStart: false, isWork: true);
        if (!_daysWithoutBreak.contains(day)) {
          breakStarts[day] = _getTime(day: day, isStart: true, isWork: false);
          breakEnds[day] = _getTime(day: day, isStart: false, isWork: false);
        }
      }
      widget.onDataChanged?.call(
        Step3Data(
          workStarts: starts,
          workEnds: ends,
          breakStarts: breakStarts,
          breakEnds: breakEnds,
        ),
      );
    }
  }

  List<int> get _sortedDays => _selectedDays.toList()..sort();

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
    _notify();
  }

  TimeOfDay _getTime({
    required int day,
    required bool isStart,
    required bool isWork,
  }) {
    if (isWork) {
      if (_unifyWorkTime) {
        return isStart ? _workStart : _workEnd;
      }
      // 통일 OFF: 개별 시간이 없으면 00:00 표시(미입력 상태)
      return isStart
          ? (_perWorkStart[day] ?? const TimeOfDay(hour: 0, minute: 0))
          : (_perWorkEnd[day] ?? const TimeOfDay(hour: 0, minute: 0));
    } else {
      if (_daysWithoutBreak.contains(day)) {
        return const TimeOfDay(hour: 0, minute: 0);
      }
      if (_unifyBreakTime) {
        return isStart ? _breakStart : _breakEnd;
      }
      return isStart
          ? (_perBreakStart[day] ?? _breakStart)
          : (_perBreakEnd[day] ?? _breakEnd);
    }
  }

  bool _isRowActive(int day, bool isWork) {
    if (isWork) {
      if (_unifyWorkTime) return true;
      return _perWorkStart.containsKey(day);
    } else {
      if (_daysWithoutBreak.contains(day)) return false;
      if (_unifyBreakTime) return true;
      return _perBreakStart.containsKey(day);
    }
  }

  void _toggleBreakDay(int day) {
    setState(() {
      if (_daysWithoutBreak.contains(day)) {
        _daysWithoutBreak.remove(day);
      } else {
        _daysWithoutBreak.add(day);
        _perBreakStart.remove(day);
        _perBreakEnd.remove(day);
      }
    });
    _notify();
  }

  /// 상대방 시간이 이미 설정되어 있는지 여부 (per-day 모드에서 미설정이면 검사 스킵)
  bool _isCounterpartSet({
    required int day,
    required bool isStart,
    required bool isWork,
  }) {
    if (isWork) {
      if (_unifyWorkTime) return true;
      return isStart
          ? _perWorkEnd.containsKey(day)
          : _perWorkStart.containsKey(day);
    } else {
      if (_daysWithoutBreak.contains(day)) return false;
      if (_unifyBreakTime) return true;
      return isStart
          ? _perBreakEnd.containsKey(day)
          : _perBreakStart.containsKey(day);
    }
  }

  void _showTimeError(String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('시간 설정 오류'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _onTimeTap({
    required int day,
    required bool isStart,
    required bool isWork,
  }) async {
    TimeOfDay? minTime;
    TimeOfDay? maxTime;

    if (_isCounterpartSet(day: day, isStart: isStart, isWork: isWork)) {
      final counterpart = _getTime(day: day, isStart: !isStart, isWork: isWork);
      if (isStart) {
        maxTime = counterpart; // 시작 시간 < 마감 시간
      } else {
        minTime = counterpart; // 마감 시간 > 시작 시간
      }
    }

    final picked = await _showTimePicker(
      _getTime(day: day, isStart: isStart, isWork: isWork),
      minTime: minTime,
      maxTime: maxTime,
    );
    if (picked == null || !mounted) return;

    // 혹시라도 통과된 경우 최종 방어
    if (minTime != null) {
      final pickedMin = picked.hour * 60 + picked.minute;
      final minMin = minTime.hour * 60 + minTime.minute;
      if (pickedMin <= minMin) {
        _showTimeError('마감 시간은 시작 시간보다 늦은 시간이어야 합니다.');
        return;
      }
    }
    if (maxTime != null) {
      final pickedMin = picked.hour * 60 + picked.minute;
      final maxMin = maxTime.hour * 60 + maxTime.minute;
      if (pickedMin >= maxMin) {
        _showTimeError('시작 시간은 마감 시간보다 이른 시간이어야 합니다.');
        return;
      }
    }

    setState(() {
      final unified = isWork ? _unifyWorkTime : _unifyBreakTime;
      if (unified) {
        if (isWork) {
          if (isStart) {
            _workStart = picked;
          } else {
            _workEnd = picked;
          }
        } else {
          if (isStart) {
            _breakStart = picked;
          } else {
            _breakEnd = picked;
          }
        }
      } else {
        if (isWork) {
          if (isStart) {
            _perWorkStart[day] = picked;
          } else {
            _perWorkEnd[day] = picked;
          }
        } else {
          if (isStart) {
            _perBreakStart[day] = picked;
          } else {
            _perBreakEnd[day] = picked;
          }
        }
      }
    });
    _notify();
  }

  Future<TimeOfDay?> _showTimePicker(
    TimeOfDay initial, {
    TimeOfDay? minTime,
    TimeOfDay? maxTime,
  }) async {
    // 초기값을 범위 안으로 클램핑
    int clampedTotalMin = initial.hour * 60 + initial.minute;
    if (minTime != null) {
      final minMin = minTime.hour * 60 + minTime.minute + 5;
      if (clampedTotalMin <= minMin - 5) clampedTotalMin = minMin;
    }
    if (maxTime != null) {
      final maxMin = maxTime.hour * 60 + maxTime.minute - 5;
      if (clampedTotalMin >= maxMin + 5) clampedTotalMin = maxMin;
    }
    var tempHour = clampedTotalMin ~/ 60;
    var tempMinute = (clampedTotalMin % 60 ~/ 5) * 5;

    return showModalBottomSheet<TimeOfDay>(
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
                child: Row(
                  children: [
                    _buildWheelPicker(
                      items: List.generate(
                        24,
                        (i) => '${i.toString().padLeft(2, '0')}시',
                      ),
                      initialItem: tempHour,
                      onChanged: (i) => tempHour = i,
                    ),
                    _buildWheelPicker(
                      items: List.generate(
                        12,
                        (i) => '${(i * 5).toString().padLeft(2, '0')}분',
                      ),
                      initialItem: tempMinute ~/ 5,
                      onChanged: (i) => tempMinute = i * 5,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 30 + bottomInset),
                child: SubmitButton(
                  text: '확인',
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(TimeOfDay(hour: tempHour, minute: tempMinute)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWheelPicker({
    required List<String> items,
    required int initialItem,
    required void Function(int) onChanged,
  }) {
    return Expanded(
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: initialItem),
        itemExtent: 40,
        onSelectedItemChanged: (i) {
          HapticFeedback.selectionClick();
          onChanged(i);
        },
        children: items
            .map(
              (item) => Center(
                child: Text(item, style: pretendard(weight: 500, size: 23)),
              ),
            )
            .toList(),
      ),
    );
  }

  static String _formatTime(TimeOfDay t) {
    final isAm = t.hour < 12;
    final prefix = isAm ? '오전' : '오후';
    final hour = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    return '$prefix ${hour.toString().padLeft(2, '0')} : ${t.minute.toString().padLeft(2, '0')}';
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
              '근무일과 휴게시간을 설정해주세요',
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
            child: _buildDaySelectorCard(),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTimeCard(isWork: true),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTimeCard(isWork: false),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDaySelectorCard() {
    return Container(
      height: 73,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final day = i + 1;
          final isSelected = _selectedDays.contains(day);
          return GestureDetector(
            onTap: () => _toggleDay(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 33,
              height: 33,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFF3FBFF) : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? AppColors.brandColor
                      : const Color(0xFFE1E1E1),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _dayLabels[i],
                style: pretendard(
                  weight: 600,
                  size: 16,
                  color: isSelected
                      ? AppColors.brandColor
                      : const Color(0xFF999999),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimeCard({required bool isWork}) {
    final isUnified = isWork ? _unifyWorkTime : _unifyBreakTime;

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
          Row(
            children: [
              Text(
                isWork ? '근무시간' : '휴게시간(점심시간)',
                style: pretendard(
                  weight: 600,
                  size: 20,
                  color: const Color(0xFF333333),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isWork) {
                      _unifyWorkTime = !_unifyWorkTime;
                      if (!_unifyWorkTime) {
                        _perWorkStart.clear();
                        _perWorkEnd.clear();
                      }
                    } else {
                      _unifyBreakTime = !_unifyBreakTime;
                      if (_unifyBreakTime) _daysWithoutBreak.clear();
                    }
                  });
                  _notify();
                },
                child: Row(
                  children: [
                    Text(
                      isWork ? '모든 근무시간 통일하기' : '모든 휴게시간 통일하기',
                      style: pretendard(
                        weight: 600,
                        size: 12,
                        color: isUnified
                            ? AppColors.brandColor
                            : const Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUnified
                            ? AppColors.brandColor
                            : const Color(0xFF999999),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ..._buildTimeRows(isWork: isWork),
        ],
      ),
    );
  }

  List<Widget> _buildTimeRows({required bool isWork}) {
    final rows = <Widget>[];
    final days = _sortedDays;
    for (int i = 0; i < days.length; i++) {
      if (i > 0) rows.add(const SizedBox(height: 18));
      final day = days[i];
      final isActive = _isRowActive(day, isWork);
      final canTapTime = isWork || !_daysWithoutBreak.contains(day);
      rows.add(
        _buildTimeRow(
          day: day,
          start: _getTime(day: day, isStart: true, isWork: isWork),
          end: _getTime(day: day, isStart: false, isWork: isWork),
          isActive: isActive,
          onStartTap: canTapTime
              ? () => _onTimeTap(day: day, isStart: true, isWork: isWork)
              : null,
          onEndTap: canTapTime
              ? () => _onTimeTap(day: day, isStart: false, isWork: isWork)
              : null,
          onDayTap: isWork ? null : () => _toggleBreakDay(day),
        ),
      );
    }
    return rows;
  }

  Widget _buildTimeRow({
    required int day,
    required TimeOfDay start,
    required TimeOfDay end,
    required bool isActive,
    VoidCallback? onStartTap,
    VoidCallback? onEndTap,
    VoidCallback? onDayTap,
  }) {
    return Row(
      children: [
        GestureDetector(
          onTap: onDayTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 33,
            height: 33,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFFF3FBFF) : Colors.white,
              border: Border.all(
                color: isActive
                    ? AppColors.brandColor
                    : const Color(0xFFE1E1E1),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _dayLabels[day - 1],
              style: pretendard(
                weight: 600,
                size: 16,
                color: isActive
                    ? AppColors.brandColor
                    : const Color(0xFF999999),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: onStartTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 35,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFF3FBFF) : Colors.white,
                border: Border.all(
                  color: isActive
                      ? AppColors.brandColor
                      : const Color(0xFFE1E1E1),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                _formatTime(start),
                style: pretendard(
                  weight: 500,
                  size: 15,
                  color: isActive
                      ? AppColors.brandColor
                      : const Color(0xFF999999),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Container(
            width: 8,
            height: 3,
            decoration: BoxDecoration(
              color: isActive ? AppColors.brandColor : const Color(0xFFE1E1E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onEndTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 35,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFF3FBFF) : Colors.white,
                border: Border.all(
                  color: isActive
                      ? AppColors.brandColor
                      : const Color(0xFFE1E1E1),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                _formatTime(end),
                style: pretendard(
                  weight: 500,
                  size: 15,
                  color: isActive
                      ? AppColors.brandColor
                      : const Color(0xFF999999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
