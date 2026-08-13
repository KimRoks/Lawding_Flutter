import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/calendar_event.dart';
import '../../../domain/entities/calendar_event_request.dart';
import '../../../data/network/network_error.dart';
import '../../../domain/core/result.dart';
import '../../../domain/entities/holiday.dart';
import '../../../domain/entities/leave_policy.dart';
import '../../../infrastructure/services/analytics_service.dart';
import '../../core/design_system.dart';
import '../../providers/providers.dart';
import 'leave_time_calculator.dart';

class AddCalendarEventScreen extends ConsumerStatefulWidget {
  /// null이면 등록 모드, non-null이면 수정 모드
  final CalendarEventEntity? editEvent;

  const AddCalendarEventScreen({super.key, this.editEvent});

  @override
  ConsumerState<AddCalendarEventScreen> createState() =>
      _AddCalendarEventScreenState();
}

class _AddCalendarEventScreenState
    extends ConsumerState<AddCalendarEventScreen> {
  static const _dayLabels = ['일', '월', '화', '수', '목', '금', '토'];

  // ── 폼 상태 ──────────────────────────────────────────────────────────────

  bool _isLeaveEvent = true;
  bool _isAllDay = false;
  bool _isSubmitting = false;
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _calendarMonth;
  late List<List<DateTime>> _weeks;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  LeavePolicy? _leavePolicy;

  double get _avgDailyWorkHours {
    if (_leavePolicy != null) return _leavePolicy!.dailyWorkMinutes / 60.0;
    return ref.read(dailyWorkMinutesProvider) / 60.0;
  }

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<Holiday> _holidays = [];

  @override
  void initState() {
    super.initState();
    final edit = widget.editEvent;
    if (edit != null) {
      _isLeaveEvent = edit.isLeaveEvent;
      _isAllDay = edit.isAllDay;
      _startDate = edit.startDatetime;
      _endDate = _isSameDay(edit.startDatetime, edit.endDatetime)
          ? null
          : edit.endDatetime;
      if (!edit.isAllDay) {
        _startTime = TimeOfDay.fromDateTime(edit.startDatetime);
        _endTime = TimeOfDay.fromDateTime(edit.endDatetime);
      }
      _titleController.text = edit.title;
      _descriptionController.text = edit.description;
      _calendarMonth = DateTime(
        edit.startDatetime.year,
        edit.startDatetime.month,
        1,
      );
    } else {
      final now = DateTime.now();
      _calendarMonth = DateTime(now.year, now.month, 1);
    }
    _weeks = _buildWeeks(_calendarMonth);
    _fetchHolidays();
    _fetchUserMe();
    AnalyticsService().logCalendarEventFormScreenViewed(isEdit: widget.editEvent != null);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserMe() async {
    final result = await ref.read(getUserMeUseCaseProvider).execute();
    if (result case Success(:final value)) {
      if (!mounted) return;
      setState(() => _leavePolicy = value.leavePolicy);
    }
  }

  Future<void> _fetchHolidays() async {
    final year = _calendarMonth.year;
    final result = await ref
        .read(getHolidaysUseCaseProvider)
        .execute(startYear: year - 1, endYear: year + 2);
    switch (result) {
      case Success(:final value):
        if (!mounted) return;
        setState(() => _holidays = value);
      case Failure():
        break;
    }
  }

  // ── 헬퍼 ────────────────────────────────────────────────────────────────

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isHolidayDate(DateTime date) =>
      _holidays.any((h) => _isSameDay(h.date, date));

  /// 6주 고정 grid — 이전/다음 달 날짜 채움
  List<List<DateTime>> _buildWeeks(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sun

    final cells = <DateTime>[];

    // 이전 달 채우기
    for (int i = startWeekday - 1; i >= 0; i--) {
      cells.add(firstDay.subtract(Duration(days: i + 1)));
    }
    // 현재 달
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(month.year, month.month, d));
    }
    // 다음 달 채우기 (7의 배수로)
    int nextDay = 1;
    while (cells.length % 7 != 0) {
      cells.add(DateTime(month.year, month.month + 1, nextDay++));
    }

    final weeks = <List<DateTime>>[];
    for (int i = 0; i < cells.length; i += 7) {
      weeks.add(cells.sublist(i, i + 7));
    }
    return weeks;
  }

  String _formatDatePill(DateTime date) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final y = (date.year % 100).toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final w = weekdays[date.weekday % 7];
    return '$y.$m.$d($w)';
  }

  String _formatTimePill(TimeOfDay time) {
    final isAm = time.hour < 12;
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    return '${isAm ? '오전' : '오후'} $h시$m분';
  }

  String _formatMinutes(int minutes) {
    final hours = minutes / 60;
    return '${hours.toStringAsFixed(1)}시간';
  }

  static const _weekdayNames = {
    1: 'MONDAY',
    2: 'TUESDAY',
    3: 'WEDNESDAY',
    4: 'THURSDAY',
    5: 'FRIDAY',
    6: 'SATURDAY',
    7: 'SUNDAY',
  };


  LeaveTimeCalculator get _calculator => LeaveTimeCalculator(
        workPattern: _leavePolicy?.workPattern ?? const {},
        breakTimePattern: _leavePolicy?.breakTimePattern ?? const {},
        avgDailyWorkHours: _avgDailyWorkHours,
        holidays: _holidays,
      );

  int _calcUsedMinutesForDate(DateTime date, {int? inputStartOverride, int? inputEndOverride}) {
    if (_leavePolicy != null) {
      if (!_isAllDay && (_startTime == null || _endTime == null)) return 0;
      return _calculator.calcUsedMinutesForDate(
        date,
        inputStartMin: inputStartOverride ?? (_startTime!.hour * 60 + _startTime!.minute),
        inputEndMin: inputEndOverride ?? (_endTime!.hour * 60 + _endTime!.minute),
        isAllDay: _isAllDay,
      );
    }
    // fallback: 정책 미로드
    if (_isHolidayDate(date)) return 0;
    final maxMin = (_avgDailyWorkHours * 60).round();
    if (_isAllDay) return maxMin;
    if (_startTime == null || _endTime == null) return 0;
    final s = inputStartOverride ?? (_startTime!.hour * 60 + _startTime!.minute);
    final e = inputEndOverride ?? (_endTime!.hour * 60 + _endTime!.minute);
    return (e - s).clamp(0, maxMin);
  }

  int _calcTotalUsedMinutes() {
    if (_startDate == null) return _calcUsedMinutes();
    if (!_isAllDay && (_startTime == null || _endTime == null)) return 0;
    final startMin = _isAllDay ? 0 : (_startTime!.hour * 60 + _startTime!.minute);
    final endMin = _isAllDay ? 0 : (_endTime!.hour * 60 + _endTime!.minute);
    return _calculator.calcTotalUsedMinutes(
      _selectedDates(),
      startMin: startMin,
      endMin: endMin,
      isAllDay: _isAllDay,
    );
  }

  /// 날짜가 공휴일 또는 비근로일인지 확인
  bool _isNonWorkOrHoliday(DateTime d) {
    if (_isHolidayDate(d)) return true;
    if (_leavePolicy == null) return false;
    return _leavePolicy!.workPattern[_weekdayNames[d.weekday]!] == null;
  }

  bool _hasWorkDayWithNoOverlap(List<DateTime> dates) {
    if (_startTime == null || _endTime == null) return false;
    return _calculator.hasWorkDayWithNoOverlap(
      dates,
      startMin: _startTime!.hour * 60 + _startTime!.minute,
      endMin: _endTime!.hour * 60 + _endTime!.minute,
    );
  }

  bool _hasOutsideWorkHours(List<DateTime> dates) {
    if (_startTime == null || _endTime == null) return false;
    return _calculator.hasOutsideWorkHours(
      dates,
      startMin: _startTime!.hour * 60 + _startTime!.minute,
      endMin: _endTime!.hour * 60 + _endTime!.minute,
    );
  }

  int _calcUsedMinutes() {
    if (_isAllDay) return (_avgDailyWorkHours * 60).round();
    if (_startTime == null || _endTime == null) return 0;
    if (_startDate != null) return _calcUsedMinutesForDate(_startDate!);
    final s = _startTime!.hour * 60 + _startTime!.minute;
    final e = _endTime!.hour * 60 + _endTime!.minute;
    return (e - s).clamp(0, (_avgDailyWorkHours * 60).round());
  }

  Future<TimeOfDay?> _showTimePicker(TimeOfDay? initial) async {
    // 5분 단위로 반올림 (initialDateTime이 5의 배수여야 picker가 올바른 위치에서 시작)
    final raw = initial ?? const TimeOfDay(hour: 9, minute: 0);
    final roundedMinute = (raw.minute ~/ 5) * 5;
    TimeOfDay picked = TimeOfDay(hour: raw.hour, minute: roundedMinute);
    return await showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (ctx) {
        return Container(
          color: Colors.white,
          height: 300,
          child: Column(
            children: [
              // 완료 버튼
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(ctx, picked),
                      child: Text(
                        '완료',
                        style: pretendard(
                          weight: 700,
                          size: 16,
                          color: AppColors.brandColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: false,
                  minuteInterval: 5,
                  initialDateTime: DateTime(
                    2000,
                    1,
                    1,
                    picked.hour,
                    picked.minute,
                  ),
                  onDateTimeChanged: (dt) {
                    picked = TimeOfDay(hour: dt.hour, minute: dt.minute);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onDateTapped(DateTime date) {
    setState(() {
      if (_startDate == null) {
        // 첫 번째 선택 → 시작일 세팅
        _startDate = date;
        _endDate = null;
      } else if (_endDate == null) {
        if (_isSameDay(date, _startDate!)) {
          // 같은 날 재탭 → 초기화
          _startDate = null;
        } else if (date.isAfter(_startDate!)) {
          // 이후 날짜 → 종료일
          _endDate = date;
        } else {
          // 이전 날짜 → 스왑
          _endDate = _startDate;
          _startDate = date;
        }
      } else {
        // 이미 범위 선택된 상태 → 재시작
        _startDate = date;
        _endDate = null;
      }
    });
    if (_startDate != null) {
      AnalyticsService().logCalendarEventDateSelected(isRange: _endDate != null);
    }
  }

  /// 선택된 기간의 날짜 목록 반환
  List<DateTime> _selectedDates() {
    final start = _startDate!;
    final end = _endDate ?? start;
    final dates = <DateTime>[];
    var cursor = start;
    while (!cursor.isAfter(end)) {
      dates.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return dates;
  }

  /// 날짜별 API 요청 객체 생성
  CalendarEventRequest _buildSingleRequest() {
    final startDate = _startDate!;
    final endDate = _endDate ?? _startDate!;
    final startDt = _isAllDay
        ? DateTime(startDate.year, startDate.month, startDate.day, 0, 0)
        : DateTime(startDate.year, startDate.month, startDate.day,
            _startTime?.hour ?? 0, _startTime?.minute ?? 0);
    final endDt = _isAllDay
        ? DateTime(endDate.year, endDate.month, endDate.day, 23, 59)
        : DateTime(endDate.year, endDate.month, endDate.day,
            _endTime?.hour ?? 0, _endTime?.minute ?? 0);
    return CalendarEventRequest(
      title: _titleController.text,
      description: _descriptionController.text,
      startDatetime: startDt,
      endDatetime: endDt,
      usedLeaveMinutes: _isLeaveEvent ? _calcTotalUsedMinutes() : 0,
      isAllDay: _isAllDay,
      isLeaveEvent: _isLeaveEvent,
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('등록 실패'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    if (_startDate == null) {
      AnalyticsService().logCalendarEventSubmitBlocked('no_date');
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('기간을 등록해주세요.'),
          content: const Text('달력에서 기간을 선택해주세요.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    // ── 연차 사용 사전 검증 ──────────────────────────────────────────────────
    if (_isLeaveEvent) {
      final dates = _selectedDates();

      // Condition 1: 선택 기간이 모두 비근로일/공휴일 → 제출 차단
      if (dates.every(_isNonWorkOrHoliday)) {
        AnalyticsService().logCalendarEventSubmitBlocked('all_holiday');
        await showCupertinoDialog<void>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('연차 사용 불가'),
            content: const Text('근무일이 아닌 경우 연차 사용이 불가합니다'),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(ctx),
                child: const Text('닫기'),
              ),
            ],
          ),
        );
        return;
      }

      // 근로일이지만 입력 시간이 근무시간과 전혀 겹치지 않는 경우 → 제출 차단
      if (!_isAllDay && _hasWorkDayWithNoOverlap(dates)) {
        AnalyticsService().logCalendarEventSubmitBlocked('no_work_overlap');
        await showCupertinoDialog<void>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('입력 오류'),
            content: const Text('연차를 사용할 근로시간을 확인해주세요'),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(ctx),
                child: const Text('닫기'),
              ),
            ],
          ),
        );
        return;
      }

      // 입력 시간이 모두 휴게시간 안에 포함 → 제출 차단
      if (!_isAllDay && _calcTotalUsedMinutes() == 0) {
        AnalyticsService().logCalendarEventSubmitBlocked('break_time_only');
        await showCupertinoDialog<void>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('입력 오류'),
            content: const Text('선택한 시간이 모두 휴게시간에 포함되어 있어 연차 사용이 불가합니다'),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(ctx),
                child: const Text('닫기'),
              ),
            ],
          ),
        );
        return;
      }

      // Condition 2: 이틀 이상 기간에 비근로일/공휴일이 하나라도 포함 → 안내 후 제출
      if (dates.length >= 2 && dates.any(_isNonWorkOrHoliday)) {
        final ok = await showCupertinoDialog<bool>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            content: const Text('비근로일/공휴일은 자동으로 연차 사용에서 제외됩니다'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('확인'),
              ),
            ],
          ),
        );
        if (ok != true || !mounted) return;
      }

      // Condition 3: 종일 아닌 경우 입력 시간이 근무시간 외 영역에 걸침 → 안내 후 제출
      if (!_isAllDay && _hasOutsideWorkHours(dates)) {
        final ok = await showCupertinoDialog<bool>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            content: const Text('비근무시간은 자동으로 연차 사용에서 제외됩니다'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('확인'),
              ),
            ],
          ),
        );
        if (ok != true || !mounted) return;
      }
    }

    setState(() => _isSubmitting = true);

    final editId = widget.editEvent?.id;
    AnalyticsService().logCalendarEventSubmitTapped(isEdit: editId != null);
    NetworkError? error;

    final request = _buildSingleRequest();

    if (editId != null) {
      // 수정 모드: 단건 PUT
      final result = await ref
          .read(updateCalendarEventUseCaseProvider)
          .execute(id: editId, request: request);
      if (result is Failure) {
        error = (result as Failure<void, NetworkError>).error;
      }
    } else {
      // 등록 모드: 단건 POST (기간형 포함)
      final result = await ref
          .read(createCalendarEventUseCaseProvider)
          .execute(request: request);
      if (result is Failure) {
        error = (result as Failure<void, NetworkError>).error;
      }
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error == null) {
      if (editId != null) {
        AnalyticsService().logCalendarEventUpdated();
      } else {
        AnalyticsService().logCalendarEventRegistered(
          isAllDay: _isAllDay,
          isRange: _endDate != null,
        );
      }
      ref.read(leaveDataRefreshProvider.notifier).state++;
      Navigator.pop(context);
      return;
    }

    final message = switch (error) {
      ServerError(:final message) => message,
      TimeoutError() => '요청 시간이 초과되었습니다.',
      UnauthorizedError() => '로그인이 필요합니다.',
      NetworkConnectionError() => '네트워크 연결을 확인해주세요.',
      _ => '일정 ${editId != null ? '수정' : '등록'}에 실패했습니다.',
    };
    if (editId != null) {
      AnalyticsService().logCalendarEventUpdateFailed(message);
    } else {
      AnalyticsService().logCalendarEventRegisterFailed(message);
    }
    _showErrorDialog(message);
  }

  // ── 빌드 ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    _buildLeaveEventCard(),
                    const SizedBox(height: 18),
                    _buildDatePickerCard(),
                    const SizedBox(height: 18),
                    _buildTimeCard(),
                    if (_isLeaveEvent) ...[
                      const SizedBox(height: 9),
                      _buildUsedTimeRow(),
                    ],
                    const SizedBox(height: 18),
                    _buildMemoCard(),
                    const SizedBox(height: 26),
                    _buildSubmitButton(),
                    if (widget.editEvent != null) ...[
                      const SizedBox(height: 12),
                      _buildDeleteButton(),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 헤더 ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return SizedBox(
      height: 63,
      child: Row(
        children: [
          // 뒤로 버튼 — 오른쪽 placeholder와 동일 너비로 제목 정확히 중앙 정렬
          SizedBox(
            width: 90,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () => Navigator.pop(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icons/ic_previous_black.png',
                      width: 9,
                      height: 18,
                      color: AppColors.brandColor,
                    ),
                    const SizedBox(width: 4),
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
          ),
          // 제목 — 남은 공간 가운데
          Expanded(
            child: Text(
              widget.editEvent != null ? '일정 수정' : '일정 등록',
              textAlign: TextAlign.center,
              style: pretendard(
                weight: 700,
                size: 20,
                color: AppColors.brandColor,
              ),
            ),
          ),
          // 오른쪽 여백 — 뒤로 버튼과 대칭
          const SizedBox(width: 90),
        ],
      ),
    );
  }

  // ── 공통 카드 셸 ─────────────────────────────────────────────────────────

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: child,
    );
  }

  // ── 공통 토글 ────────────────────────────────────────────────────────────

  Widget _buildToggle(bool isOn, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 30,
        decoration: BoxDecoration(
          color: isOn ? AppColors.brandLight : const Color(0xFFF1F1F1),
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(17),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isOn ? AppColors.brandColor : const Color(0xFF999999),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  // ── 연차 사용 여부 ────────────────────────────────────────────────────────

  Widget _buildLeaveEventCard() {
    return _buildCard(
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                '연차 사용 여부',
                style: pretendard(
                  weight: 700,
                  size: 20,
                  color: AppColors.textGray11,
                ),
              ),
              const Spacer(),
              _buildToggle(
                _isLeaveEvent,
                () {
                  setState(() => _isLeaveEvent = !_isLeaveEvent);
                  AnalyticsService().logCalendarEventLeaveTypeToggled(isLeaveEvent: _isLeaveEvent);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 휴가 신청일 (미니 캘린더) ─────────────────────────────────────────────

  Widget _buildDatePickerCard() {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '휴가 신청일',
              style: pretendard(
                weight: 700,
                size: 20,
                color: AppColors.textGray11,
              ),
            ),
            const SizedBox(height: 19),
            _buildMiniCalendar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCalendar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Column(
          children: [
            _buildCalendarHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildCalendarDayLabels(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: _buildCalendarGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              _calendarMonth = DateTime(
                _calendarMonth.year,
                _calendarMonth.month - 1,
                1,
              );
              _weeks = _buildWeeks(_calendarMonth);
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Image.asset(
                'assets/icons/ic_previous_black.png',
                width: 6,
                height: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${_calendarMonth.year}년 ${_calendarMonth.month}월',
              textAlign: TextAlign.center,
              style: pretendard(
                weight: 700,
                size: 15,
                color: AppColors.textGray11,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              _calendarMonth = DateTime(
                _calendarMonth.year,
                _calendarMonth.month + 1,
                1,
              );
              _weeks = _buildWeeks(_calendarMonth);
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Image.asset(
                'assets/icons/ic_next_black.png',
                width: 6,
                height: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDayLabels() {
    return Row(
      children: _dayLabels
          .map(
            (l) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  l,
                  textAlign: TextAlign.center,
                  style: pretendard(
                    weight: 600,
                    size: 15,
                    color: AppColors.textGray99,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    return Column(
      children: _weeks
          .map(
            (week) => Row(
              children: List.generate(
                7,
                (i) => Expanded(child: _buildCalendarCell(week[i], i)),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarCell(DateTime date, int colIdx) {
    final isCurrentMonth = date.month == _calendarMonth.month;
    final isStart = _startDate != null && _isSameDay(date, _startDate!);
    final isEnd = _endDate != null && _isSameDay(date, _endDate!);
    final isEndpoint = isStart || isEnd;

    // 범위 내 여부 (시작·끝 제외한 중간)
    final inRange =
        _startDate != null &&
        _endDate != null &&
        date.isAfter(_startDate!) &&
        date.isBefore(_endDate!);

    final isSunday = colIdx == 0;
    final isRedDay = isCurrentMonth && (isSunday || _isHolidayDate(date));

    Color textColor;
    if (isEndpoint) {
      textColor = Colors.white;
    } else if (!isCurrentMonth) {
      textColor = AppColors.textGray99;
    } else if (isRedDay) {
      textColor = const Color(0xFFD30000);
    } else {
      textColor = AppColors.textGray11;
    }

    // range 띠: 즉시 on/off (애니메이션 없음 — 사라질 때 깔끔)
    final hasRange = _endDate != null;
    final fillLeft = hasRange && (inRange || isEnd);
    final fillRight = hasRange && (inRange || isStart);

    return GestureDetector(
      onTap: isCurrentMonth ? () => _onDateTapped(date) : null,
      child: SizedBox(
        height: 37,
        child: Stack(
          children: [
            // 띠: 비-positioned Row → Stack의 full width를 자연스럽게 채움
            // vertical margin으로 수직 중앙 26px 확보
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: fillLeft ? AppColors.brandLight : null,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: fillRight ? AppColors.brandLight : null,
                  ),
                ),
              ],
            ),

            // 원 + 텍스트: 중앙 정렬
            Align(
              alignment: Alignment.center,
              child: isEndpoint
                  ? TweenAnimationBuilder<double>(
                      key: ValueKey('${date.toIso8601String()}-circle'),
                      tween: Tween(begin: 0.5, end: 1.0),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      builder: (_, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: AppColors.brandColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${date.day}',
                          style: pretendard(
                            weight: 600,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      '${date.day}',
                      textAlign: TextAlign.center,
                      style: pretendard(
                        weight: 600,
                        size: 15,
                        color: textColor,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 종일 + 시작일/종료일 ──────────────────────────────────────────────────

  Widget _buildTimeCard() {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '종일',
                  style: pretendard(
                    weight: 700,
                    size: 16,
                    color: AppColors.textGray11,
                  ),
                ),
                const Spacer(),
                _buildToggle(
                  _isAllDay,
                  () {
                    setState(() {
                      _isAllDay = !_isAllDay;
                      if (_isAllDay) {
                        _startTime = null;
                        _endTime = null;
                      }
                    });
                    AnalyticsService().logCalendarEventAllDayToggled(isAllDay: _isAllDay);
                  },
                ),
              ],
            ),
            if (!_isAllDay) ...[
              const SizedBox(height: 9),
              Container(height: 1, color: AppColors.border),
              const SizedBox(height: 9),
              _buildDateTimeRow(label: '시작일', isStart: true),
              const SizedBox(height: 9),
              Container(height: 1, color: AppColors.border),
              const SizedBox(height: 9),
              _buildDateTimeRow(label: '종료일', isStart: false),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeRow({required String label, required bool isStart}) {
    final time = isStart ? _startTime : _endTime;
    final date = isStart ? _startDate : (_endDate ?? _startDate);
    final hasDate = date != null;
    final hasTime = time != null;

    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: pretendard(
              weight: 700,
              size: 16,
              color: AppColors.textGray11,
            ),
          ),
        ),
        const Spacer(),
        // 날짜 pill (캘린더에서 선택된 날짜 표시)
        Container(
          width: 80,
          height: 28,
          decoration: BoxDecoration(
            color: hasDate ? AppColors.brandLight : const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            hasDate ? _formatDatePill(date) : '날짜 미선택',
            style: pretendard(
              weight: 700,
              size: 10,
              color: hasDate ? AppColors.textGray11 : AppColors.textGray99,
            ),
          ),
        ),
        const SizedBox(width: 7),
        // 시간 pill (탭하면 시간 선택 모달)
        GestureDetector(
          onTap: () async {
            final picked = await _showTimePicker(time);
            if (picked != null && mounted) {
              setState(() {
                if (isStart) {
                  _startTime = picked;
                } else {
                  _endTime = picked;
                }
              });
              AnalyticsService().logCalendarEventTimeSet(isStart ? 'start' : 'end');
            }
          },
          child: Container(
            width: 80,
            height: 28,
            decoration: BoxDecoration(
              color: hasTime ? AppColors.brandLight : const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              hasTime ? _formatTimePill(time) : '오전 00시00분',
              style: pretendard(
                weight: 700,
                size: 10,
                color: hasTime ? AppColors.textGray11 : AppColors.textGray99,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 사용시간 ─────────────────────────────────────────────────────────────

  Widget _buildUsedTimeRow() {
    final hasCalcTime = _isAllDay || (_startTime != null && _endTime != null);

    return _buildCard(
      child: SizedBox(
        height: 46,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                '사용시간',
                style: pretendard(
                  weight: 700,
                  size: 16,
                  color: AppColors.textGray11,
                ),
              ),
              const Spacer(),
              Text(
                _formatMinutes(_calcTotalUsedMinutes()),
                style: pretendard(
                  weight: 700,
                  size: 14,
                  color: hasCalcTime
                      ? AppColors.brandColor
                      : AppColors.textGray99,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 메모 ─────────────────────────────────────────────────────────────────

  Widget _buildMemoCard() {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '메모',
              style: pretendard(
                weight: 700,
                size: 20,
                color: AppColors.textGray11,
              ),
            ),
            const SizedBox(height: 17),
            Text(
              '제목',
              style: pretendard(
                weight: 700,
                size: 14,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 5),
            _buildTextField(
              controller: _titleController,
              height: 41,
              hint: '메모 제목을 입력해주세요.',
              maxLines: 1,
            ),
            const SizedBox(height: 14),
            Text(
              '내용',
              style: pretendard(
                weight: 700,
                size: 14,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 5),
            _buildTextField(
              controller: _descriptionController,
              height: 144,
              hint: '메모 내용을 입력해주세요.',
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required double height,
    required String hint,
    int? maxLines,
  }) {
    final isSingleLine = maxLines == 1;

    return Container(
      height: height,
      alignment: isSingleLine ? Alignment.center : Alignment.topLeft,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 13,
        vertical: isSingleLine ? 0 : 12,
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        expands: !isSingleLine,
        textAlignVertical: isSingleLine
            ? TextAlignVertical.center
            : TextAlignVertical.top,
        style: pretendard(weight: 400, size: 14, color: AppColors.textGray11),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintText: hint,
          hintStyle: pretendard(
            weight: 400,
            size: 14,
            color: AppColors.textGray99,
          ),
        ),
      ),
    );
  }

  // ── 삭제하기 (수정 모드 전용) ─────────────────────────────────────────────

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _confirmDelete,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF5252),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(
            0xFFFF5252,
          ).withValues(alpha: 0.5),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          '삭제하기',
          style: pretendard(weight: 700, size: 15, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final id = widget.editEvent?.id;
    if (id == null) return;
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제하시겠습니까?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await ref
        .read(deleteCalendarEventUseCaseProvider)
        .execute(id: id);
    if (!mounted) return;
    if (result case Success()) {
      ref.read(leaveDataRefreshProvider.notifier).state++;
      Navigator.pop(context);
    }
  }

  // ── 등록하기 ──────────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.brandColor.withValues(alpha: 0.5),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
