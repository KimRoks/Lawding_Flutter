import '../core/result.dart';
import '../repositories/calendar_event_repository.dart';
import '../entities/calendar_event_request.dart';
import '../../data/network/network_error.dart';

/// 캘린더 이벤트 생성 UseCase
class CreateCalendarEventUseCase {
  final CalendarEventRepository _repository;

  CreateCalendarEventUseCase(this._repository);

  Future<Result<void, NetworkError>> execute({
    required CalendarEventRequest request,
  }) {
    return _repository.createCalendarEvent(request: request);
  }
}
