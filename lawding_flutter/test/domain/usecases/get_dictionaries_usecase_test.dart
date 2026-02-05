import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/network/network_error.dart';
import 'package:lawding_flutter/domain/core/result.dart';
import 'package:lawding_flutter/domain/entities/dictionary.dart';
import 'package:lawding_flutter/domain/repositories/dictionary_repository.dart';
import 'package:lawding_flutter/domain/usecases/get_dictionaries_usecase.dart';

/// Mock DictionaryRepository
class MockDictionaryRepository implements DictionaryRepository {
  DictionaryListResult? _mockListResult;
  DictionarySearchResult? _mockSearchResult;
  NetworkError? _mockError;

  void setMockListResult(DictionaryListResult result) {
    _mockListResult = result;
    _mockError = null;
  }

  void setMockError(NetworkError error) {
    _mockError = error;
    _mockListResult = null;
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
    if (_mockError != null) {
      return Failure(_mockError!);
    }
    return Success(_mockSearchResult!);
  }
}

void main() {
  group('GetDictionariesUseCase Tests', () {
    late MockDictionaryRepository mockRepository;
    late GetDictionariesUseCase useCase;

    setUp(() {
      mockRepository = MockDictionaryRepository();
      useCase = GetDictionariesUseCase(mockRepository);
    });

    const mockDictionaryListResult = DictionaryListResult(
      items: [
        Dictionary(
          id: 1,
          category: DictionaryCategory(id: 100, name: '연차발생'),
          question: '연차는 어떻게 발생하나요?',
          content: '연차는 근로기준법에 따라 발생합니다.',
        ),
        Dictionary(
          id: 2,
          category: DictionaryCategory(id: 102, name: '연차사용'),
          question: '연차는 언제 사용할 수 있나요?',
          content: '발생한 연차는 1년 이내에 사용해야 합니다.',
        ),
      ],
    );

    test('전체 용어 사전 목록 조회 성공', () async {
      // Given
      mockRepository.setMockListResult(mockDictionaryListResult);

      // When
      final result = await useCase.execute();

      // Then
      expect(result, isA<Success<DictionaryListResult, NetworkError>>());
      result.fold(
        onSuccess: (dictionaryResult) {
          expect(dictionaryResult.items.length, 2);
          expect(dictionaryResult.items[0].question, '연차는 어떻게 발생하나요?');
        },
        onFailure: (error) {
          fail('Should not fail but got error: $error');
        },
      );
    });

    test('전체 용어 사전 목록 조회 실패 - 서버 에러', () async {
      // Given
      mockRepository.setMockError(
        const ServerError(message: 'Internal Server Error', statusCode: 500),
      );

      // When
      final result = await useCase.execute();

      // Then
      expect(result, isA<Failure<DictionaryListResult, NetworkError>>());
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

    test('전체 용어 사전 목록 조회 실패 - 타임아웃', () async {
      // Given
      mockRepository.setMockError(const TimeoutError());

      // When
      final result = await useCase.execute();

      // Then
      expect(result, isA<Failure<DictionaryListResult, NetworkError>>());
      result.fold(
        onSuccess: (_) {
          fail('Should fail with TimeoutError');
        },
        onFailure: (error) {
          expect(error, isA<TimeoutError>());
        },
      );
    });

    test('전체 용어 사전 목록 조회 실패 - 네트워크 연결 에러', () async {
      // Given
      mockRepository.setMockError(const NetworkConnectionError());

      // When
      final result = await useCase.execute();

      // Then
      expect(result, isA<Failure<DictionaryListResult, NetworkError>>());
      result.fold(
        onSuccess: (_) {
          fail('Should fail with NetworkConnectionError');
        },
        onFailure: (error) {
          expect(error, isA<NetworkConnectionError>());
        },
      );
    });
  });
}
