import '../../data/network/network_error.dart';
import '../core/result.dart';
import '../entities/dictionary.dart';
import '../repositories/dictionary_repository.dart';

/// 용어 사전 검색 UseCase
class SearchDictionaryUseCase {
  final DictionaryRepository _repository;

  SearchDictionaryUseCase(this._repository);

  /// 키워드로 용어 사전 검색 실행
  Future<Result<DictionarySearchResult, NetworkError>> execute({
    required String keyword,
  }) async {
    // 비즈니스 검증: 빈 키워드 체크
    if (keyword.trim().isEmpty) {
      return const Failure(
        ServerError(message: '검색 키워드를 입력해주세요', statusCode: 400),
      );
    }

    return await _repository.searchDictionaries(keyword: keyword.trim());
  }
}
