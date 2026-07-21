import '../core/result.dart';
import '../repositories/calendar_event_repository.dart';
import '../entities/calendar_event_request.dart';
import '../../data/network/network_error.dart';

/// 캘린더 이벤트 수정 UseCase
class UpdateCalendarEventUseCase {
  final CalendarEventRepository _repository;

  UpdateCalendarEventUseCase(this._repository);

  Future<Result<void, NetworkError>> execute({
    required int id,
    required CalendarEventRequest request,
  }) {
    return _repository.updateCalendarEvent(id: id, request: request);
  }
}
