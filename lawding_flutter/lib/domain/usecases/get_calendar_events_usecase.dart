import '../core/result.dart';
import '../entities/calendar_event.dart';
import '../repositories/calendar_event_repository.dart';
import '../../data/network/network_error.dart';

/// 월별 캘린더 이벤트 목록 조회 UseCase
class GetCalendarEventsUseCase {
  final CalendarEventRepository _repository;

  GetCalendarEventsUseCase(this._repository);

  Future<Result<List<CalendarEventEntity>, NetworkError>> execute({
    required int year,
    required int month,
  }) {
    return _repository.getCalendarEvents(year: year, month: month);
  }
}
