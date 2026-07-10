import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/calendar_event/calendar_event_request.dart';
import '../../../data/network/network_error.dart';
import '../../../domain/core/result.dart';
import '../../../domain/entities/holiday.dart';
import '../../core/design_system.dart';
import '../../providers/providers.dart';

class AddCalendarEventScreen extends ConsumerStatefulWidget {
  const AddCalendarEventScreen({super.key});

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
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<Holiday> _holidays = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _calendarMonth = DateTime(now.year, now.month, 1);
    _fetchHolidays();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchHolidays() async {
    final repo = ref.read(holidayRepositoryProvider);
    final year = _calendarMonth.year;
    final result = await repo.getHolidays(
      startYear: year - 1,
      endYear: year + 2,
    );
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

  String _calcUsedTime() {
    if (_startTime == null || _endTime == null) return '00시간00분';
    final s = _startTime!.hour * 60 + _startTime!.minute;
    final e = _endTime!.hour * 60 + _endTime!.minute;
    final diff = (e - s).clamp(0, 24 * 60);
    final h = diff ~/ 60;
    final m = diff % 60;
    return '${h.toString().padLeft(2, '0')}시간${m.toString().padLeft(2, '0')}분';
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}시간${m.toString().padLeft(2, '0')}분';
  }

  int _calcUsedMinutes() {
    if (_isAllDay) return ref.read(dailyWorkMinutesProvider);
    if (_startTime == null || _endTime == null) return 0;
    final s = _startTime!.hour * 60 + _startTime!.minute;
    final e = _endTime!.hour * 60 + _endTime!.minute;
    return (e - s).clamp(0, 24 * 60);
  }

  Future<TimeOfDay?> _showTimePicker(TimeOfDay? initial) async {
    TimeOfDay picked = initial ?? const TimeOfDay(hour: 9, minute: 0);
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
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    if (_startDate == null) {
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

    setState(() => _isSubmitting = true);

    // 선택된 기간의 모든 날짜를 구함
    final startDate = _startDate!;
    final endDate = _endDate ?? startDate;
    final dates = <DateTime>[];
    var cursor = startDate;
    while (!cursor.isAfter(endDate)) {
      dates.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }

    // 날짜별로 각각 1건씩 요청 생성
    final title = _titleController.text.isEmpty ? null : _titleController.text;
    final description = _descriptionController.text.isEmpty
        ? null
        : _descriptionController.text;
    final usedLeaveMinutes = _isLeaveEvent ? _calcUsedMinutes() : null;

    final requests = dates.map((date) {
      final startDt = _isAllDay
          ? DateTime(date.year, date.month, date.day, 0, 0)
          : DateTime(
              date.year,
              date.month,
              date.day,
              _startTime?.hour ?? 0,
              _startTime?.minute ?? 0,
            );
      final endDt = _isAllDay
          ? DateTime(date.year, date.month, date.day, 23, 59)
          : DateTime(
              date.year,
              date.month,
              date.day,
              _endTime?.hour ?? 0,
              _endTime?.minute ?? 0,
            );
      return CalendarEventRequest(
        title: title,
        description: description,
        startDatetime: startDt,
        endDatetime: endDt,
        usedLeaveMinutes: usedLeaveMinutes,
        isAllDay: _isAllDay,
        isLeaveEvent: _isLeaveEvent,
      );
    }).toList();

    final useCase = ref.read(createCalendarEventUseCaseProvider);
    final results = await Future.wait(
      requests.map((r) => useCase.execute(request: r)),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final failure = results
        .whereType<Failure<void, NetworkError>>()
        .firstOrNull;

    if (failure == null) {
      Navigator.pop(context);
      return;
    }

    final message = switch (failure.error) {
      ServerError(:final message) => message,
      TimeoutError() => '요청 시간이 초과되었습니다.',
      UnauthorizedError() => '로그인이 필요합니다.',
      NetworkConnectionError() => '네트워크 연결을 확인해주세요.',
      _ => '일정 등록에 실패했습니다.',
    };
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
              '일정 등록',
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
                () => setState(() => _isLeaveEvent = !_isLeaveEvent),
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
    final weeks = _buildWeeks(_calendarMonth);
    return Column(
      children: weeks
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
                  () => setState(() {
                    _isAllDay = !_isAllDay;
                    if (_isAllDay) {
                      _startTime = null;
                      _endTime = null;
                    }
                  }),
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
                _isAllDay
                    ? _formatMinutes(ref.read(dailyWorkMinutesProvider))
                    : _calcUsedTime(),
                style: pretendard(
                  weight: 700,
                  size: 14,
                  color: hasCalcTime
                      ? AppColors.textGray11
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
