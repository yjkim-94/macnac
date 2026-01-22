# MACNAC Backend

FastAPI 기반 REST API 서버

## 실행 방법

### 1. 의존성 설치
```bash
cd backend
pip install -r requirements.txt
```

### 2. 환경변수 설정
```bash
cp .env.example .env
# .env 파일 수정
```

### 3. 서버 실행 (Mock 데이터 자동 시딩)
```bash
python run.py
```

### 4. API 확인
- http://localhost:8000 (루트)
- http://localhost:8000/docs (Swagger UI)

## API 엔드포인트

- `POST /api/v1/auth/login` - 로그인
- `POST /api/v1/auth/register` - 회원가입
- `GET /api/v1/news` - 뉴스 목록
- `GET /api/v1/news/{id}` - 뉴스 상세

## 테스트 계정
- Email: test@test.com
- Password: test1234

