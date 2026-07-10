import '../../domain/core/result.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_event_repository.dart';
import '../network/dio_client.dart';
import '../network/network_error.dart';
import 'calendar_event_api.dart';
import 'calendar_event_mapper.dart';
import 'calendar_event_request.dart';
import 'calendar_event_response.dart';

class CalendarEventRepositoryImpl implements CalendarEventRepository {
  final DioClient _client;

  CalendarEventRepositoryImpl(this._client);

  @override
  Future<Result<List<CalendarEventEntity>, NetworkError>> getCalendarEvents({
    required int year,
    required int month,
  }) async {
    try {
      final response = await _client.request(
        CalendarEventApi.getCalendarEvents(year: year, month: month),
      );
      final apiResponse = CalendarEventListApiResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Success(apiResponse.toDomain());
    } on NetworkError catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<CalendarEventEntity, NetworkError>> getCalendarEvent({
    required int id,
  }) async {
    try {
      final response = await _client.request(
        CalendarEventApi.getCalendarEvent(id: id),
      );
      final apiResponse = CalendarEventSingleApiResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Success(apiResponse.toDomain());
    } on NetworkError catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<void, NetworkError>> createCalendarEvent({
    required CalendarEventRequest request,
  }) async {
    try {
      await _client.request(
        CalendarEventApi.createCalendarEvent(request: request),
      );
      return const Success(null);
    } on NetworkError catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<CalendarEventEntity, NetworkError>> updateCalendarEvent({
    required int id,
    required CalendarEventRequest request,
  }) async {
    try {
      final response = await _client.request(
        CalendarEventApi.updateCalendarEvent(id: id, request: request),
      );
      final apiResponse = CalendarEventSingleApiResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Success(apiResponse.toDomain());
    } on NetworkError catch (error) {
      return Failure(error);
    }
  }

  @override
  Future<Result<void, NetworkError>> deleteCalendarEvent({
    required int id,
  }) async {
    try {
      await _client.request(CalendarEventApi.deleteCalendarEvent(id: id));
      return const Success(null);
    } on NetworkError catch (error) {
      return Failure(error);
    }
  }
}
