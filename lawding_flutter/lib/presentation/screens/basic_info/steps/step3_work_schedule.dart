import 'package:flutter/material.dart';

import '../../../core/design_system.dart';
import '../../../widgets/common/time_picker_dialog.dart';

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
    for (final day in _selectedDays) {
      if (!_unifyWorkTime &&
          (!_perWorkStart.containsKey(day) || !_perWorkEnd.containsKey(day))) {
        return false;
      }
      if (_isEndInvalid(day: day, isWork: true)) return false;
      if (!_daysWithoutBreak.contains(day) &&
          _isEndInvalid(day: day, isWork: false)) {
        return false;
      }
    }
    return true;
  }

  // 시작 >= 마감인 경우 마감 필드를 무효 처리
  bool _isEndInvalid({required int day, required bool isWork}) {
    if (isWork) {
      if (!_unifyWorkTime &&
          (!_perWorkStart.containsKey(day) || !_perWorkEnd.containsKey(day))) {
        return false;
      }
    } else {
      if (_daysWithoutBreak.contains(day)) return false;
      if (!_unifyBreakTime &&
          (!_perBreakStart.containsKey(day) || !_perBreakEnd.containsKey(day))) {
        return false;
      }
    }
    final s = _getTime(day: day, isStart: true, isWork: isWork);
    final e = _getTime(day: day, isStart: false, isWork: isWork);
    return s.hour * 60 + s.minute >= e.hour * 60 + e.minute;
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

  Future<void> _onTimeTap({
    required int day,
    required bool isStart,
    required bool isWork,
  }) async {
    final picked = await _showTimePicker(
      _getTime(day: day, isStart: isStart, isWork: isWork),
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (isWork) {
        if (_unifyWorkTime) {
          if (isStart) { _workStart = picked; } else { _workEnd = picked; }
        } else {
          if (isStart) { _perWorkStart[day] = picked; } else { _perWorkEnd[day] = picked; }
        }
      } else {
        if (_unifyBreakTime) {
          if (isStart) { _breakStart = picked; } else { _breakEnd = picked; }
        } else {
          if (isStart) { _perBreakStart[day] = picked; } else { _perBreakEnd[day] = picked; }
        }
      }
    });
    _notify();
  }

  Future<TimeOfDay?> _showTimePicker(TimeOfDay initial) {
    return showLawdingTimePicker(context, initialTime: initial);
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
                        // 통일 → 개별: 현재 통일 시간을 모든 선택 요일에 pre-fill
                        for (final day in _selectedDays) {
                          _perWorkStart[day] = _workStart;
                          _perWorkEnd[day] = _workEnd;
                        }
                      } else {
                        // 개별 → 통일: 월요일(없으면 첫 번째 요일) 기준으로 통일 시간 갱신
                        final ref = _selectedDays.contains(1)
                            ? 1
                            : _sortedDays.first;
                        _workStart = _perWorkStart[ref] ?? _workStart;
                        _workEnd = _perWorkEnd[ref] ?? _workEnd;
                      }
                    } else {
                      _unifyBreakTime = !_unifyBreakTime;
                      if (!_unifyBreakTime) {
                        // 통일 → 개별: 현재 통일 시간을 모든 선택 요일에 pre-fill
                        for (final day in _selectedDays) {
                          if (!_daysWithoutBreak.contains(day)) {
                            _perBreakStart[day] = _breakStart;
                            _perBreakEnd[day] = _breakEnd;
                          }
                        }
                      } else {
                        // 개별 → 통일: 월요일(없으면 첫 번째 요일) 기준으로 통일 시간 갱신
                        _daysWithoutBreak.clear();
                        final ref = _selectedDays.contains(1)
                            ? 1
                            : _sortedDays.first;
                        _breakStart = _perBreakStart[ref] ?? _breakStart;
                        _breakEnd = _perBreakEnd[ref] ?? _breakEnd;
                      }
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
      final isEndInvalid = isActive && _isEndInvalid(day: day, isWork: isWork);
      final canTapTime = isWork || !_daysWithoutBreak.contains(day);
      rows.add(
        _buildTimeRow(
          day: day,
          start: _getTime(day: day, isStart: true, isWork: isWork),
          end: _getTime(day: day, isStart: false, isWork: isWork),
          isActive: isActive,
          isEndInvalid: isEndInvalid,
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
    required bool isEndInvalid,
    VoidCallback? onStartTap,
    VoidCallback? onEndTap,
    VoidCallback? onDayTap,
  }) {
    // 마감 필드: 시작 >= 마감이면 회색으로 표시 (탭은 가능)
    final endActive = isActive && !isEndInvalid;
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
                color: endActive ? const Color(0xFFF3FBFF) : Colors.white,
                border: Border.all(
                  color: endActive
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
                  color: endActive
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
