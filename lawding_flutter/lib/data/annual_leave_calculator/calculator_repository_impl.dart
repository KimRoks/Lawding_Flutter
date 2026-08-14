import '../../domain/core/result.dart';
import '../../domain/entities/annual_leave.dart';
import '../../domain/entities/non_working_period.dart';
import '../../domain/repositories/annual_leave_repository.dart';
import '../network/dio_client.dart';
import '../network/network_error.dart';
import 'calculator_api.dart';
import 'calculator_mapper.dart';
import 'calculator_response.dart';

class AnnualLeaveRepositoryImpl implements AnnualLeaveRepository {
  final DioClient _client;

  AnnualLeaveRepositoryImpl(this._client);

  @override
  Future<Result<AnnualLeave, NetworkError>> calculateAnnualLeave({
    required CalculationType calculationType,
    required DateTime hireDate,
    required DateTime referenceDate,
    String? fiscalYear,
    required List<NonWorkingPeriod> nonWorkingPeriods,
    required List<DateTime> companyHolidays,
  }) async {
    try {
      // Domain → Data 변환
      final params = calculationType.toParams(
        hireDate: hireDate,
        referenceDate: referenceDate,
        fiscalYear: fiscalYear,
        nonWorkingPeriods: nonWorkingPeriods,
        companyHolidays: companyHolidays,
      );

      final request = CalculatorApi.calculate(params);
      final response = await _client.request(request);
      final calculatorResponse = CalculatorResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Data → Domain 변환
      return Success(calculatorResponse.toDomain());
    } on NetworkError catch (error) {
      return Failure(error);
    } catch (e) {
      return Failure(ServerError(message: e.toString()));
    }
  }
}
