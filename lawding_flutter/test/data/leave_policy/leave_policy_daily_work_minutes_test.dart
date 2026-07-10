import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/domain/entities/leave_policy.dart';
import 'package:lawding_flutter/domain/entities/leave_policy_request.dart';

LeavePolicy _makePolicy({
  required Map<String, WorkTimeSlot> workPattern,
  Map<String, WorkTimeSlot>? breakTimePattern,
}) {
  return LeavePolicy(
    userId: 1,
    acceptedAt: '2026-07-05T15:35:56',
    leaveAccrualBasis: 1,
    hireDate: '2024-05-08',
    companySize: 30,
    workPattern: workPattern,
    breakTimePattern: breakTimePattern ?? {},
  );
}

void main() {
  group('LeavePolicy.dailyWorkMinutes', () {
    test('표준 주 5일 (09:00-18:00, 점심 12:00-13:00) → 480분', () {
      final policy = _makePolicy(
        workPattern: {
          'MONDAY': const WorkTimeSlot(start: '09:00:00', end: '18:00:00'),
          'TUESDAY': const WorkTimeSlot(start: '09:00:00', end: '18:00:00'),
          'WEDNESDAY': const WorkTimeSlot(start: '09:00:00', end: '18:00:00'),
          'THURSDAY': const WorkTimeSlot(start: '09:00:00', end: '18:00:00'),
          'FRIDAY': const WorkTimeSlot(start: '09:00:00', end: '18:00:00'),
        },
        breakTimePattern: {
          'MONDAY': const WorkTimeSlot(start: '12:00:00', end: '13:00:00'),
          'TUESDAY': const WorkTimeSlot(start: '12:00:00', end: '13:00:00'),
          'WEDNESDAY': const WorkTimeSlot(start: '12:00:00', end: '13:00:00'),
          'THURSDAY': const WorkTimeSlot(start: '12:00:00', end: '13:00:00'),
          'FRIDAY': const WorkTimeSlot(start: '12:00:00', end: '13:00:00'),
        },
      );

      expect(policy.dailyWorkMinutes, 480);
    });

    test('HH:mm 포맷도 정상 파싱', () {
      final policy = _makePolicy(
        workPattern: {
          'MONDAY': const WorkTimeSlot(start: '09:00', end: '18:00'),
        },
        breakTimePattern: {
          'MONDAY': const WorkTimeSlot(start: '12:00', end: '13:00'),
        },
      );

      expect(policy.dailyWorkMinutes, 480);
    });

    test('휴게시간 없을 때 → 총 근무시간 그대로', () {
      final policy = _makePolicy(
        workPattern: {
          'MONDAY': const WorkTimeSlot(start: '09:00:00', end: '17:00:00'),
        },
      );

      expect(policy.dailyWorkMinutes, 480);
    });

    test('날마다 근무시간이 다를 때 → 평균 반환', () {
      // MON: 9시간, TUE: 7시간 → 평균 8시간 = 480분
      final policy = _makePolicy(
        workPattern: {
          'MONDAY': const WorkTimeSlot(start: '09:00:00', end: '18:00:00'),
          'TUESDAY': const WorkTimeSlot(start: '09:00:00', end: '16:00:00'),
        },
        breakTimePattern: {},
      );

      expect(policy.dailyWorkMinutes, 480);
    });

    test('workPattern 비어있으면 fallback 480', () {
      final policy = _makePolicy(workPattern: {});

      expect(policy.dailyWorkMinutes, 480);
    });
  });
}
