# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 답변 규칙
- 질문에는 핵심만 짧고 간결하게 답변할 것
- 한국어로 답변할 것
- 듣는 사람이 비전공자라는 가정 하에 이해하기 쉽게 설명할 것
- 코드는 최대한 효율적이고 쉽고 간결하게 작성할 것
- 커밋메세지를 작성해달라는 요청엔 메세지만 작성할 것

## 프로젝트 개요

**MACNAC: 데일리 뉴스 요약 및 투자 인사이트 서비스**

### 서비스 핵심
1. **데일리 뉴스 요약** - 매일 주요 뉴스를 짧고 쉽게 전달
2. **투자 인사이트** - 뉴스를 읽고 끝이 아닌, 행동 지침 제공

### 부가 기능
- 인과관계(Causality) 분석
- AI 기반 뉴스 재창작
- 모듈형 구독제 (토핑 모델)

### 저작권 가드레일 (필수 준수)

이 프로젝트의 가장 중요한 원칙입니다:

1. **재창작(Re-creation)**
   - 원문의 문장을 복제하지 않음
   - 사실관계만 추출하여 완전히 새로운 문장으로 생성
   - AI 엔진이 원문을 참조하되, 표현은 독자적으로 재구성

2. **주종관계(Primary-Secondary)**
   - **주(主)**: 서비스 고유의 분석 (인과관계, 투자 인사이트)
   - **종(從)**: 뉴스 요약 (보조적 역할)
   - 저작권 위험을 줄이기 위해 분석 콘텐츠가 핵심이 되어야 함

3. **단순 링크(Simple Link)**
   - 원본 뉴스로의 아웃링크를 시스템화
   - 모든 콘텐츠에 출처(URL, 언론사명, 작성일시) 필수 표기
   - API 응답에도 출처 정보 반드시 포함

## 기술 스택

### Backend
- **Python 3.11+**
- **FastAPI**: 고성능 비동기 REST API 프레임워크
- **PostgreSQL**: 메인 데이터베이스
- **Redis**: 캐싱 및 세션 관리
- **SQLAlchemy**: ORM (PostgreSQL 연동)
- **python-dotenv**: 환경변수 관리

### AI Engine
- **Claude API (Anthropic)**: GPT-4o-mini 대체
  - 뉴스 분석 및 재창작 엔진
  - 인과관계 추출
  - 투자 인사이트 생성

### Frontend
- **Flutter**: 크로스 플랫폼 UI 프레임워크
- **Bento Grid 스타일**: 모던 타일 기반 레이아웃
- **Responsive Design**: 웹/모바일 동시 지원

### Infrastructure
- **AWS Serverless**: 권장 아키텍처
  - Lambda (API 서버리스)
  - RDS (PostgreSQL)
  - ElastiCache (Redis)
  - S3 (정적 자산)
  - CloudFront (CDN)

## 프로젝트 구조

```
macnac/
├── backend/              # FastAPI 기반 REST API 서버
│   ├── app/
│   │   ├── models/       # SQLAlchemy 데이터 모델 (PostgreSQL)
│   │   ├── routes/       # API 엔드포인트
│   │   ├── services/     # 비즈니스 로직
│   │   │   ├── claude_service.py    # Claude AI 연동
│   │   │   ├── causality_service.py # 인과관계 분석
│   │   │   └── insight_service.py   # 투자 인사이트
│   │   ├── utils/        # 유틸리티 함수
│   │   └── prompts/      # AI 프롬프트 템플릿
│   ├── config.py         # 설정 관리
│   └── main.py           # FastAPI 애플리케이션 엔트리포인트
├── frontend/             # Flutter 애플리케이션
│   ├── lib/
│   │   ├── screens/      # 화면 위젯
│   │   ├── widgets/      # 재사용 가능한 위젯
│   │   ├── models/       # 데이터 모델
│   │   ├── services/     # API 통신
│   │   └── main.dart     # 앱 엔트리포인트
│   └── pubspec.yaml      # Flutter 의존성
├── scripts/              # 배포/설정 스크립트
└── docs/                 # 프로젝트 문서
    ├── architecture.md   # 시스템 아키텍처
    ├── api_spec.md       # API 명세서
    └── copyright_guide.md # 저작권 가이드
```

