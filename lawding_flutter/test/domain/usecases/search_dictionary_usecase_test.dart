import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/network/network_error.dart';
import 'package:lawding_flutter/domain/core/result.dart';
import 'package:lawding_flutter/domain/entities/dictionary.dart';
import 'package:lawding_flutter/domain/repositories/dictionary_repository.dart';
import 'package:lawding_flutter/domain/usecases/search_dictionary_usecase.dart';

/// Mock DictionaryRepository
class MockDictionaryRepository implements DictionaryRepository {
  DictionaryListResult? _mockListResult;
  DictionarySearchResult? _mockSearchResult;
  NetworkError? _mockError;
  String? lastSearchKeyword;

  void setMockSearchResult(DictionarySearchResult result) {
    _mockSearchResult = result;
    _mockError = null;
  }

  void setMockError(NetworkError error) {
    _mockError = error;
    _mockSearchResult = null;
  }

  @override
  Future<Result<DictionaryListResult, NetworkError>> getDictionaries() async {
    if (_mockError != null) {
      return Failure(_mockError!);
    }
    return Success(_mockListResult!);
  }

  @override
  Future<Result<DictionarySearchResult, NetworkError>> searchDictionaries({
    required String keyword,
  }) async {
    lastSearchKeyword = keyword;
    if (_mockError != null) {
      return Failure(_mockError!);
    }
    return Success(_mockSearchResult!);
  }
}

void main() {
  group('SearchDictionaryUseCase Tests', () {
    late MockDictionaryRepository mockRepository;
    late SearchDictionaryUseCase useCase;

    setUp(() {
      mockRepository = MockDictionaryRepository();
      useCase = SearchDictionaryUseCase(mockRepository);
    });

    final mockDictionarySearchResult = DictionarySearchResult(
      items: [
        const Dictionary(
          id: 1,
          category: DictionaryCategory(id: 100, name: '연차발생'),
          question: '연차는 어떻게 발생하나요?',
          content: '연차는 근로기준법에 따라 발생합니다.',
        ),
      ],
      pageInfo: const PageInfo(
        page: 0,
        size: 10,
        totalElements: 1,
        totalPages: 1,
        hasNext: false,
        hasPrevious: false,
      ),
    );

    test('키워드 검색 성공', () async {
      // Given
      mockRepository.setMockSearchResult(mockDictionarySearchResult);

      // When
      final result = await useCase.execute(keyword: '연차');

      // Then
      expect(result, isA<Success<DictionarySearchResult, NetworkError>>());
      expect(mockRepository.lastSearchKeyword, '연차');
      result.fold(
        onSuccess: (dictionaryResult) {
          expect(dictionaryResult.items.length, 1);
          expect(dictionaryResult.items[0].question, '연차는 어떻게 발생하나요?');
        },
        onFailure: (error) {
          fail('Should not fail but got error: $error');
        },
      );
    });

    test('키워드 검색 성공 - 앞뒤 공백 제거', () async {
      // Given
      mockRepository.setMockSearchResult(mockDictionarySearchResult);

      // When
      final result = await useCase.execute(keyword: '  연차  ');

      // Then
      expect(result, isA<Success<DictionarySearchResult, NetworkError>>());
      expect(mockRepository.lastSearchKeyword, '연차');
    });

    test('키워드 검색 실패 - 빈 키워드', () async {
      // Given
      mockRepository.setMockSearchResult(mockDictionarySearchResult);

      // When
      final result = await useCase.execute(keyword: '');

      // Then
      expect(result, isA<Failure<DictionarySearchResult, NetworkError>>());
      result.fold(
        onSuccess: (_) {
          fail('Should fail with validation error');
        },
        onFailure: (error) {
          expect(error, isA<ServerError>());
          expect((error as ServerError).statusCode, 400);
          expect(error.message, '검색 키워드를 입력해주세요');
        },
      );
    });

    test('키워드 검색 실패 - 공백만 있는 키워드', () async {
      // Given
      mockRepository.setMockSearchResult(mockDictionarySearchResult);

      // When
      final result = await useCase.execute(keyword: '   ');

      // Then
      expect(result, isA<Failure<DictionarySearchResult, NetworkError>>());
      result.fold(
        onSuccess: (_) {
          fail('Should fail with validation error');
        },
        onFailure: (error) {
          expect(error, isA<ServerError>());
          expect((error as ServerError).message, '검색 키워드를 입력해주세요');
        },
      );
    });

    test('키워드 검색 실패 - 서버 에러', () async {
      // Given
      mockRepository.setMockError(
        const ServerError(message: 'Internal Server Error', statusCode: 500),
      );

      // When
      final result = await useCase.execute(keyword: '연차');

      // Then
      expect(result, isA<Failure<DictionarySearchResult, NetworkError>>());
      result.fold(
        onSuccess: (_) {
          fail('Should fail with ServerError');
        },
        onFailure: (error) {
          expect(error, isA<ServerError>());
          expect((error as ServerError).statusCode, 500);
        },
      );
    });

    test('키워드 검색 실패 - 타임아웃', () async {
      // Given
      mockRepository.setMockError(const TimeoutError());

      // When
      final result = await useCase.execute(keyword: '연차');

      // Then
      expect(result, isA<Failure<DictionarySearchResult, NetworkError>>());
      result.fold(
        onSuccess: (_) {
          fail('Should fail with TimeoutError');
        },
        onFailure: (error) {
          expect(error, isA<TimeoutError>());
        },
      );
    });

    test('키워드 검색 실패 - 인증 에러', () async {
      // Given
      mockRepository.setMockError(const UnauthorizedError());

      // When
      final result = await useCase.execute(keyword: '연차');

      // Then
      expect(result, isA<Failure<DictionarySearchResult, NetworkError>>());
      result.fold(
        onSuccess: (_) {
          fail('Should fail with UnauthorizedError');
        },
        onFailure: (error) {
          expect(error, isA<UnauthorizedError>());
        },
      );
    });
  });
}
