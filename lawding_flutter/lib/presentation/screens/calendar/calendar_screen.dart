import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../domain/core/result.dart';
import '../../../domain/entities/calendar_event.dart';
import '../../../domain/entities/user_me.dart';
import '../../../infrastructure/services/analytics_service.dart';
import '../../core/design_system.dart';
import '../../providers/providers.dart';
import '../../widgets/common/custom_scaffold.dart';
import '../../widgets/common/logo_app_bar.dart';
import 'add_calendar_event_screen.dart';
import 'leave_time_edit_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 데이터 모델 — 추후 VM / Repository 레이어로 이동
// ─────────────────────────────────────────────────────────────────────────────

class CalendarHoliday {
  final DateTime date;
  final String name;
  const CalendarHoliday(this.date, this.name);
}

enum CalendarEventType {
  holiday(Color(0xFFF16767)), // 공휴일 / 대체 휴일
  annualLeave(Color(0xFF0057B8)), // 연차
  otherLeave(Color(0xFFE1E1E1)); // 연차가 아닌 일정

  const CalendarEventType(this.color);
  final Color color;
}

class CalendarEvent {
  final int? id; // 공휴일은 null
  final DateTime date; // = startDatetime
  final DateTime endDatetime; // 단일 이벤트는 같은 날, 기간 이벤트는 마지막 날 포함
  final CalendarEventType type;
  final String label; // 셀 배지: 공휴일명 또는 "HH:MM-HH:MM" 또는 "종일"
  final String name; // 카드 제목 (비공휴일), 미입력 시 label 표시
  final String detail; // 카드 하단 메모 (isFocused 확장 카드)
  const CalendarEvent({
    this.id,
    required this.date,
    required this.endDatetime,
    required this.type,
    required this.label,
    this.name = '',
    this.detail = '',
  });
}

