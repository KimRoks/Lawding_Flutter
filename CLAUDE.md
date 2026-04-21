# Lawding Flutter — Project Instructions

## Architecture

Clean Architecture + MVVM + Riverpod v2.

```
Presentation → Domain ← Data
Presentation → Infrastructure
```

## 절대 금지 (위반 시 아키텍처 붕괴)

1. `domain/` → 다른 레이어 import (domain은 순수 Dart만)
2. `presentation/` (`providers.dart` 제외) → `data/` 직접 import
3. `infrastructure/` → `domain/`, `data/`, `presentation/` import
4. ViewModel → Repository 직접 호출 (반드시 UseCase 경유)
5. `!` null assertion 사용 — 런타임 크래시 유발
6. `as` 강제 타입캐스팅 — `is` 체크 후 스마트 캐스트 사용
7. `build()` 내부 `async`/`await` 또는 side effect
8. `print()` 사용 — `debugPrint()` 또는 logging 서비스 사용

## Import 허용 규칙

| Layer                                   | 참조 가능                                     |
| --------------------------------------- | --------------------------------------------- |
| `domain/`                               | `domain/` 내부만                              |
| `data/`                                 | `domain/`                                     |
| `presentation/`                         | `domain/`, `infrastructure/`                  |
| `presentation/providers/providers.dart` | `domain/`, `data/` — DI 조립 전용 유일한 예외 |
| `infrastructure/`                       | 외부 패키지만                                 |

## 에러 타입 위치 규칙

- Repository 인터페이스 반환 타입에 등장하는 에러는 `domain/core/`에 선언
- Dio/HTTP 예외 → `NetworkError` 변환은 `data/` Mapper/RepositoryImpl에서만 처리
- `data/`의 구체적 예외 타입(DioException 등)이 `domain/`에 노출되면 안 됨

## 런타임 호출 흐름

```
ViewModel → UseCase → Repository interface (domain/)
                              ↑ providers.dart가 RepositoryImpl 주입
```

- Domain Entity는 Presentation에서 직접 사용 (별도 모델 변환 불필요)
- DTO → Entity 변환은 `RepositoryImpl` 내 Mapper에서만 처리

**providers.dart 패턴:**

```dart
@riverpod
LeaveRepository leaveRepository(ref) =>
    LeaveRepositoryImpl(ref.watch(dioClientProvider));
```

## 레이어별 책임

| Layer          | 책임                                              |
| -------------- | ------------------------------------------------- |
| ViewModel      | UI 상태, Analytics/Crashlytics 호출, UseCase 호출 |
| UseCase        | 비즈니스 유효성 검사, 도메인 로직                 |
| RepositoryImpl | 네트워크/로컬 접근, Mapper로 DTO → Entity 변환    |
| Infrastructure | 싱글톤 서비스 (Analytics, Crashlytics)            |

## 코드 규칙

```dart
// null 처리
final value = someNullable ?? defaultValue;   // ✅
if (someObject is MyType) { /* 스마트 캐스트 */ } // ✅
final value = someNullable!;                  // ❌
final typed = someObject as MyType;           // ❌

// async 후 context 사용
await someAsyncOperation();
if (!mounted) return; // 필수
Navigator.of(context).pop();

// const 위젯 — 붙일 수 있으면 반드시 붙인다
const MyWidget()  // ✅

// 에러 처리 — Result<S, F> sealed class, exhaustive switch 필수
final result = await useCase.execute(params);
switch (result) {
  case Success(:final value): // 성공 처리
  case Failure(:final error): // 실패 처리
} // else/default 금지 — 케이스 누락 시 컴파일 에러로 강제 검출
```

- 변경되지 않는 변수는 `final`
- `dynamic` 타입 자제
- `design system: presentation/core/` (AppColors, AppTextStyles) 사용 — 색상/텍스트 하드코딩 금지

## 알려진 기술 부채

없음

## 코드 생성

Riverpod provider 변경 후 필수 실행:

```bash
dart run build_runner build
```

`.g.dart` 파일 직접 수정 금지.

## 파일 suffix 규칙

`_screen` · `_view_model` · `_state` · `_repository` · `_repository_impl` · `_api` · `_mapper` · `_usecase` · `_service`

새 기능: `data/{feature}/` · `domain/usecases/` · `presentation/screens/{feature}/` 구조 유지.
