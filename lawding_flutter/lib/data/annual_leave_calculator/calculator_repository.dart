import '../network/dio_client.dart';
import 'calculator_api.dart';
import 'calculator_params.dart';
import 'calculator_response.dart';

/// Data Layer Repository (테스트용)
/// Domain Layer와 분리된 순수 Data 처리
class CalculatorRepository {
  final DioClient _client;

  CalculatorRepository(this._client);

  /// 연차 계산 API 호출
  Future<CalculatorResponse> calculate(CalculatorCalculateParams params) async {
    final request = CalculatorApi.calculate(params);
    final response = await _client.request(request);
    return CalculatorResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
