# MACNAC Backend

FastAPI 기반 REST API 서버

## 실행 방법

### 1. Conda 환경 생성
```bash
conda create -n macnac python=3.11 -y
conda activate macnac
```

### 2. 의존성 설치
```bash
cd backend
pip install -r requirements.txt
pip install feedparser bcrypt anthropic
```

### 3. 환경변수 설정
```bash
cp .env.example .env
# ANTHROPIC_API_KEY 설정 (Claude API 사용시)
```

### 4. 서버 실행
```bash
python run.py
```

### 5. API 확인
- http://localhost:8000 (루트)
- http://localhost:8000/docs (Swagger UI)

## 주요 API

### 브리핑 생성 (curl)
```bash
# 오늘 브리핑 생성
curl -X POST http://localhost:8000/api/v1/briefing/generate

# 강제 재생성 (기존 브리핑 삭제 후 재생성)
curl -X POST "http://localhost:8000/api/v1/briefing/generate?force=true"

# 뉴스 개수 지정 (기본 5개)
curl -X POST "http://localhost:8000/api/v1/briefing/generate?news_count=3"
```

### 브리핑 조회
```bash
# 오늘 브리핑 조회
curl http://localhost:8000/api/v1/briefing/today

# 최근 N일 브리핑 목록
curl "http://localhost:8000/api/v1/briefing?days=7"
```

### 뉴스
- `GET /api/v1/news/rss/fetch` - RSS 뉴스 수집 테스트

## RSS 피드 지원
- 한국경제, 매일경제, 서울경제, 이데일리, 머니투데이 (경제)
- ZDNet Korea, 전자신문 (IT/산업)
- 연합뉴스TV (종합)

## 저작권 검증
```bash
python tests/test_copyright.py
```
