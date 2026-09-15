import '../../domain/entities/public_holiday_period.dart';

/// 공공 연휴 하드코딩 데이터 (API 연동 전 임시).
/// startDate 오름차순 정렬 유지.
final List<PublicHolidayPeriod> kPublicHolidayPeriods = [
  // 2026
  PublicHolidayPeriod(
    name: '광복절 연휴',
    startDate: DateTime.utc(2026, 8, 15),
    endDate: DateTime.utc(2026, 8, 17),
  ),
  PublicHolidayPeriod(
    name: '추석 연휴',
    startDate: DateTime.utc(2026, 9, 24),
    endDate: DateTime.utc(2026, 9, 27),
  ),
  PublicHolidayPeriod(
    name: '개천절 연휴',
    startDate: DateTime.utc(2026, 10, 3),
    endDate: DateTime.utc(2026, 10, 5),
  ),
  PublicHolidayPeriod(
    name: '한글날 연휴',
    startDate: DateTime.utc(2026, 10, 9),
    endDate: DateTime.utc(2026, 10, 11),
  ),
  PublicHolidayPeriod(
    name: '성탄절 연휴',
    startDate: DateTime.utc(2026, 12, 25),
    endDate: DateTime.utc(2026, 12, 27),
  ),
  // 2027
  PublicHolidayPeriod(
    name: '신정 연휴',
    startDate: DateTime.utc(2027, 1, 1),
    endDate: DateTime.utc(2027, 1, 3),
  ),
  PublicHolidayPeriod(
    name: '설 연휴',
    startDate: DateTime.utc(2027, 2, 6),
    endDate: DateTime.utc(2027, 2, 9),
  ),
  PublicHolidayPeriod(
    name: '삼일절 연휴',
    startDate: DateTime.utc(2027, 2, 27),
    endDate: DateTime.utc(2027, 3, 1),
  ),
  PublicHolidayPeriod(
    name: '노동절 연휴',
    startDate: DateTime.utc(2027, 5, 1),
    endDate: DateTime.utc(2027, 5, 3),
  ),
  PublicHolidayPeriod(
    name: '제헌절 연휴',
    startDate: DateTime.utc(2027, 7, 17),
    endDate: DateTime.utc(2027, 7, 19),
  ),
  PublicHolidayPeriod(
    name: '광복절 연휴',
    startDate: DateTime.utc(2027, 8, 14),
    endDate: DateTime.utc(2027, 8, 16),
  ),
  PublicHolidayPeriod(
    name: '추석 연휴',
    startDate: DateTime.utc(2027, 9, 14),
    endDate: DateTime.utc(2027, 9, 16),
  ),
  PublicHolidayPeriod(
    name: '개천절 연휴',
    startDate: DateTime.utc(2027, 10, 2),
    endDate: DateTime.utc(2027, 10, 4),
  ),
  PublicHolidayPeriod(
    name: '한글날 연휴',
    startDate: DateTime.utc(2027, 10, 9),
    endDate: DateTime.utc(2027, 10, 11),
  ),
  PublicHolidayPeriod(
    name: '성탄절 연휴',
    startDate: DateTime.utc(2027, 12, 25),
    endDate: DateTime.utc(2027, 12, 27),
  ),
];
