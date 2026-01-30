import '../core/result.dart';
import '../entities/dictionary.dart';
import '../repositories/dictionary_repository.dart';
import '../../data/network/network_error.dart';

/// 전체 용어 사전 목록 조회 UseCase
class GetDictionariesUseCase {
  final DictionaryRepository _repository;

  GetDictionariesUseCase(this._repository);

  /// 전체 용어 사전 목록 조회 실행
  Future<Result<DictionaryListResult, NetworkError>> execute() async {
    return await _repository.getDictionaries();
  }
}
