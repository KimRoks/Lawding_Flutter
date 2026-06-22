import '../core/result.dart';
import '../entities/holiday.dart';
import '../../data/network/network_error.dart';

abstract interface class HolidayRepository {
  Future<Result<List<Holiday>, NetworkError>> getHolidays({
    required int startYear,
    required int endYear,
  });
}
