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

## API 엔드포인트

### 인증
- `POST /api/v1/auth/login` - 로그인
- `POST /api/v1/auth/register` - 회원가입

### 뉴스
- `GET /api/v1/news` - 뉴스 목록
- `GET /api/v1/news/{id}` - 뉴스 상세
- `GET /api/v1/news/rss/fetch` - RSS 뉴스 수집

### AI 분석 (Claude API 필요)
- `POST /api/v1/news/analyze/recreate` - 뉴스 재창작
- `POST /api/v1/news/analyze/causality` - 인과관계 분석
- `POST /api/v1/news/analyze/insights` - 투자 인사이트

## 테스트 계정
- Email: test@test.com
- Password: test1234

## RSS 피드 지원
- 한국경제
- 매일경제
- 서울경제

## 저작권 검증
```bash
python tests/test_copyright.py
```
