import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../data/network/network_error.dart';
import '../../domain/core/result.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/holiday.dart';
import '../../domain/usecases/get_calendar_events_usecase.dart';
import '../../domain/usecases/get_holidays_usecase.dart';
import 'widget_service.dart';

/// 4×4 캘린더 위젯에 이번 달·다음 달의 공휴일/일정 원본을 저장한다.
/// 그리드와 "오늘 이후 일정"은 네이티브가 그리는 시점에 계산하므로 자정·월 변경에도 정확하다.
class CalendarWidgetSync {
  static const dataKey = 'widgetCalendarData';
  static const androidName = 'LawdingWidgetLargeCalendar';
  static const iOSName = 'LawdingCalendarLargeWidget';

  static const _typeHoliday = 0;
  static const _typeLeave = 1;
  static const _typeOther = 2;

  final GetHolidaysUseCase _getHolidays;
  final GetCalendarEventsUseCase _getEvents;

  CalendarWidgetSync(this._getHolidays, this._getEvents);

  Future<void> sync() async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final next = DateTime(now.year, now.month + 1, 1);
    final to = DateTime(now.year, now.month + 2, 0);

    // calendarScreen과 같은 조회 범위
    final holidaysFuture = _getHolidays.execute(startYear: now.year - 1, endYear: now.year + 2);
    final thisMonthFuture = _getEvents.execute(year: from.year, month: from.month);
    final nextMonthFuture = _getEvents.execute(year: next.year, month: next.month);

    final holidays = _valueOrLog(await holidaysFuture, '공휴일');
    final thisMonth = _valueOrLog(await thisMonthFuture, '${from.month}월 일정');
    final nextMonth = _valueOrLog(await nextMonthFuture, '${next.month}월 일정');
    // 하나라도 실패하면 이전 데이터를 유지한다.
    if (holidays == null || thisMonth == null || nextMonth == null) return;

    final payload = buildPayload(holidays, [...thisMonth, ...nextMonth], from, to);
    await WidgetService.save(dataKey, payload);
    await HomeWidget.updateWidget(androidName: androidName, iOSName: iOSName);
  }

  static T? _valueOrLog<T>(Result<T, NetworkError> result, String label) {
    switch (result) {
      case Success(:final value):
        return value;
      case Failure(:final error):
        debugPrint('[CalendarWidget] $label 조회 실패: $error');
        return null;
    }
  }

  static String buildPayload(
    List<Holiday> holidays,
    List<CalendarEventEntity> events,
    DateTime from,
    DateTime to,
  ) {
    final items = <Map<String, Object>>[];

    for (final h in holidays) {
      final d = DateTime(h.date.year, h.date.month, h.date.day);
      if (d.isBefore(from) || d.isAfter(to)) continue;
      final (label, detail) = _parseHolidayName(h.name);
      items.add({
        's': _ymd(d),
        'e': _ymd(d),
        't': _typeHoliday,
        'k': 0,
        'title': label,
        'sub': detail,
        'cell': label,
      });
    }

    final seenIds = <int>{};
    for (final e in events) {
      if (!seenIds.add(e.id)) continue;
      final start = DateTime(e.startDatetime.year, e.startDatetime.month, e.startDatetime.day);
      final end = DateTime(e.endDatetime.year, e.endDatetime.month, e.endDatetime.day);
      if (end.isBefore(from) || start.isAfter(to)) continue;

      final time = e.isAllDay ? '종일' : '${_hm(e.startDatetime)} - ${_hm(e.endDatetime)}';
      final hasTitle = e.title.trim().isNotEmpty;
      items.add({
        's': _ymd(start),
        'e': _ymd(end),
        't': e.isLeaveEvent ? _typeLeave : _typeOther,
        'k': e.isAllDay ? -1 : e.startDatetime.hour * 60 + e.startDatetime.minute,
        'title': hasTitle ? e.title.trim() : time,
        'sub': hasTitle ? time : '',
        if (e.isLeaveEvent) 'badge': _leaveBadge(e),
      });
    }

    return jsonEncode({'items': items});
  }

  /// calendarScreen과 동일: "대체공휴일(삼일절)" → ('대체공휴일', '삼일절')
  static (String, String) _parseHolidayName(String name) {
    final open = name.indexOf('(');
    final close = name.indexOf(')');
    if (open != -1 && close > open) {
      return (name.substring(0, open).trim(), name.substring(open + 1, close).trim());
    }
    return (name, '');
  }

  /// 실제 차감량(usedLeaveMinutes) 기준(종일 포함). 값이 없으면 종일 또는 시작~종료 시간 차로 대체.
  static String _leaveBadge(CalendarEventEntity e) {
    if (e.usedLeaveMinutes <= 0 && e.isAllDay) return '연차(종일)';
    final minutes = e.usedLeaveMinutes > 0
        ? e.usedLeaveMinutes
        : e.endDatetime.difference(e.startDatetime).inMinutes.clamp(0, 1440);
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '연차($h시간)' : '연차($h시간 $m분)';
  }

  static String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _hm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
