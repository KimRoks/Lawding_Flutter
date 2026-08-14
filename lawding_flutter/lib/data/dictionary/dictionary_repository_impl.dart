import '../../domain/core/result.dart';
import '../../domain/entities/dictionary.dart';
import '../../domain/repositories/dictionary_repository.dart';
import '../network/dio_client.dart';
import '../network/network_error.dart';
import 'dictionary_api.dart';
import 'dictionary_mapper.dart';
import 'dictionary_response.dart';

class DictionaryRepositoryImpl implements DictionaryRepository {
  final DioClient _client;

  DictionaryRepositoryImpl(this._client);

  @override
  Future<Result<DictionaryListResult, NetworkError>> getDictionaries() async {
    try {
      final request = DictionaryApi.getDictionaries();
      final response = await _client.request(request);

      final apiResponse = DictionaryListApiResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return Success(apiResponse.toDomain());
    } on NetworkError catch (error) {
      return Failure(error);
    } catch (e) {
      return Failure(ServerError(message: e.toString()));
    }
  }

  @override
  Future<Result<DictionarySearchResult, NetworkError>> searchDictionaries({
    required String keyword,
  }) async {
    try {
      final request = DictionaryApi.searchDictionaries(keyword: keyword);
      final response = await _client.request(request);

      final apiResponse = DictionarySearchApiResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return Success(apiResponse.data.toDomain());
    } on NetworkError catch (error) {
      return Failure(error);
    } catch (e) {
      return Failure(ServerError(message: e.toString()));
    }
  }
}
