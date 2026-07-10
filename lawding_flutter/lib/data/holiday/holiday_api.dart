import '../network/api_endpoints.dart';
import '../network/api_request.dart';
import '../network/http_methods.dart';

class HolidayApi {
  HolidayApi._();

  /// 공휴일 목록 조회 API
  /// GET /holidays?start-year={startYear}&end-year={endYear}
  static ApiRequest getHolidays({
    required int startYear,
    required int endYear,
  }) {
    return ApiRequest(
      method: HttpMethod.get,
      path: ApiEndpoints.holidays,
      queryParameters: {
        'start-year': startYear,
        'end-year': endYear,
      },
    );
  }
}
