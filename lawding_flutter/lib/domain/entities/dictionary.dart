/// 용어 사전 카테고리를 나타내는 Domain Entity
class DictionaryCategory {
  /// 카테고리 ID
  final int id;

  /// 카테고리명
  final String name;

  const DictionaryCategory({
    required this.id,
    required this.name,
  });

  @override
  String toString() {
    return 'DictionaryCategory(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DictionaryCategory && other.id == id && other.name == name;
  }

  @override
  int get hashCode {
    return Object.hash(id, name);
  }
}

/// 용어 사전 항목을 나타내는 Domain Entity
class Dictionary {
  /// 항목 ID
  final int id;

  /// 카테고리
  final DictionaryCategory category;

  /// 질문
  final String question;

  /// 내용
  final String content;

  const Dictionary({
    required this.id,
    required this.category,
    required this.question,
    required this.content,
  });

  @override
  String toString() {
    return 'Dictionary(id: $id, question: $question)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Dictionary &&
        other.id == id &&
        other.category == category &&
        other.question == question &&
        other.content == content;
  }

  @override
  int get hashCode {
    return Object.hash(id, category, question, content);
  }
}

/// 페이지네이션 정보를 나타내는 Domain Entity
class PageInfo {
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const PageInfo({
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  @override
  String toString() {
    return 'PageInfo(page: $page, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PageInfo &&
        other.page == page &&
        other.size == size &&
        other.totalElements == totalElements &&
        other.totalPages == totalPages &&
        other.hasNext == hasNext &&
        other.hasPrevious == hasPrevious;
  }

  @override
  int get hashCode {
    return Object.hash(page, size, totalElements, totalPages, hasNext, hasPrevious);
  }
}

/// 전체 용어 사전 목록 결과 (페이지네이션 없음)
class DictionaryListResult {
  final List<Dictionary> items;

  const DictionaryListResult({
    required this.items,
  });

  @override
  String toString() {
    return 'DictionaryListResult(items: ${items.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DictionaryListResult && other.items == items;
  }

  @override
  int get hashCode {
    return items.hashCode;
  }
}

/// 용어 사전 검색 결과 (페이지네이션 있음)
class DictionarySearchResult {
  final List<Dictionary> items;
  final PageInfo pageInfo;

  const DictionarySearchResult({
    required this.items,
    required this.pageInfo,
  });

  @override
  String toString() {
    return 'DictionarySearchResult(items: ${items.length}, pageInfo: $pageInfo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DictionarySearchResult &&
        other.items == items &&
        other.pageInfo == pageInfo;
  }

  @override
  int get hashCode {
    return Object.hash(items, pageInfo);
  }
}
