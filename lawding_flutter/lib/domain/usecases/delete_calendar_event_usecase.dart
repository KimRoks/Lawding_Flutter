import '../core/result.dart';
import '../repositories/calendar_event_repository.dart';
import '../../data/network/network_error.dart';

/// 캘린더 이벤트 삭제 UseCase
class DeleteCalendarEventUseCase {
  final CalendarEventRepository _repository;

  DeleteCalendarEventUseCase(this._repository);

  Future<Result<void, NetworkError>> execute({required int id}) {
    return _repository.deleteCalendarEvent(id: id);
  }
}
