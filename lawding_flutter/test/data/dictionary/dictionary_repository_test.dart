import 'package:flutter_test/flutter_test.dart';
import 'package:lawding_flutter/data/dictionary/dictionary_repository_impl.dart';
import 'package:lawding_flutter/data/network/dio_client.dart';
import 'package:lawding_flutter/data/network/network_error.dart';
import 'package:lawding_flutter/domain/core/result.dart';
import 'package:lawding_flutter/domain/entities/dictionary.dart';

import '../../helpers/mock_dio_helper.dart';

void main() {
  group('DictionaryRepository Tests', () {
    late MockDioHelper mockDioHelper;
    late DioClient dioClient;
    late DictionaryRepositoryImpl repository;

    setUp(() {
      mockDioHelper = MockDioHelper(baseUrl: 'https://api.test.com');
      dioClient = DioClient(
        baseUrl: 'https://api.test.com',
        dio: mockDioHelper.dio,
      );
      repository = DictionaryRepositoryImpl(dioClient);
    });

    // 전체 목록 응답 (data가 배열)
    final mockListSuccessResponse = {
      'status': 'success',
      'message': 'success',
      'data': [
        {
          'id': 1,
          'category': {'id': 100, 'name': '연차발생'},
          'question': '연차는 어떻게 발생하나요?',
          'content': '연차는 근로기준법에 따라 발생합니다.',
        },
        {
          'id': 2,
          'category': {'id': 102, 'name': '연차사용'},
          'question': '연차를 시간단위로 사용할 수 있나요?',
          'content': '원칙적으로 연차유급휴가는 1일 단위로 사용하여야 합니다.',
        },
      ],
      'timestamp': '2026-01-30T16:22:24.825024077+09:00',
    };

    // 검색 결과 응답 (data가 객체 with content + page)
    final mockSearchSuccessResponse = {
      'status': 'success',
      'message': 'success',
      'data': {
        'content': [
          {
            'id': 23,
            'category': {'id': 102, 'name': '연차사용'},
            'question': '소수점 연차는 어떻게 사용하나요?',
            'content': '연차유급휴가는 일단위로 발생하는 것이 원칙입니다.',
          },
          {
            'id': 22,
            'category': {'id': 104, 'name': '퇴사 및 정산'},
            'question': '연차를 다 못 쓰면 어떻게 되나요?',
            'content': '연차는 "유효기간"이 있어요.',
          },
        ],
        'page': {
          'page': 0,
          'size': 6,
          'totalElements': 19,
          'totalPages': 4,
          'hasNext': true,
          'hasPrevious': false,
        },
      },
      'timestamp': '2026-01-30T16:22:24.825024077+09:00',
    };

    group('getDictionaries', () {
      test('전체 용어 사전 목록 조회 성공', () async {
        // Given
        mockDioHelper.mockGet(
          path: '/v1/dictionaries',
          responseData: mockListSuccessResponse,
          statusCode: 200,
        );

        // When
        final result = await repository.getDictionaries();

        // Then
        expect(result, isA<Success<DictionaryListResult, NetworkError>>());
        result.fold(
          onSuccess: (dictionaryResult) {
            expect(dictionaryResult.items.length, 2);
            expect(dictionaryResult.items[0].id, 1);
            expect(dictionaryResult.items[0].question, '연차는 어떻게 발생하나요?');
            expect(dictionaryResult.items[0].category.name, '연차발생');
          },
          onFailure: (error) {
            fail('Should not fail but got error: $error');
          },
        );
      });

      test('전체 용어 사전 목록 조회 실패 - 서버 에러 (500)', () async {
        // Given
        mockDioHelper.mockError(
          path: '/v1/dictionaries',
          method: 'GET',
          statusCode: 500,
          errorMessage: 'Internal Server Error',
        );

        // When
        final result = await repository.getDictionaries();

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
        mockDioHelper.mockTimeout(
          path: '/v1/dictionaries',
          method: 'GET',
        );

        // When
        final result = await repository.getDictionaries();

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
    });

    group('searchDictionaries', () {
      test('키워드 검색 성공', () async {
        // Given
        mockDioHelper.mockGet(
          path: '/v1/dictionaries/search',
          responseData: mockSearchSuccessResponse,
          statusCode: 200,
          queryParameters: {'keyword': '연차'},
        );

        // When
        final result = await repository.searchDictionaries(keyword: '연차');

        // Then
        expect(result, isA<Success<DictionarySearchResult, NetworkError>>());
        result.fold(
          onSuccess: (dictionaryResult) {
            expect(dictionaryResult.items.length, 2);
            expect(dictionaryResult.pageInfo.page, 0);
            expect(dictionaryResult.pageInfo.totalElements, 19);
            expect(dictionaryResult.pageInfo.hasNext, true);
          },
          onFailure: (error) {
            fail('Should not fail but got error: $error');
          },
        );
      });

      test('키워드 검색 실패 - 서버 에러 (500)', () async {
        // Given
        mockDioHelper.mockError(
          path: '/v1/dictionaries/search',
          method: 'GET',
          statusCode: 500,
          errorMessage: 'Internal Server Error',
        );

        // When
        final result = await repository.searchDictionaries(keyword: '연차');

        // Then
        expect(result, isA<Failure<DictionarySearchResult, NetworkError>>());
        result.fold(
          onSuccess: (_) {
            fail('Should fail with ServerError');
          },
          onFailure: (error) {
            expect(error, isA<ServerError>());
          },
        );
      });

      test('키워드 검색 실패 - 인증 에러 (401)', () async {
        // Given
        mockDioHelper.mockError(
          path: '/v1/dictionaries/search',
          method: 'GET',
          statusCode: 401,
          errorMessage: 'Unauthorized',
        );

        // When
        final result = await repository.searchDictionaries(keyword: '연차');

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
  });
}
