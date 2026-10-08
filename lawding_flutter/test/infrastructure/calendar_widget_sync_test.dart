import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/domain/entities/calendar_event.dart';
import 'package:lawding_flutter/domain/entities/holiday.dart';
import 'package:lawding_flutter/infrastructure/services/calendar_widget_sync.dart';

void main() {
  final from = DateTime(2026, 3, 1);
  final to = DateTime(2026, 4, 30);

  List<Map<String, dynamic>> items(List<Holiday> holidays, List<CalendarEventEntity> events) {
    final json = jsonDecode(CalendarWidgetSync.buildPayload(holidays, events, from, to));
    return (json['items'] as List).cast<Map<String, dynamic>>();
  }

  CalendarEventEntity event({
    int id = 1,
    String title = '치과 예약',
    required DateTime start,
    required DateTime end,
    bool isAllDay = false,
    bool isLeave = true,
    int usedLeaveMinutes = 0,
  }) =>
      CalendarEventEntity(
        id: id,
        title: title,
        description: '',
        startDatetime: start,
        endDatetime: end,
        usedLeaveMinutes: usedLeaveMinutes,
        isAllDay: isAllDay,
        isLeaveEvent: isLeave,
      );

  test('괄호가 있는 공휴일명은 제목/부제로 나뉘고 셀 라벨은 괄호 앞부분이다', () {
    final result = items([Holiday(date: DateTime(2026, 3, 2), name: '대체공휴일(삼일절)')], []);

    expect(result.single, {
      's': '2026-03-02',
      'e': '2026-03-02',
      't': 0,
      'k': 0,
      'title': '대체공휴일',
      'sub': '삼일절',
      'cell': '대체공휴일',
    });
  });

  test('범위 밖 공휴일은 제외한다', () {
    final result = items([
      Holiday(date: DateTime(2026, 2, 28), name: '이전'),
      Holiday(date: DateTime(2026, 5, 1), name: '이후'),
    ], []);

    expect(result, isEmpty);
  });

  test('연차 일정은 시간 부제와 실제 차감량 pill을 가진다', () {
    final result = items([], [
      event(
        start: DateTime(2026, 3, 3, 10),
        end: DateTime(2026, 3, 3, 16),
        usedLeaveMinutes: 480,
      ),
    ]);

    expect(result.single['title'], '치과 예약');
    expect(result.single['sub'], '10:00 - 16:00');
    expect(result.single['badge'], '연차(8시간)');
    expect(result.single['t'], 1);
    expect(result.single['k'], 600);
  });

  test('이번 달·다음 달 조회에 모두 나온 일정은 한 번만 넣는다', () {
    final e = event(start: DateTime(2026, 3, 31), end: DateTime(2026, 4, 1), isAllDay: true);

    final result = items([], [e, e]);

    expect(result, hasLength(1));
    expect(result.single['sub'], '종일');
    expect(result.single['badge'], '연차(종일)');
  });

  test('종일 연차도 차감량이 있으면 실제 차감 시간을 pill에 표시한다', () {
    final result = items([], [
      event(
        start: DateTime(2026, 3, 12),
        end: DateTime(2026, 3, 12, 23, 59),
        isAllDay: true,
        usedLeaveMinutes: 498,
      ),
    ]);

    expect(result.single['sub'], '종일');
    expect(result.single['badge'], '연차(8시간 18분)');
  });

  test('제목 없는 일반 일정은 시간을 제목으로 쓰고 pill이 없다', () {
    final result = items([], [
      event(
        title: ' ',
        start: DateTime(2026, 3, 5, 9, 30),
        end: DateTime(2026, 3, 5, 11),
        isLeave: false,
      ),
    ]);

    expect(result.single['title'], '09:30 - 11:00');
    expect(result.single['sub'], '');
    expect(result.single['t'], 2);
    expect(result.single.containsKey('badge'), isFalse);
  });
}
