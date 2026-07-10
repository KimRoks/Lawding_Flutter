import '../core/result.dart';
import '../entities/calendar_event.dart';
import '../repositories/calendar_event_repository.dart';
import '../../data/network/network_error.dart';

/// 단건 캘린더 이벤트 조회 UseCase
class GetCalendarEventUseCase {
  final CalendarEventRepository _repository;

  GetCalendarEventUseCase(this._repository);

  Future<Result<CalendarEventEntity, NetworkError>> execute({required int id}) {
    return _repository.getCalendarEvent(id: id);
  }
}