final List<CalendarHoliday> _mockHolidays = [];

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const _dayLabels = ['일', '월', '화', '수', '목', '금', '토'];
  static const _initialPage = 1200;

  late final PageController _pageController;
  DateTime? _focusedDate; // 앱 실행 시 null, 터치 시 설정
  late DateTime _displayedMonth;
  late final DateTime _today;

  // API 응답으로 교체됨. 실패 시 mock 유지
  List<CalendarHoliday> _holidays = _mockHolidays;
  List<CalendarEvent> _events = [];
  UserMe? _userMe;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _focusedDate = null;
    _displayedMonth = DateTime(now.year, now.month, 1);
    _pageController = PageController(initialPage: _initialPage);
    _fetchHolidays();
    _fetchUserMe();
    _fetchCalendarEvents(_displayedMonth.year, _displayedMonth.month);
    AnalyticsService().logCalendarScreenViewed();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatDays(double days) => days.toStringAsFixed(3);

  Future<void> _fetchUserMe() async {
    final result = await ref.read(getUserMeUseCaseProvider).execute();
    switch (result) {
      case Success(:final value):
        if (!mounted) return;
        setState(() => _userMe = value);
      case Failure(:final error):
        debugPrint('[UserMe] 실패: $error');
    }
  }

  Future<void> _fetchHolidays() async {
    final currentYear = _today.year;
    final result = await ref
        .read(getHolidaysUseCaseProvider)
        .execute(startYear: currentYear - 1, endYear: currentYear + 2);
    switch (result) {
      case Success(:final value):
        debugPrint(
          '[Holiday API] 수신: ${value.length}건 ${value.map((h) => '${h.date.toIso8601String().substring(0, 10)} ${h.name}').toList()}',
        );
        if (!mounted) return;
        setState(() {
          _holidays = value
              .map((h) => CalendarHoliday(h.date, h.name))
              .toList();
        });
      case Failure(:final error):
        debugPrint('[Holiday API] 실패: $error');
    }
  }

  Future<void> _fetchCalendarEvents(int year, int month) async {
    final result = await ref
        .read(getCalendarEventsUseCaseProvider)
        .execute(year: year, month: month);
    switch (result) {
      case Success(:final value):
        if (!mounted) return;
        setState(() {
          _events = value.map(_toCalendarEvent).toList();
        });
      case Failure(:final error):
        debugPrint('[CalendarEvents] 실패: $error');
    }
  }

  CalendarEvent _toCalendarEvent(CalendarEventEntity entity) {
    final type = entity.isLeaveEvent
        ? CalendarEventType.annualLeave
        : CalendarEventType.otherLeave;

    final String label;
    if (entity.isAllDay) {
      label = '종일';
    } else {
      final sh = entity.startDatetime.hour.toString().padLeft(2, '0');
      final sm = entity.startDatetime.minute.toString().padLeft(2, '0');
      final eh = entity.endDatetime.hour.toString().padLeft(2, '0');
      final em = entity.endDatetime.minute.toString().padLeft(2, '0');
      label = '$sh:$sm-$eh:$em';
    }

    return CalendarEvent(
      id: entity.id,
      date: entity.startDatetime,
      endDatetime: entity.endDatetime,
      type: type,
      label: label,
      name: entity.title,
      detail: entity.description,
    );
  }

  DateTime _monthFromPage(int page) {
    final today = DateTime.now();
    final monthOffset = page - _initialPage;
    final totalMonths = today.year * 12 + (today.month - 1) + monthOffset;
    return DateTime(totalMonths ~/ 12, totalMonths % 12 + 1, 1);
  }

  void _goToPreviousMonth() {
    AnalyticsService().logCalendarMonthChanged('prev');
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextMonth() {
    AnalyticsService().logCalendarMonthChanged('next');
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// 해당 월의 주 목록 생성 (null = 빈 셀)
  /// 대한민국 표준 달력 기준: 일요일 시작
  List<List<DateTime?>> _buildWeeksForMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Dart weekday: 1=월 ~ 7=일 → 일=0 기준: weekday % 7
    final startWeekday = firstDay.weekday % 7;

    final weeks = <List<DateTime?>>[];
    var week = <DateTime?>[];

    for (int i = 0; i < startWeekday; i++) {
      week.add(null);
    }

    for (int day = 1; day <= daysInMonth; day++) {
      week.add(DateTime(month.year, month.month, day));
      if (week.length == 7) {
        weeks.add(week);
        week = [];
      }
    }

    if (week.isNotEmpty) {
      while (week.length < 7) {
        week.add(null);
      }
      weeks.add(week);
    }

    return weeks;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isHoliday(DateTime date) =>
      _holidays.any((h) => _isSameDay(h.date, date));

  /// 정렬 기준: holiday → annualLeave → otherLeave, 동일 타입은 시간 순 (종일 먼저)
  /// "대체공휴일(부처님 오신날)" → ('대체공휴일', '부처님 오신날')
  /// 괄호 없으면 → ('대체공휴일', '')
  (String label, String detail) _parseHolidayName(String name) {
    final parenStart = name.indexOf('(');
    final parenEnd = name.indexOf(')');
    if (parenStart != -1 && parenEnd > parenStart) {
      final label = name.substring(0, parenStart).trim();
      final detail = name.substring(parenStart + 1, parenEnd).trim();
      return (label, detail);
    }
    return (name, '');
  }

  List<CalendarEvent> _eventsForDate(DateTime date) {
    // 공휴일은 _holidays에서 파생 (API 데이터 반영)
    final holidayEvents = _holidays.where((h) => _isSameDay(h.date, date)).map((
      h,
    ) {
      final (label, detail) = _parseHolidayName(h.name);
      return CalendarEvent(
        date: date,
        endDatetime: date,
        type: CalendarEventType.holiday,
        label: label,
        name: label,
        detail: detail,
      );
    }).toList();
    final otherEvents = _events
        .where(
          (e) =>
              e.type != CalendarEventType.holiday &&
              !date.isBefore(DateTime(e.date.year, e.date.month, e.date.day)) &&
              !date.isAfter(
                DateTime(
                  e.endDatetime.year,
                  e.endDatetime.month,
                  e.endDatetime.day,
                ),
              ),
        )
        .toList();

    final list = [...holidayEvents, ...otherEvents];
    const typeOrder = [
      CalendarEventType.holiday,
      CalendarEventType.annualLeave,
      CalendarEventType.otherLeave,
    ];
    list.sort((a, b) {
      final ti = typeOrder.indexOf(a.type);
      final tj = typeOrder.indexOf(b.type);
      if (ti != tj) return ti.compareTo(tj);
      return _labelSortKey(a.label).compareTo(_labelSortKey(b.label));
    });
    return list;
  }

  /// 종일 = 0분(최우선), HH:MM-HH:MM = 시작 시간(분)으로 변환
  int _labelSortKey(String label) {
    if (label == '종일') return -1;
    final start = label.split('-').first.split(':');
    if (start.length != 2) return 0;
    return (int.tryParse(start[0]) ?? 0) * 60 + (int.tryParse(start[1]) ?? 0);
  }

  /// 기기 shortestSide 기준 셀 높이 (가로/세로 모드 모두 일관된 크기)
  double _cellHeight(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    if (shortestSide < 360) return 52.0;
    if (shortestSide < 400) return 58.0;
    if (shortestSide < 600) return 65.0;
    return 90.0; // 태블릿
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(leaveDataRefreshProvider, (prev, next) {
      if (prev != null && prev != next) {
        _fetchCalendarEvents(_displayedMonth.year, _displayedMonth.month);
        _fetchUserMe();
      }
    });
    return CustomScaffold(
      backgroundColor: AppColors.background,
      appBar: const LogoAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildLeaveCard(),
            ),
            const SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCalendarCard(context),
            ),
            const SizedBox(height: 12),
            _buildMonthEventList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveCard() {
    final balance = _userMe?.leaveBalance;
    return Container(
      height: 83,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Stack(
        children: [
          // 닉네임 + 남은 연차 라벨 (5px 간격, baseline 정렬)
          Positioned(
            top: 10,
            left: 17,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${_userMe?.user.nickname ?? ''}님',
                  style: pretendard(
                    weight: 700,
                    size: 20,
                    color: AppColors.brandColor,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '남은 연차',
                  style: pretendard(
                    weight: 700,
                    size: 13,
                    color: AppColors.brandColor,
                  ),
                ),
              ],
            ),
          ),
          // 회색 pill — 텍스트 너비에 맞게 자동 크기
          Positioned(
            top: 39,
            left: 10,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(17),
              ),
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    balance == null
                        ? ''
                        : '${_formatDays(balance.remainingLeaveDays)}일',
                    style: pretendard(
                      weight: 700,
                      size: 20,
                      color: AppColors.textGray11,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    balance == null
                        ? ''
                        : '${balance.remainingLeaveHours.toStringAsFixed(2)}시간',
                    style: pretendard(
                      weight: 700,
                      size: 13,
                      color: AppColors.textGray55,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 41,
            left: 164,
            child: CupertinoButton(
              padding: const EdgeInsets.all(8),
              minimumSize: Size.zero,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaveTimeEditScreen()),
              ),
              child: SvgPicture.asset(
                'assets/icons/calendar_timeEdit.svg',
                width: 14,
                height: 14,
              ),
            ),
          ),
          // 연차 추가 버튼 — SVG에 원 배경 포함
          Positioned.fill(
            right: 19,
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () async {
                  AnalyticsService().logCalendarAddEventTapped();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddCalendarEventScreen(),
                    ),
                  );
                  if (mounted) {
                    _fetchCalendarEvents(
                      _displayedMonth.year,
                      _displayedMonth.month,
                    );
                    _fetchUserMe();
                  }
                },
                child: SvgPicture.asset(
                  'assets/icons/calendar_add.svg',
                  width: 69,
                  height: 69,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    final cellHeight = _cellHeight(context);
    final weeksCount = _buildWeeksForMonth(_displayedMonth).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          _buildMonthHeader(),
          _buildDayLabels(),
          Container(height: 0.5, color: const Color(0xFFE1E1E1)),
          // AnimatedContainer: 주 수(4/5/6) 변화 시 부드럽게 높이 전환
          ClipRect(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: cellHeight * weeksCount + (weeksCount - 1) * 0.5,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  final newMonth = _monthFromPage(page);
                  setState(() => _displayedMonth = newMonth);
                  _fetchCalendarEvents(newMonth.year, newMonth.month);
                },
                itemBuilder: (context, page) {
                  return OverflowBox(
                    alignment: Alignment.topCenter,
                    maxHeight: double.infinity,
                    child: _buildMonthGrid(_monthFromPage(page), cellHeight),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return SizedBox(
      height: 70,
      child: Row(
        children: [
          GestureDetector(
            onTap: _goToPreviousMonth,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 8, 8, 8),
              child: Image.asset(
                'assets/icons/ic_previous_black.png',
                width: 6,
                height: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${_displayedMonth.year}년 ${_displayedMonth.month}월',
              textAlign: TextAlign.center,
              style: pretendard(
                weight: 600,
                size: 17,
                color: AppColors.textGray11,
              ),
            ),
          ),
          GestureDetector(
            onTap: _goToNextMonth,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 13, 8),
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

  Widget _buildDayLabels() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 3),
      child: Row(
        children: _dayLabels
            .map(
              (label) => Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: pretendard(
                    weight: 400,
                    size: 12,
                    color: AppColors.textGray11,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMonthGrid(DateTime month, double cellHeight) {
    final weeks = _buildWeeksForMonth(month);
    final rows = <Widget>[];

    for (int i = 0; i < weeks.length; i++) {
      rows.add(_buildWeekRow(weeks[i], cellHeight));
      if (i < weeks.length - 1) {
        rows.add(Container(height: 0.5, color: const Color(0xFFE1E1E1)));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _buildWeekRow(List<DateTime?> days, double cellHeight) {
    return Row(
      children: List.generate(7, (colIdx) {
        return Expanded(child: _buildDayCell(days[colIdx], colIdx, cellHeight));
      }),
    );
  }

  Widget _buildDayCell(DateTime? date, int colIdx, double cellHeight) {
    if (date == null) return SizedBox(height: cellHeight);

    final isFocused = _focusedDate != null && _isSameDay(date, _focusedDate!);
    final isToday = _isSameDay(date, _today);
    final isSunday = colIdx == 0;
    final isRedDay = isSunday || _isHoliday(date);

    return GestureDetector(
      onTap: () {
        final isUnfocus = _focusedDate != null && _isSameDay(_focusedDate!, date);
        if (isUnfocus) {
          AnalyticsService().logCalendarDateUnfocused();
        } else {
          AnalyticsService().logCalendarDateTapped();
        }
        setState(() {
          _focusedDate = isUnfocus ? null : date;
        });
      },
      onDoubleTap: () {
        // 추후 이벤트 추가
      },
      child: Container(
        height: cellHeight - 2,
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: isFocused ? AppColors.brandLight : Colors.transparent,
          border: Border.all(
            color: isFocused ? AppColors.brandColor : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 6,
              child: isToday
                  ? Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.brandColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            Text(
              '${date.day}',
              textAlign: TextAlign.center,
              style: pretendard(
                weight: 400,
                size: 12,
                color: isRedDay
                    ? const Color(0xFFD30000)
                    : AppColors.textGray11,
              ),
            ),
            const SizedBox(height: 2),
            ..._buildCellBars(date),
            const Spacer(),
            _buildHolidayLabel(date),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCellBars(DateTime date) {
    final events = _eventsForDate(date).take(3).toList();
    return events
        .map(
          (event) => Container(
            margin: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
            height: 3,
            decoration: BoxDecoration(
              color: event.type.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )
        .toList();
  }

  Widget _buildHolidayLabel(DateTime date) {
    final holiday = _eventsForDate(
      date,
    ).where((e) => e.type == CalendarEventType.holiday).firstOrNull;
    if (holiday == null) return const SizedBox.shrink();
    return Text(
      holiday.label,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: pretendard(size: 7, weight: 600, color: const Color(0xFFD30000)),
    );
  }

  // ── 이벤트 목록 ─────────────────────────────────────────────────────────────

  Widget _buildMonthEventList() => _focusedDate == null
      ? _buildUpcomingEventList()
      : _buildFocusedEventList();

  /// isFocused=false: 오늘~14일 이벤트, 날짜별 최대 3개
  Widget _buildUpcomingEventList() {
    final end = _today.add(const Duration(days: 14));

    // holidays + events 통합 후 날짜별 그룹핑
    final Map<DateTime, List<CalendarEvent>> grouped = {};

    for (final h in _holidays) {
      final d = DateTime(h.date.year, h.date.month, h.date.day);
      if (!d.isBefore(_today) && d.isBefore(end)) {
        final (label, detail) = _parseHolidayName(h.name);
        grouped
            .putIfAbsent(d, () => [])
            .add(
              CalendarEvent(
                date: d,
                endDatetime: d,
                type: CalendarEventType.holiday,
                label: label,
                name: label,
                detail: detail,
              ),
            );
      }
    }

    for (final e in _events) {
      final eStart = DateTime(e.date.year, e.date.month, e.date.day);
      final eEnd = DateTime(
        e.endDatetime.year,
        e.endDatetime.month,
        e.endDatetime.day,
      );
      // 이벤트 기간이 오늘~14일 윈도우와 겹치면 포함
      if (eEnd.isBefore(_today) || !eStart.isBefore(end)) continue;
      // 진행 중인 이벤트(시작일 < 오늘)는 오늘 날짜 그룹에 표시
      final d = eStart.isBefore(_today) ? _today : eStart;
      grouped.putIfAbsent(d, () => []).add(e);
    }

    // 날짜별로 정렬(type→time)하여 최대 3개씩 취합
    const typeOrder = [
      CalendarEventType.holiday,
      CalendarEventType.annualLeave,
      CalendarEventType.otherLeave,
    ];
    final List<CalendarEvent> limited = [];
    for (final date in grouped.keys.toList()..sort()) {
      final sorted = grouped[date]!
        ..sort((a, b) {
          final ti = typeOrder.indexOf(a.type);
          final tj = typeOrder.indexOf(b.type);
          if (ti != tj) return ti.compareTo(tj);
          return _labelSortKey(a.label).compareTo(_labelSortKey(b.label));
        });
      limited.addAll(sorted.take(3));
    }

    if (limited.isEmpty) return const SizedBox(height: 100);

    return _buildEventListWidget(limited, expanded: false);
  }

  /// isFocused=true: 선택 날짜 이벤트 전부, 확장 카드
  Widget _buildFocusedEventList() {
    final events = _eventsForDate(_focusedDate!);
    if (events.isEmpty) return const SizedBox(height: 100);
    return _buildEventListWidget(events, expanded: true);
  }

  /// 이벤트 리스트를 날짜 헤더 + 카드로 렌더링
  Widget _buildEventListWidget(
    List<CalendarEvent> events, {
    required bool expanded,
  }) {
    final Map<DateTime, List<CalendarEvent>> grouped = {};
    for (final e in events) {
      final key = DateTime(e.date.year, e.date.month, e.date.day);
      grouped.putIfAbsent(key, () => []).add(e);
    }
    final sortedDates = grouped.keys.toList()..sort();

    final widgets = <Widget>[];
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final dateEvents = grouped[date]!;
      if (i > 0) widgets.add(const SizedBox(height: 12));
      widgets.add(_buildDateHeader(date, dateEvents));
      for (final event in dateEvents) {
        widgets.add(const SizedBox(height: 6));
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: expanded
                ? _buildExpandedEventCard(event)
                : _buildEventCard(event),
          ),
        );
      }
    }
    widgets.add(const SizedBox(height: 100));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildDateHeader(DateTime date, List<CalendarEvent> events) {
    final nonHolidays = events
        .where((e) => e.type != CalendarEventType.holiday)
        .toList();

    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[date.weekday % 7];

    final String dateText;
    if (nonHolidays.isEmpty) {
      dateText = '${date.month}월 ${date.day}일';
    } else {
      dateText = '${date.month}월 ${date.day}일($weekday)';
    }

    // 연차 시간 계산
    final annualLeaveMinutes = _annualLeaveMinutes(events);
    final String? annualLeaveText;
    if (annualLeaveMinutes > 0) {
      final h = annualLeaveMinutes ~/ 60;
      final m = annualLeaveMinutes % 60;
      annualLeaveText = m == 0 ? '$h시간' : '$h시간 $m분';
    } else {
      annualLeaveText = null;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        children: [
          Text(
            dateText,
            style: pretendard(
              weight: 700,
              size: 14,
              color: AppColors.textGray11,
            ),
          ),
          if (annualLeaveText != null) ...[
            const SizedBox(width: 6),
            Text(
              annualLeaveText,
              textAlign: TextAlign.center,
              style: pretendard(
                weight: 700,
                size: 14,
                color: AppColors.brandColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 연차 이벤트의 총 분 합산. 종일이 있으면 -1 반환.
  int _annualLeaveMinutes(List<CalendarEvent> events) {
    final annuals = events
        .where((e) => e.type == CalendarEventType.annualLeave)
        .toList();
    if (annuals.isEmpty) return 0;
    int total = 0;
    for (final e in annuals) {
      total += _minutesFromLabel(e.label);
    }
    return total;
  }

  int _minutesFromLabel(String label) {
    final parts = label.split('-');
    if (parts.length != 2) return 0;
    final s = parts[0].split(':');
    final e = parts[1].split(':');
    if (s.length != 2 || e.length != 2) return 0;
    final start = (int.tryParse(s[0]) ?? 0) * 60 + (int.tryParse(s[1]) ?? 0);
    final end = (int.tryParse(e[0]) ?? 0) * 60 + (int.tryParse(e[1]) ?? 0);
    return (end - start).clamp(0, 1440);
  }

  Widget _buildAnnualLeaveBadge(String label) {
    final minutes = _minutesFromLabel(label);
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final String text = m == 0 ? '연차($h시간)' : '연차($h시간 $m분)';
    return Container(
      height: 14,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.brandLight,
        borderRadius: BorderRadius.circular(7),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: pretendard(weight: 700, size: 8, color: AppColors.brandColor),
      ),
    );
  }

  /// isFocused=false: 비공휴일은 name(상단) / label(하단) 순서
  Widget _buildEventCard(CalendarEvent event) {
    final isHoliday = event.type == CalendarEventType.holiday;
    final topText = isHoliday
        ? event.label
        : (event.name.isNotEmpty ? event.name : event.label);
    final bottomText = isHoliday
        ? null
        : (event.name.isNotEmpty ? event.label : null);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Container(
          color: Colors.white,
          child: Row(
            children: [
              Container(width: 7, color: event.type.color),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      topText,
                      style: pretendard(
                        weight: 600,
                        size: 14,
                        color: AppColors.textGray11,
                      ),
                    ),
                    if (bottomText != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        bottomText,
                        style: pretendard(
                          weight: 600,
                          size: 11,
                          color: AppColors.textGray55,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (event.type == CalendarEventType.annualLeave) ...[
                _buildAnnualLeaveBadge(event.label),
                const SizedBox(width: 13),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// isFocused=true: 내용에 따라 높이가 변하는 확장 카드
  Future<void> _showEventOptions(CalendarEvent event) async {
    final eventType = event.type == CalendarEventType.annualLeave
        ? 'annual_leave'
        : 'other_leave';
    AnalyticsService().logCalendarEventOptionsOpened(eventType);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              AnalyticsService().logCalendarEventEditTapped(eventType);
              final entity = CalendarEventEntity(
                id: event.id!,
                title: event.name,
                description: event.detail,
                startDatetime: event.date,
                endDatetime: event.endDatetime,
                usedLeaveMinutes: 0,
                isAllDay: event.label == '종일',
                isLeaveEvent: event.type == CalendarEventType.annualLeave,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddCalendarEventScreen(editEvent: entity),
                ),
              ).then((_) {
                if (mounted) {
                  _fetchCalendarEvents(
                    _displayedMonth.year,
                    _displayedMonth.month,
                  );
                  _fetchUserMe();
                }
              });
            },
            child: const Text('수정하기'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              showCupertinoDialog<void>(
                context: context,
                builder: (dialogCtx) => CupertinoAlertDialog(
                  title: const Text('일정 삭제'),
                  content: const Text('이 일정을 삭제하시겠습니까?'),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: const Text('취소'),
                    ),
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () {
                        Navigator.pop(dialogCtx);
                        AnalyticsService().logCalendarEventDeleteConfirmed(eventType);
                        _deleteEvent(event);
                      },
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('삭제하기'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('취소'),
        ),
      ),
    );
  }

  Future<void> _deleteEvent(CalendarEvent event) async {
    final id = event.id;
    if (id == null) return;
    final eventType = event.type == CalendarEventType.annualLeave
        ? 'annual_leave'
        : 'other_leave';
    final result = await ref
        .read(deleteCalendarEventUseCaseProvider)
        .execute(id: id);
    if (!mounted) return;
    if (result case Success()) {
      AnalyticsService().logCalendarEventDeleted(eventType);
      _fetchCalendarEvents(_displayedMonth.year, _displayedMonth.month);
      _fetchUserMe();
    } else if (result case Failure(:final error)) {
      AnalyticsService().logCalendarEventDeleteFailed(error.toString());
    }
  }

  Widget _buildExpandedEventCard(CalendarEvent event) {
    final isHoliday = event.type == CalendarEventType.holiday;
    final hasDetail = event.detail.isNotEmpty;
    // 공휴일이고 detail 없음 → title만 존재 → unfocused와 동일한 44px
    final titleOnly = isHoliday && !hasDetail;

    final cardContent = Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 7, color: event.type.color),
          const SizedBox(width: 13),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: titleOnly ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: titleOnly
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    isHoliday
                        ? event.label
                        : (event.name.isNotEmpty ? event.name : event.label),
                    style: pretendard(
                      weight: 600,
                      size: 14,
                      color: AppColors.textGray11,
                    ),
                  ),
                  // 시간 (비공휴일)
                  if (!isHoliday) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.label,
                      style: pretendard(
                        weight: 600,
                        size: 13,
                        color: AppColors.textGray55,
                      ),
                    ),
                  ],
                  // 메모
                  if (hasDetail) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.detail,
                      style: pretendard(
                        weight: 600,
                        size: 10,
                        color: AppColors.textGray55,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // 우측: 3dot(상단) + 연차 뱃지(중앙)
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isHoliday)
                  GestureDetector(
                    onTap: () => _showEventOptions(event),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: List.generate(
                          3,
                          (i) => Container(
                            width: 4,
                            height: 4,
                            margin: EdgeInsets.only(left: i == 0 ? 0 : 3),
                            decoration: const BoxDecoration(
                              color: AppColors.textGray99,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (event.type == CalendarEventType.annualLeave) ...[
                  const Spacer(),
                  _buildAnnualLeaveBadge(event.label),
                  const Spacer(),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: titleOnly
            ? SizedBox(height: 44, child: cardContent)
            : IntrinsicHeight(child: cardContent),
      ),
    );
  }
}
