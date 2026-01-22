# MACNAC Frontend

Flutter 기반 크로스 플랫폼 프론트엔드

## 구현 현황

### 1단계 완료 ✅

- [x] Flutter 프로젝트 기본 설정
- [x] 디렉토리 구조 구성
- [x] 색상/테마/타이포그래피 정의
- [x] 인증 상태 관리 (Provider)
- [x] 온보딩 화면
- [x] 로그인 화면
- [x] 회원가입 화면

### 2단계 완료 ✅

- [x] Bento Grid 레이아웃 시스템 (가변 크기 타일)
- [x] 뉴스 데이터 모델 (GridTileSize enum)
- [x] 반응형 그리드 위젯
- [x] 뉴스 카드 위젯 (애니메이션 포함)
- [x] 홈 화면 구현 (Mock 데이터)
- [x] Bottom Navigation Bar
- [x] Pull-to-Refresh
- [x] Hero 애니메이션 및 탭 효과

### 3단계 완료 ✅

- [x] 뉴스 상세 화면 (재창작 요약 + 인과관계 + 인사이트 + 출처)
- [x] 인과관계 분석 위젯 (원인→결과, 신뢰도 표시)
- [x] 투자 인사이트 위젯 (타입별 색상, 중요도 별표)
- [x] 출처 링크 위젯 (저작권 가드레일 준수)
- [x] 구독 화면 (토핑 모듈 선택, 가격 계산)
- [x] 프로필 화면 (사용자 정보, 로그아웃)

### 다음 단계 (4단계 예정)

- [ ] API 서비스 레이어 구현
- [ ] 실제 백엔드 연동
- [ ] 에러 핸들링 및 로딩 상태 개선

## 프로젝트 구조

```
frontend/
├── lib/
│   ├── config/           # 앱 설정 (색상, 테마)
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── models/           # 데이터 모델
│   │   ├── user_model.dart
│   │   └── news_article_model.dart
│   ├── providers/        # 상태 관리
│   │   └── auth_provider.dart
│   ├── screens/          # 화면
│   │   ├── onboarding_screen.dart
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── home_screen.dart
│   ├── widgets/          # 재사용 위젯
│   │   └── bento_grid.dart
│   ├── services/         # API 서비스 (추후 추가)
│   ├── utils/            # 유틸리티 (추후 추가)
│   └── main.dart         # 앱 엔트리포인트
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
└── pubspec.yaml
```

## 실행 방법

### 사전 준비

1. Flutter SDK 설치: https://flutter.dev/docs/get-started/install
2. 의존성 설치:

```bash
cd frontend
flutter pub get
```

### 실행

#### 웹
```bash
flutter run -d chrome
```

#### iOS 시뮬레이터
```bash
flutter run -d ios
```

#### Android 에뮬레이터
```bash
flutter run -d android
```

### 빌드

#### 웹
```bash
flutter build web
```

#### APK (Android)
```bash
flutter build apk
```

#### iOS
```bash
flutter build ios
```

## 주요 기능

### 인증 흐름

1. **온보딩** → 최초 실행 시 서비스 소개
2. **로그인** → 이메일/비밀번호 또는 Google 로그인
3. **회원가입** → 이메일 인증 및 약관 동의

### Bento Grid 레이아웃

- **가변 크기 타일**: 1x1 (small), 2x1 (wide), 1x2 (tall), 2x2 (large)
- **반응형 그리드**: crossAxisCount 설정 가능
- **애니메이션**: 탭 시 스케일 효과, Hero 애니메이션
- **자동 레이아웃**: 타일 크기에 따라 자동 배치

### 홈 화면

- Bento Grid 뉴스 피드
- Pull-to-Refresh
- Bottom Navigation (홈/구독/프로필)
- 필터 & 정렬 (모달)
- Mock 데이터 6개 표시

### 상태 관리

- Provider 패턴 사용
- `AuthProvider`: 사용자 인증 상태 관리

### 테마

- Light/Dark 모드 지원
- Material 3 Design
- Pretendard 폰트 (추가 필요)

## 개발 가이드

### 색상 사용

```dart
import '../config/app_colors.dart';

// Primary Color
AppColors.primary

// Text Colors
AppColors.textPrimary
AppColors.textSecondary
```

### 테마 사용

```dart
// 현재 테마의 텍스트 스타일
Theme.of(context).textTheme.displayLarge
Theme.of(context).textTheme.bodyMedium
```

### Provider 사용

```dart
// 읽기
final authProvider = Provider.of<AuthProvider>(context);

// 쓰기 (rebuild 없이)
final authProvider = Provider.of<AuthProvider>(context, listen: false);
await authProvider.signIn(email: email, password: password);
```

### Bento Grid 사용

```dart
import '../widgets/bento_grid.dart';
import '../models/news_article_model.dart';

BentoGrid(
  articles: newsArticles,
  onTileTap: (article) {
    // 상세 화면으로 이동
    Navigator.pushNamed(context, '/detail', arguments: article);
  },
  crossAxisCount: 2, // 기본값
  spacing: 12, // 타일 간격
)
```

### GridTileSize 설정

```dart
NewsArticleModel(
  // ... 다른 필드
  tileSize: GridTileSize.large, // small, wide, tall, large
)
```

## TODO

- [ ] Pretendard 폰트 파일 추가
- [ ] 앱 아이콘 및 스플래시 스크린
- [ ] API 서비스 레이어 구현
- [ ] 에러 핸들링 개선
- [ ] 로딩 상태 UI 개선
- [ ] 폼 유효성 검사 강화
