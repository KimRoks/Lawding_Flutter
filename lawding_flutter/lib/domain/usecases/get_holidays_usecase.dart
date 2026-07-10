import '../../data/network/network_error.dart';
import '../core/result.dart';
import '../entities/holiday.dart';
import '../repositories/holiday_repository.dart';

class GetHolidaysUseCase {
  final HolidayRepository _repository;

  GetHolidaysUseCase(this._repository);

  Future<Result<List<Holiday>, NetworkError>> execute({
    required int startYear,
    required int endYear,
  }) {
    return _repository.getHolidays(startYear: startYear, endYear: endYear);
  }
}
