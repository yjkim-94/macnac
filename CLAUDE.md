# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 답변 규칙
- 질문에는 핵심만 짧고 간결하게 답변할 것
- 한국어로 답변할 것
- 듣는 사람이 비전공자라는 가정 하에 이해하기 쉽게 설명할 것
- 코드는 최대한 효율적이고 쉽고 간결하게 작성할 것
- 커밋메세지를 작성해달라는 요청엔 메세지만 작성할 것

## 프로젝트 개요

**MACNAC: 하루의 핵심 뉴스를 간결하게 요약해 제공하는 브리핑 서비스**

### 서비스 핵심 (MVP)
- 오늘 주요 뉴스를 빠르게 확인하고, 5분 안에 전체 흐름 파악
- 하루 꼭 알아야 할 뉴스 5개 선별 (경제, 산업, 기술, 정책)
- 재창작 뉴스 요약 (원문 없이 사실 기반으로 새로 작성)

### MVP 이후 기능 (추후 출시)
- 투자 인사이트
- 인과관계(Causality) 분석
- 모듈형 구독제 (토핑 모델)

## 사용자 흐름 (MVP)

### 핵심 원칙
- **로그인 없이 바로 사용**
- 앱 실행 → 오늘 브리핑 바로 노출
- 익명 사용자 기준 설계
- 구독은 나중에 자연스럽게 붙임

### 전체 흐름
```
앱 실행 → 오늘 브리핑 카드 → 주요 뉴스 5개 읽기 → 원문 링크 클릭(선택) → 앱 종료
```

### 내부 준비 (화면에 안 보임)
- 사용자 상태: anonymous / subscriber
- 접근 권한 체크 함수 (현재는 항상 허용)
- 브리핑 데이터에 free / premium 플래그

## 하루 브리핑 구조

### 필수 구성 요소
1. **오늘의 한 줄 요약** - 오늘 뉴스의 공통 흐름 한 문장
2. **주요 뉴스 5개** - 각 뉴스별로 독립 섹션

### 각 뉴스 섹션 구성
- 재작성 제목 1줄
- 요약 본문 5~7줄 (배경 → 사건 → 영향 구조)
- 출처 정보 + 원문 링크

### 요약 길이 기준
- 뉴스 1개당 읽는 시간: 약 30~40초 (5~7문장)
- 전체 브리핑 읽는 시간: 약 4~5분
- 숫자, 전문용어 최소화, 문장 길이 짧게

## 데일리 브리핑 자동 생성 파이프라인

```
1. 뉴스 수집      - RSS/API로 하루 기사 수집
2. 1차 필터      - 단순 사건사고/단문 기사 제거
3. 분야 분류     - 경제/산업/기술/정책 중 1개 지정
4. 중요도 점수    - 키워드 기반 가점/감점
5. 점수 컷       - 기준 점수 미만 기사 제외
6. 이슈 묶기     - 유사도 비교로 중복 기사 그룹화
7. 대표 기사 선택 - 그룹 내 최고 점수 기사 1개
8. 상위 5개 선정  - 점수 순 + 분야 균형 보정
9. 재창작 요약    - 배경→사건→영향 구조로 요약 (LLM)
10. 브리핑 생성   - 5개 뉴스 + 한 줄 요약 (LLM)
```

## 저작권 가드레일 (필수 준수)

### 재창작(Re-creation)
- 원문의 문장을 복제하지 않음
- 사실관계만 추출하여 완전히 새로운 문장으로 생성
- AI 엔진이 원문을 참조하되, 표현은 독자적으로 재구성

### 단순 링크(Simple Link)
- 원본 뉴스로의 아웃링크를 시스템화
- 모든 콘텐츠에 출처(URL, 언론사명, 작성일시) 필수 표기
- API 응답에도 출처 정보 반드시 포함

### 저작권 준수 체크리스트
- [ ] 원문의 문장을 3단어 이상 연속으로 복제하지 않았는가?
- [ ] 사실관계만 추출하고 표현은 완전히 새롭게 작성했는가?
- [ ] 원본 출처(URL, 언론사, 날짜)가 명확히 표기되었는가?
- [ ] 아웃링크가 올바르게 작동하는가?

## 기술 스택

### Backend
- **Python 3.11+**
- **FastAPI**: 단일 서버, REST API만 제공
- **PostgreSQL**: 뉴스, 브리핑, 사용자 전부 저장
- **Redis**: 선택적 사용 (브리핑 결과 캐시 정도만)
- **SQLAlchemy**: ORM
- **python-dotenv**: 환경변수 관리

### AI Engine
- **Claude API (Anthropic)**
  - 뉴스 재창작 (요약, 브리핑 문장)
  - 판단 로직에는 사용 최소화 (비용/불확실성 관리)

### Frontend
- **Flutter**: 웹 + 모바일 동시 대응
- UI 로직 하나로 유지

