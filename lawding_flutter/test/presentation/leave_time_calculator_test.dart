import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/domain/entities/holiday.dart';
import 'package:lawding_flutter/domain/entities/leave_policy_request.dart';
import 'package:lawding_flutter/presentation/screens/calendar/leave_time_calculator.dart';

// 전제 조건: 월~금 09:00~18:00, 점심 12:00~13:00, avgDailyWorkHours = 8.0
LeaveTimeCalculator _makeCalc({List<Holiday> holidays = const []}) {
  const days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'];
  return LeaveTimeCalculator(
    workPattern: {
      for (final d in days) d: const WorkTimeSlot(start: '09:00', end: '18:00'),
    },
    breakTimePattern: {
      for (final d in days) d: const WorkTimeSlot(start: '12:00', end: '13:00'),
    },
    avgDailyWorkHours: 8.0,
    holidays: holidays,
  );
}

// 2026-07-27 = 월요일, 7/28 = 화, 7/29 = 수, 7/26 = 일, 7/25 = 토
final _mon = DateTime(2026, 7, 27);
final _tue = DateTime(2026, 7, 28);
final _wed = DateTime(2026, 7, 29);
final _sat = DateTime(2026, 7, 25);
final _sun = DateTime(2026, 7, 26);

void main() {
  group('calcUsedMinutesForDate — 단일 날짜', () {
    test('근무 시간 내 (10:00~16:00) → 6h - 1h break = 5h', () {
      final calc = _makeCalc();
      expect(
        calc.calcUsedMinutesForDate(
          _mon,
          inputStartMin: 10 * 60,
          inputEndMin: 16 * 60,
          isAllDay: false,
        ),
        equals(300), // 5h
      );
    });

    test('시작이 근무 전 (05:00~18:00) → workStart에 클리핑 → 하루 전체 8h', () {
      final calc = _makeCalc();
      expect(
        calc.calcUsedMinutesForDate(
          _mon,
          inputStartMin: 5 * 60,
          inputEndMin: 18 * 60,
          isAllDay: false,
        ),
        equals(480), // 8h
      );
    });

    test('종료가 근무 후 (09:00~20:00) → workEnd에 클리핑 → 하루 전체 8h', () {
      final calc = _makeCalc();
      expect(
        calc.calcUsedMinutesForDate(
          _mon,
          inputStartMin: 9 * 60,
          inputEndMin: 20 * 60,
          isAllDay: false,
        ),
        equals(480),
      );
    });

    test('근무 시간 외 (20:00~22:00) → 겹침 없음 → 0', () {
      final calc = _makeCalc();
      expect(
        calc.calcUsedMinutesForDate(
          _mon,
          inputStartMin: 20 * 60,
          inputEndMin: 22 * 60,
          isAllDay: false,
        ),
        equals(0),
      );
    });

    test('종일 → maxMin (8h = 480min)', () {
      final calc = _makeCalc();
      expect(
        calc.calcUsedMinutesForDate(
          _mon,
          inputStartMin: 0,
          inputEndMin: 0,
          isAllDay: true,
        ),
        equals(480),
      );
    });

    test('공휴일 → 0', () {
      final calc = _makeCalc(holidays: [Holiday(date: _mon, name: '임시공휴일')]);
      expect(
        calc.calcUsedMinutesForDate(
          _mon,
          inputStartMin: 9 * 60,
          inputEndMin: 18 * 60,
          isAllDay: false,
        ),
        equals(0),
      );
    });

    test('비근로일 (토요일) → 0', () {
      final calc = _makeCalc();
      expect(
        calc.calcUsedMinutesForDate(
          _sat,
          inputStartMin: 9 * 60,
          inputEndMin: 18 * 60,
          isAllDay: false,
        ),
        equals(0),
      );
    });

    test('점심 시간 전까지만 (09:00~12:00) → break 제외 없음 → 3h', () {
      final calc = _makeCalc();
      expect(
        calc.calcUsedMinutesForDate(
          _mon,
          inputStartMin: 9 * 60,
          inputEndMin: 12 * 60,
          isAllDay: false,
        ),
        equals(180),
      );
    });

    test('점심 포함 (09:00~13:00) → break 1h 제외 → 3h', () {
      final calc = _makeCalc();
      expect(
        calc.calcUsedMinutesForDate(
          _mon,
          inputStartMin: 9 * 60,
          inputEndMin: 13 * 60,
          isAllDay: false,
        ),
        equals(180),
      );
    });

    test('오후만 (14:00~18:00) → 4h (break 없음)', () {
      final calc = _makeCalc();
      expect(
        calc.calcUsedMinutesForDate(
          _mon,
          inputStartMin: 14 * 60,
          inputEndMin: 18 * 60,
          isAllDay: false,
        ),
        equals(240),
      );
    });

    // ─── 요건 1: 휴계시간 제외 명시적 검증 ───────────────────────────────────
    test('휴계시간만 선택 (12:00~13:00) → 연차 0분', () {
      // 선택 시간 전체가 휴계시간 → 실제 연차 차감 없음
      final calc = _makeCalc();
      expect(
        calc.calcUsedMinutesForDate(
          _mon,
          inputStartMin: 12 * 60,
          inputEndMin: 13 * 60,
          isAllDay: false,
        ),
        equals(0),
      );
    });

    test('휴계시간 일부 겹침 (11:30~13:30) → 30min break 제외 → 1.5h = 90min', () {
      // 11:30~12:00(30min) + 13:00~13:30(30min) = 60min, break overlap=30min
      // effStart=690, effEnd=810, break overlap 720~780=60min 이지만
      // 오버랩 계산: oStart=max(690,720)=720, oEnd=min(810,780)=780 → breakDed=60
      // result = 810-690-60 = 60min... 실제로는 11:30~12:00=30min + 13:00~13:30=30min = 60min
      final calc = _makeCalc();
      expect(
        calc.calcUsedMinutesForDate(
          _mon,
          inputStartMin: 11 * 60 + 30, // 11:30
          inputEndMin: 13 * 60 + 30,   // 13:30
          isAllDay: false,
        ),
        equals(60), // (13:30-11:30) - (13:00-12:00) = 120min - 60min = 60min
      );
    });
  });

  group('calcTotalUsedMinutes — 다일 이벤트 버그 수정 검증', () {
    // 테스트 케이스 1: 7/27(월) 05:00 ~ 7/29(수) 14:00 → 기대: 20h (1200min)
    test('TC1: 3일 (05:00~14:00) → 8h + 8h + 4h = 20h', () {
      final calc = _makeCalc();
      final result = calc.calcTotalUsedMinutes(
        [_mon, _tue, _wed],
        startMin: 5 * 60,
        endMin: 14 * 60,
        isAllDay: false,
      );
      expect(result, equals(1200));
    });

    // 테스트 케이스 2: 7/27(월) 15:00 ~ 7/29(수) 14:00 → 기대: 15h (900min)
    test('TC2: 3일 (15:00~14:00, 역순처럼 보임) → 3h + 8h + 4h = 15h', () {
      final calc = _makeCalc();
      final result = calc.calcTotalUsedMinutes(
        [_mon, _tue, _wed],
        startMin: 15 * 60,
        endMin: 14 * 60,
        isAllDay: false,
      );
      expect(result, equals(900));
    });

    test('단일 날짜 → calcUsedMinutesForDate와 동일', () {
      final calc = _makeCalc();
      expect(
        calc.calcTotalUsedMinutes([_mon], startMin: 10 * 60, endMin: 15 * 60, isAllDay: false),
        equals(calc.calcUsedMinutesForDate(_mon, inputStartMin: 10 * 60, inputEndMin: 15 * 60, isAllDay: false)),
      );
    });

    test('중간에 주말 포함 (토~월, 09:00~18:00) → 주말 제외 → 1일치만', () {
      final calc = _makeCalc();
      final result = calc.calcTotalUsedMinutes(
        [_sat, _sun, _mon],
        startMin: 9 * 60,
        endMin: 18 * 60,
        isAllDay: false,
      );
      // 토·일 = 0, 월(마지막날) = workStart~18:00 = 8h
      expect(result, equals(480));
    });

    test('중간에 공휴일 포함 (월~수, 화요일 공휴일) → 화 제외 → 16h', () {
      final calc = _makeCalc(holidays: [Holiday(date: _tue, name: '임시공휴일')]);
      final result = calc.calcTotalUsedMinutes(
        [_mon, _tue, _wed],
        startMin: 9 * 60,
        endMin: 18 * 60,
        isAllDay: false,
      );
      // 월(첫날, 09:00~workEnd) + 화(공휴일=0) + 수(마지막날, workStart~18:00) = 480+0+480
      expect(result, equals(960));
    });

    test('종일 3일 → 3 × 480 = 1440min', () {
      final calc = _makeCalc();
      expect(
        calc.calcTotalUsedMinutes([_mon, _tue, _wed], startMin: 0, endMin: 0, isAllDay: true),
        equals(1440),
      );
    });
  });

  group('hasWorkDayWithNoOverlap', () {
    test('단일 날짜 — 겹침 없음 (20:00~22:00) → true', () {
      final calc = _makeCalc();
      expect(
        calc.hasWorkDayWithNoOverlap([_mon], startMin: 20 * 60, endMin: 22 * 60),
        isTrue,
      );
    });

    test('단일 날짜 — 겹침 있음 (10:00~15:00) → false', () {
      final calc = _makeCalc();
      expect(
        calc.hasWorkDayWithNoOverlap([_mon], startMin: 10 * 60, endMin: 15 * 60),
        isFalse,
      );
    });

    test('TC2 (15:00~14:00, 3일) — 다일에선 겹침 있음 → false', () {
      final calc = _makeCalc();
      expect(
        calc.hasWorkDayWithNoOverlap([_mon, _tue, _wed], startMin: 15 * 60, endMin: 14 * 60),
        isFalse,
      );
    });

    test('첫날 시작이 workEnd와 동일 (18:00) → 겹침 없음 → true', () {
      final calc = _makeCalc();
      // 첫날: inputStart=18:00, inputEnd=1440(override). effStart=max(1080,540)=1080, effEnd=min(1440,1080)=1080 → 겹침 없음
      expect(
        calc.hasWorkDayWithNoOverlap([_mon, _wed], startMin: 18 * 60, endMin: 17 * 60),
        isTrue,
      );
    });

    test('비근로일(주말)만 포함 → 모두 skip → false', () {
      final calc = _makeCalc();
      expect(
        calc.hasWorkDayWithNoOverlap([_sat, _sun], startMin: 20 * 60, endMin: 22 * 60),
        isFalse,
      );
    });
  });

  group('hasOutsideWorkHours', () {
    test('시작이 근무 전 (05:00~18:00) → true', () {
      final calc = _makeCalc();
      expect(
        calc.hasOutsideWorkHours([_mon], startMin: 5 * 60, endMin: 18 * 60),
        isTrue,
      );
    });

    test('종료가 근무 후 (09:00~20:00) → true', () {
      final calc = _makeCalc();
      expect(
        calc.hasOutsideWorkHours([_mon], startMin: 9 * 60, endMin: 20 * 60),
        isTrue,
      );
    });

    test('정상 범위 (10:00~17:00) → false', () {
      final calc = _makeCalc();
      expect(
        calc.hasOutsideWorkHours([_mon], startMin: 10 * 60, endMin: 17 * 60),
        isFalse,
      );
    });

    test('정확히 근무 시간과 일치 (09:00~18:00) → false', () {
      final calc = _makeCalc();
      expect(
        calc.hasOutsideWorkHours([_mon], startMin: 9 * 60, endMin: 18 * 60),
        isFalse,
      );
    });

    test('다일 — 첫날 시작만 체크: 첫날이 주말이면 skip → false', () {
      final calc = _makeCalc();
      // 토(첫날, 비근로) → skip; 월(마지막날, 18:00) → 18:00 == workEnd → false
      expect(
        calc.hasOutsideWorkHours([_sat, _mon], startMin: 5 * 60, endMin: 18 * 60),
        isFalse,
      );
    });

    test('다일 — 마지막날 종료만 체크: 마지막날 종료가 19:00 → true', () {
      final calc = _makeCalc();
      expect(
        calc.hasOutsideWorkHours([_mon, _wed], startMin: 9 * 60, endMin: 19 * 60),
        isTrue,
      );
    });
  });
}
