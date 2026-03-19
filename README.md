-----

# ⚖️ Lawding (로딩) — 근로기준법 기반 연차 계산기

   

> **"비즈니스 확장성을 위해 Swift에서 Flutter로 마이그레이션된 전천후 연차 계산 솔루션"**
>
> 기존 iOS 전용(Swift) 서비스를 안드로이드 유저까지 확장하고자 **Flutter 마이그레이션**을 주도했습니다. 단순 기능 이식을 넘어 **Clean Architecture**와 **데이터 기반 의사결정**을 도입하여 기술적 안정성과 유저 경험을 동시에 확보한 프로젝트입니다.

-----

## 🔗 다운로드 및 마켓 링크

| iOS 앱스토어 링크 | 안드로이드 플레이스토어 링크 |
| :---: | :---: |
| [App Store 바로가기](https://apps.apple.com/kr/app/lawding-%EC%97%B0%EC%B0%A8%EA%B3%84%EC%82%B0%EA%B8%B0/id6751892414) | [Google Play 바로가기](https://play.google.com/store/apps/details?id=com.lawding.annualleavecalculator&pcampaignid=web_share) |

-----

## 📱 서비스 스크린샷


<img src="https://github.com/user-attachments/assets/afcf8c70-965a-4fae-8ac3-14b5e9afbbd0" width="24%"> <img src="https://github.com/user-attachments/assets/dea10052-93d4-4399-bfb1-060c51ee42f4" width="24%"> <img src="https://github.com/user-attachments/assets/abc43582-6284-49c1-a731-b8a1217c8a81" width="24%"> <img src="https://github.com/user-attachments/assets/c7528595-ac2e-4fac-8099-f347a29e418e" width="24%">

## 🏆 Key Highlights (핵심 역량)

### 1️⃣ Swift Native to Flutter 마이그레이션

  * **비즈니스 목표**: iOS 전용 서비스를 크로스 플랫폼으로 전환하여 안드로이드 잠재 고객층을 확보했습니다.
  * **기술적 성과**: Swift의 비즈니스 로직을 Dart로 완벽 이식했습니다. 특히 Swift의 안정적인 `Result` 타입을 Dart의 `Sealed Class`로 재구현하여 기존의 견고한 에러 핸들링 패턴을 유지했습니다.

### 2️⃣ 데이터 기반 의사결정 사이클 도입 (GA4)

  * **문제 정의**: 특정 화면(Calculation Detail)의 유입률이 기획 의도보다 낮음을 Google Analytics 분석으로 발견했습니다.
  * **해결 과정**: GA4 데이터를 바탕으로 유저 저니(User Journey)를 분석하여, 화면으로의 유입을 유도하기 위해 디자이너에게 시각적 강조(CTA) 버튼 추가 및 디자인 개선을 제안하고 이를 실 서비스에 적용했습니다.
  * **결과**: 업데이트 이후 해당 화면 접근율을 3% -> 18% **전기 대비 약 [15]% 개선**하며 데이터 기반 성장을 경험했습니다.

### 3️⃣ Crash-free User 99.9% 유지 (Crashlytics)

  * **운영 전략**: Firebase Crashlytics를 도입하여 배포 후 실시간 비정상 종료를 감지하고 대응합니다.
  * **성과**: 복잡한 계산 로직과 마이그레이션 과정에서도 \*\*Crash-free User 지수 99.9%\*\*를 유지하며 프로덕션 수준의 안정성을 입증했습니다.

-----

## 🛠 기술 스택 (Tech Stack)

| 구분 | 기술 |
|---|---|
| **언어 / 프레임워크** | Dart 3 / Flutter |
| **아키텍처** | Clean Architecture (Presentation / Domain / Data) |
| **상태 관리** | Riverpod 2 + Code Generation |
| **네트워크** | Dio 5 + 커스텀 에러 핸들링 |
| **의존성 주입** | Riverpod `@riverpod` 코드 생성 기반 DI |
| **분석 / 모니터링** | Firebase Analytics · Firebase Crashlytics |
| **테스트** | flutter\_test · Mockito · http\_mock\_adapter |
| **CI / 빌드** | build\_runner (코드 생성), firebase\_options (멀티 환경) |
| **플랫폼** | iOS 16.0+ · Android |

-----

## 🏗 아키텍처 및 설계 결정

### Clean Architecture (Domain-Centric)

프레임워크의 의존성을 분리하고 테스트 용이성을 확보하기 위해 레이어를 엄격히 분리했습니다. 특히 **Domain 레이어는 순수 Dart 코드**로만 구성하여 비즈니스 로직의 독립성을 확보했습니다.

### Swift-Style `Result<S, F>` Pattern

Dart의 런타임 예외 처리를 보완하기 위해 Swift의 Result 타입을 도입하여 에러 처리를 강제했습니다.

```dart
// UseCase 반환 타입을 Result로 강제하여 UI 레이어에서 모든 에러 처리를 컴파일 타임에 보장
final result = await calculateUseCase.execute(params);

result.fold(
  onSuccess: (data) => _render(data),
  onFailure: (error) => _showError(error),
);
```

-----

## 📁 프로젝트 구조 (Folder Structure)

```text
lib/
├── main.dart
├── firebase_options.dart
│
├── data/                         # 외부 데이터 소스 및 통신
│   ├── network/                  # Dio 클라이언트 및 에러 매핑
│   ├── annual_leave_calculator/  # DTO + Repository 구현체
│   ├── feedback/
│   ├── dictionary/
│   └── app_version/
│
├── domain/                       # 순수 비즈니스 로직 (심장부)
│   ├── core/                     # Result<S, F> 공통 타입
│   ├── entities/                 # 불변 도메인 모델
│   ├── repositories/             # 인터페이스 (DIP)
│   └── usecases/                 # 단일 책임 비즈니스 로직
│
├── infrastructure/               # 플랫폼 서비스
│   └── services/                 # Analytics, Crashlytics, AppReview
│
└── presentation/                 # UI 레이어
    ├── core/                     # 디자인 시스템 (Color, Typography)
    ├── providers/                # Riverpod Providers (DI)
    ├── screens/                  # 기능별 화면
    └── widgets/                  # 재사용 가능한 공용 위젯
```

-----

## 📄 주요 기능

| 기능 | 설명 |
|:---:|---|
| **연차 계산** | 입사일·기준일·회사 공휴일·특례 기간을 반영한 정밀 연차 산정 |
| **계산 상세** | 월별 발생/비례 방식 등 복잡한 계산 내역의 시각화 |
| **노동법 사전** | 클라이언트 사이드 검색 및 필터를 지원하는 용어 백과 |
| **사전 제안** | 사용자 참여형 신규 용어 등록 제안 기능 |
| **피드백** | 운영 및 로직 개선을 위한 5가지 유형의 인앱 피드백 채널 |
| **버전 체크** | 앱 안정성 유지를 위한 강제/선택 업데이트 유도 시스템 |
| **인앱 리뷰** | 특정 조건 만족 시 유도되는 AppStore/PlayStore 리뷰 시스템 |

-----

## 🚀 실행 및 테스트

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (Riverpod, JSON 직렬화 등)
dart run build_runner build --delete-conflicting-outputs

# 테스트 실행
flutter test
```

-----

### 💡 인사이트 및 경험

  * **1인 앱 개발자**로서 기획, 디자인 협업, 구현, 배포, 마케팅 지표 분석까지 앱의 전체 라이프사이클을 경험했습니다.
  * **마이그레이션** 과정에서 플랫폼별 특성을 이해하고, 유지보수 가능한 아키텍처(Clean Architecture)의 중요성을 체감했습니다.
  * \*\*데이터(GA)\*\*를 근거로 팀원(디자이너)과 소통하고 서비스를 개선하는 프로세스를 확립했습니다.

-----