## 구현 순서

프로젝트는 다음 순서로 개발합니다:

1. **프론트엔드 UI 설계 및 구현**
   - Flutter Bento Grid 레이아웃
   - 주요 화면 프로토타입
   - 사용자 인터랙션 플로우

2. **아키텍처 및 DB 설계**
   - ERD 설계 (PostgreSQL 스키마)
   - API 엔드포인트 설계
   - 데이터 플로우 정의

3. **저작권 준수형 AI 엔진 프롬프트 로직**
   - Claude API 프롬프트 엔지니어링
   - 재창작 로직 구현
   - 인과관계 추출 알고리즘
   - 투자 인사이트 생성 로직

4. **백엔드 API 구현**
   - FastAPI 엔드포인트
   - PostgreSQL 모델 및 마이그레이션
   - Redis 캐싱 전략
   - Claude API 연동

5. **테스트 및 검증**
   - 저작권 준수 검증 (원문 복제 여부)
   - API 통합 테스트
   - 프론트엔드-백엔드 통합
   - 성능 테스트

## 개발 명령어

### 백엔드 개발

```bash
# 의존성 설치
cd backend
pip install -r requirements.txt

# 개발 서버 실행 (FastAPI)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 데이터베이스 마이그레이션
alembic upgrade head

# Redis 실행 (Docker)
docker run -d -p 6379:6379 redis:alpine

# 경로 주의사항 (전역 CLAUDE.md 설정 참조)
# - 스크립트 내부: /imbdx/rnd/ALScreen/...
# - 명령어 실행: Y:/imbdx/rnd/ALScreen/...
```

### 프론트엔드 개발

```bash
cd frontend

# 의존성 설치
flutter pub get

# 웹 개발 서버 실행
flutter run -d chrome

# 모바일 시뮬레이터 실행
flutter run -d ios
# 또는
flutter run -d android

# 빌드
flutter build web
flutter build apk
```

### 환경변수 설정

`.env` 파일 생성 필요:

```bash
# Claude API
ANTHROPIC_API_KEY=your_claude_api_key

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/macnac

# Redis
REDIS_URL=redis://localhost:6379/0

# App
DEBUG=True
SECRET_KEY=your_secret_key
```

## 주요 개발 원칙

### 저작권 준수 검증 체크리스트

모든 AI 생성 콘텐츠는 다음을 준수해야 함:
- [ ] 원문의 문장을 3단어 이상 연속으로 복제하지 않았는가?
- [ ] 사실관계만 추출하고 표현은 완전히 새롭게 작성했는가?
- [ ] 분석(인과관계/인사이트)이 요약보다 더 많은 비중을 차지하는가?
- [ ] 원본 출처(URL, 언론사, 날짜)가 명확히 표기되었는가?
- [ ] 아웃링크가 올바르게 작동하는가?

### AI 프롬프트 작성 가이드

`backend/app/prompts/` 디렉토리에 프롬프트 템플릿 관리:

```python
# 예시 구조
RECREATION_PROMPT = """
당신은 뉴스 재창작 전문가입니다.
원문을 읽고 사실관계만 추출하여 완전히 새로운 문장으로 작성하세요.

[중요 규칙]
1. 원문의 표현을 절대 복제하지 마세요
2. 사실만 추출하고 의견은 제외하세요
3. 간결하고 명확하게 작성하세요

원문: {original_text}
"""

CAUSALITY_PROMPT = """
뉴스에서 인과관계를 분석하세요.
원인(Cause)과 결과(Effect)를 명확히 구분하여 제시하세요.
...
"""
```

### API 설계 원칙

- **RESTful** 원칙 준수
- **비동기(async/await)** 처리 필수
- **Redis 캐싱** 전략:
  - 뉴스 분석 결과: 24시간 TTL
  - 인사이트: 1시간 TTL
- **출처 정보**를 모든 응답에 포함

