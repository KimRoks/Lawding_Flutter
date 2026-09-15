class PublicHolidayPeriod {
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  const PublicHolidayPeriod({
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  int get days => endDate.difference(startDate).inDays + 1;

  /// 오늘 날짜 기준 가장 가까운 (아직 시작 안 했거나 진행 중인) 일정
  static PublicHolidayPeriod? nearest(
    List<PublicHolidayPeriod> list, {
    required DateTime today,
  }) {
    final upcoming = list.where((h) => !h.endDate.isBefore(today)).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  /// "9월 24일(목) ~ 9월 27일(일) 추석 연휴"
  String get displayLabel {
    String fmt(DateTime d) {
      const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      return '${d.month}월 ${d.day}일(${weekdays[d.weekday - 1]})';
    }

    return '${fmt(startDate)} ~ ${fmt(endDate)} $name';
  }
}
