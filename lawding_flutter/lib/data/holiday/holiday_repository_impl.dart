import '../../domain/core/result.dart';
import '../../domain/entities/holiday.dart';
import '../../domain/repositories/holiday_repository.dart';
import '../network/dio_client.dart';
import '../network/network_error.dart';
import 'holiday_api.dart';
import 'holiday_mapper.dart';
import 'holiday_response.dart';

class HolidayRepositoryImpl implements HolidayRepository {
  final DioClient _client;

  HolidayRepositoryImpl(this._client);

  @override
  Future<Result<List<Holiday>, NetworkError>> getHolidays({
    required int startYear,
    required int endYear,
  }) async {
    try {
      final request = HolidayApi.getHolidays(
        startYear: startYear,
        endYear: endYear,
      );
      final response = await _client.request(request);
      final apiResponse = HolidayListApiResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Success(apiResponse.toDomain());
    } on NetworkError catch (error) {
      return Failure(error);
    } catch (e) {
      return Failure(ServerError(message: e.toString()));
    }
  }
}
