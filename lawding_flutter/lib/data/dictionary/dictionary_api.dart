import '../network/api_endpoints.dart';
import '../network/api_request.dart';
import '../network/http_methods.dart';

class DictionaryApi {
  DictionaryApi._();

  /// 전체 용어 사전 목록 조회
  static ApiRequest getDictionaries() {
    return const ApiRequest(
      method: HttpMethod.get,
      path: ApiEndpoints.dictionaries,
    );
  }

  /// 키워드로 용어 사전 검색
  static ApiRequest searchDictionaries({required String keyword}) {
    return ApiRequest(
      method: HttpMethod.get,
      path: ApiEndpoints.dictionarySearch,
      queryParameters: {'keyword': keyword},
    );
  }
}