### 코딩 스타일

- **Python**: PEP 8, snake_case, type hints 필수
- **Dart/Flutter**: Effective Dart 가이드 준수, camelCase
- **주석**: 한글로 작성
- **함수 문서화**: docstring 필수

## 데이터베이스 스키마 가이드

주요 테이블 (PostgreSQL):

- `news_articles`: 재창작된 뉴스 콘텐츠
  - 원본 복제 절대 금지
  - 출처 정보 필수 (source_url, publisher, published_at)

- `causality_analyses`: 인과관계 분석 결과

- `insights`: 투자 인사이트

- `users`: 사용자 정보

- `subscriptions`: 구독 정보 (모듈형 토핑)

## 테스트 전략

```bash
# 백엔드 테스트
cd backend
pytest tests/ -v

# 저작권 검증 테스트
pytest tests/test_copyright.py -v

# 프론트엔드 테스트
cd frontend
flutter test
```

## UI/UX 디자인 가이드 (일관성 유지)

### 색상 시스템 (모노톤)

```dart
// Primary (검정 계열)
textPrimary: #1A1A1A    // 주요 텍스트, 버튼
textSecondary: #666666  // 보조 텍스트, 아이콘
textTertiary: #999999   // 비활성 텍스트

// Background
background: #FAFAFA     // 페이지 배경
surface: #FFFFFF        // 카드, 컨테이너 배경

// Border
border: #E0E0E0         // 테두리
divider: #EEEEEE        // 구분선

// Status (최소 사용)
error: #D32F2F          // 에러, 로그아웃
```

### 타이포그래피

| 용도 | 크기 | 굵기 | 색상 |
|------|------|------|------|
| 페이지 제목 | 24-28px | w700 | textPrimary |
| 섹션 제목 | 18px | w700 | textPrimary |
| 카드 제목 | 15-16px | w600 | textPrimary |
| 본문 | 14-15px | normal | textPrimary |
| 보조 텍스트 | 12-13px | normal | textSecondary |
| 라벨/뱃지 | 10-11px | w600 | textSecondary |

### 간격 및 레이아웃

```
페이지 패딩: 20px
카드 패딩: 16px
카드 간격: 12px
섹션 간격: 32px
요소 간격: 8px, 12px, 16px (8px 배수)
```

### 컴포넌트 스타일

**카드**
```dart
borderRadius: 12px
border: 1px solid border (#E0E0E0)
elevation: 0 (그림자 없음)
background: surface (#FFFFFF)
```

**버튼 (Primary)**
```dart
borderRadius: 12px
height: 48-52px
background: textPrimary (#1A1A1A)
foreground: textOnDark (#FAFAFA)
elevation: 0
```

**버튼 (Outlined)**
```dart
borderRadius: 12px
border: 1px solid border
background: transparent
```

**입력 필드**
```dart
borderRadius: 12px
filled: true
fillColor: background (#FAFAFA)
border: none (기본), textPrimary (포커스)
```

**뱃지/라벨**
```dart
borderRadius: 4px
padding: 6px 10px (horizontal), 4px (vertical)
background: textPrimary (강조), background (일반)
```

### 화면별 필수 설정

모든 화면에서 반드시 명시적으로 설정:
```dart
Scaffold(
  backgroundColor: AppColors.background,  // 또는 surface
  appBar: AppBar(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
  ),
)
```

### 아이콘 사용

- 기본 색상: `AppColors.textSecondary`
- 활성/선택: `AppColors.textPrimary`
- 크기: 20-24px (일반), 28px (강조)
- Material Icons 사용 (outlined 버전 우선)

### 금지 사항

- 파란색/보라색 그라데이션 사용 금지
- elevation/그림자 사용 최소화
- 테마 기본값에 의존하지 말 것 (명시적 색상 지정)
- 신뢰도 그래프/퍼센트 표시 금지

## 참고 문서

- `docs/architecture.md`: 상세 시스템 아키텍처
- `docs/api_spec.md`: API 명세서
- `docs/copyright_guide.md`: 저작권 준수 상세 가이드
