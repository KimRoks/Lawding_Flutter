import '../core/result.dart';
import '../entities/dictionary.dart';
import '../../data/network/network_error.dart';

/// 용어 사전 Repository 인터페이스
/// Data Layer와 Domain Layer를 분리하는 추상화
abstract interface class DictionaryRepository {
  /// 전체 용어 사전 목록 조회 (페이지네이션 없음)
  Future<Result<DictionaryListResult, NetworkError>> getDictionaries();

  /// 키워드로 용어 사전 검색 (페이지네이션 있음)
  Future<Result<DictionarySearchResult, NetworkError>> searchDictionaries({
    required String keyword,
  });
}
