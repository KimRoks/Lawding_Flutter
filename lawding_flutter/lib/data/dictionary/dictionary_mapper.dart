import '../../domain/entities/dictionary.dart';
import 'dictionary_response.dart';

/// DictionaryCategoryResponse → DictionaryCategory 변환
extension DictionaryCategoryResponseMapper on DictionaryCategoryResponse {
  DictionaryCategory toDomain() {
    return DictionaryCategory(id: id, name: name);
  }
}

/// DictionaryItemResponse → Dictionary 변환
extension DictionaryItemResponseMapper on DictionaryItemResponse {
  Dictionary toDomain() {
    return Dictionary(
      id: id,
      category: category.toDomain(),
      question: question,
      content: content,
    );
  }
}

/// PageResponse → PageInfo 변환
extension PageResponseMapper on PageResponse {
  PageInfo toDomain() {
    return PageInfo(
      page: page,
      size: size,
      totalElements: totalElements,
      totalPages: totalPages,
      hasNext: hasNext,
      hasPrevious: hasPrevious,
    );
  }
}

/// DictionaryListApiResponse → DictionaryListResult 변환 (전체 목록, 페이지네이션 없음)
extension DictionaryListApiResponseMapper on DictionaryListApiResponse {
  DictionaryListResult toDomain() {
    return DictionaryListResult(
      items: data.map((item) => item.toDomain()).toList(),
    );
  }
}

/// DictionarySearchDataResponse → DictionarySearchResult 변환 (검색 결과, 페이지네이션 있음)
extension DictionarySearchDataResponseMapper on DictionarySearchDataResponse {
  DictionarySearchResult toDomain() {
    return DictionarySearchResult(
      items: content.map((item) => item.toDomain()).toList(),
      pageInfo: page.toDomain(),
    );
  }
}
