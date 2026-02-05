/// 전체 용어 사전 목록 API 응답 모델 (페이지네이션 없음)
/// GET /v1/dictionaries
class DictionaryListApiResponse {
  final String status;
  final String message;
  final List<DictionaryItemResponse> data;
  final String timestamp;

  const DictionaryListApiResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory DictionaryListApiResponse.fromJson(Map<String, dynamic> json) {
    return DictionaryListApiResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map(
            (item) =>
                DictionaryItemResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      timestamp: json['timestamp'] as String,
    );
  }
}

/// 용어 사전 검색 API 응답 모델 (페이지네이션 있음)
/// GET /v1/dictionaries/search
class DictionarySearchApiResponse {
  final String status;
  final String message;
  final DictionarySearchDataResponse data;
  final String timestamp;

  const DictionarySearchApiResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory DictionarySearchApiResponse.fromJson(Map<String, dynamic> json) {
    return DictionarySearchApiResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: DictionarySearchDataResponse.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
      timestamp: json['timestamp'] as String,
    );
  }
}

/// 검색 결과 데이터 응답 모델
class DictionarySearchDataResponse {
  final List<DictionaryItemResponse> content;
  final PageResponse page;

  const DictionarySearchDataResponse({
    required this.content,
    required this.page,
  });

  factory DictionarySearchDataResponse.fromJson(Map<String, dynamic> json) {
    return DictionarySearchDataResponse(
      content: (json['content'] as List<dynamic>)
          .map(
            (item) =>
                DictionaryItemResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      page: PageResponse.fromJson(json['page'] as Map<String, dynamic>),
    );
  }
}

/// 용어 사전 항목 응답 모델
class DictionaryItemResponse {
  final int id;
  final DictionaryCategoryResponse category;
  final String question;
  final String content;

  const DictionaryItemResponse({
    required this.id,
    required this.category,
    required this.question,
    required this.content,
  });

  factory DictionaryItemResponse.fromJson(Map<String, dynamic> json) {
    return DictionaryItemResponse(
      id: json['id'] as int,
      category: DictionaryCategoryResponse.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      question: json['question'] as String,
      content: json['content'] as String,
    );
  }
}

/// 용어 사전 카테고리 응답 모델
class DictionaryCategoryResponse {
  final int id;
  final String name;

  const DictionaryCategoryResponse({
    required this.id,
    required this.name,
  });

  factory DictionaryCategoryResponse.fromJson(Map<String, dynamic> json) {
    return DictionaryCategoryResponse(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

/// 페이지네이션 응답 모델
class PageResponse {
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const PageResponse({
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PageResponse.fromJson(Map<String, dynamic> json) {
    return PageResponse(
      page: json['page'] as int,
      size: json['size'] as int,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
    );
  }
}