### 지금 하지 말 것
- GraphQL
- 실시간 처리
- 복잡한 추천 시스템
- 다중 언어 지원
- 서버 분리, 마이크로서비스

## 프로젝트 구조

```
macnac/
├── backend/
│   ├── app/
│   │   ├── models/       # SQLAlchemy 데이터 모델
│   │   ├── routes/       # API 엔드포인트
│   │   ├── services/     # 비즈니스 로직
│   │   │   ├── claude_service.py    # Claude AI 연동
│   │   │   ├── rss_service.py       # RSS 뉴스 수집
│   │   │   ├── news_filter.py       # 뉴스 필터링
│   │   │   └── news_pipeline.py     # 브리핑 생성 파이프라인
│   │   ├── utils/
│   │   └── prompts/      # AI 프롬프트 템플릿
│   ├── config.py
│   └── main.py
├── frontend/
│   ├── lib/
│   │   ├── screens/      # 화면 위젯
│   │   ├── widgets/      # 재사용 가능한 위젯
│   │   ├── models/       # 데이터 모델
│   │   ├── services/     # API 통신
│   │   ├── providers/    # 상태 관리
│   │   └── main.dart
│   └── pubspec.yaml
└── docs/
```

## 개발 명령어

### 백엔드

```bash
cd backend
pip install -r requirements.txt
python run.py  # http://localhost:8000
```

### 프론트엔드

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

### 환경변수 (.env)

```bash
ANTHROPIC_API_KEY=your_claude_api_key
DATABASE_URL=postgresql://user:password@localhost:5432/macnac
REDIS_URL=redis://localhost:6379/0
DEBUG=True
SECRET_KEY=your_secret_key
```

## UI/UX 디자인 가이드

### 디자인 목표
- 예쁘게 보이는 것보다 **이해가 바로 되는 것**
- 설명 없이도 "어떻게 쓰는지" 느껴지게
- 하루 1회, 5분 사용에 최적화

### 기본 원칙
- **한 화면 = 한 목적**
- 선택지는 최소화
- 읽는 흐름을 끊는 요소 제거
- 위에서 아래로 읽기만 하면 끝
- 버튼 탐색, 메뉴 이동 없음

### 필수 버튼
- 원문 링크 하나뿐
- 좋아요, 공유, 저장은 MVP에서 제거

### 카드/섹션 디자인
- 카드 구분은 여백으로만
- 그림자, 애니메이션 최소화
- 시각적 피로 줄이기

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
error: #D32F2F          // 에러
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

### 금지 사항
- 파란색/보라색 그라데이션 사용 금지
- elevation/그림자 사용 최소화
- 테마 기본값에 의존하지 말 것 (명시적 색상 지정)

## MVP 개발 체크리스트

### Phase 1: 사용자 흐름 수정 (Critical)
- [ ] main.dart: 시작 라우트를 /home으로 변경
- [ ] HomeScreen: 로그인 체크 로직 제거
- [ ] 하단 네비게이션 제거 (설정 버튼 하나로)
- [ ] 브리핑 API: 인증 없이 접근 가능

### Phase 2: 브리핑 구조 개선
- [ ] DailyBriefing 모델에 daily_summary 필드 추가
- [ ] 뉴스 요약 구조: 배경→사건→영향
- [ ] 인과관계/인사이트 섹션 숨김 (MVP)

### Phase 3: 파이프라인 개선
- [ ] 분야 분류 추가 (경제/산업/기술/정책)
- [ ] 중복 기사 그룹화
- [ ] 분야 균형 보정

### Phase 4: UI 간소화
- [ ] 구독 화면 숨김
- [ ] 로그인/회원가입 화면 제거 (MVP)
- [ ] 의견 보내기 폼 추가

### Phase 5: 출시 준비
- [ ] 개인정보처리방침 URL
- [ ] 이용약관 URL
- [ ] 최소 7일치 브리핑 데이터 확보
- [ ] 네트워크 실패 시 graceful 처리

## 출시 전 필수 체크

### 기술
- [ ] 앱 크래시 없는지
- [ ] 네트워크 실패 시 깨지지 않는지
- [ ] 오늘 브리핑 데이터가 항상 존재하는지

### 콘텐츠
- [ ] 빈 화면, 준비 중 화면 제거
- [ ] 출처, 링크 누락 없는지

### 스토어 심사
- [ ] 앱 설명 = 실제 기능과 100% 일치
- [ ] 과장 표현, 미래 기능 언급 제거
- [ ] "AI", "투자" 같은 민감 키워드 절제

### 첫 사용자 경험
- [ ] 설치 → 실행 → 읽기까지 10초 내
- [ ] 회원가입/권한 요청 없음
- [ ] 튜토리얼 없이 이해 가능

## 테스트

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
