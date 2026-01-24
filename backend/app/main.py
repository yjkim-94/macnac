from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from datetime import date
from .config import get_settings
from .routes import auth, news, briefing, feedback
from .database import engine, Base, SessionLocal
from .models import user, news as news_model, subscription, briefing as briefing_model, feedback as feedback_model
from .models.briefing import DailyBriefing

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """앱 시작/종료 시 실행"""
    # 시작 시: 오늘 브리핑 체크
    db = SessionLocal()
    try:
        today = date.today()
        existing = db.query(DailyBriefing).filter(
            DailyBriefing.briefing_date == today
        ).first()

        if not existing:
            print(f"[Startup] 오늘({today}) 브리핑 없음 - 첫 API 호출 시 자동 생성됩니다")
        else:
            print(f"[Startup] 오늘({today}) 브리핑 존재 - {len(existing.news_items)}개 뉴스")
    finally:
        db.close()

    yield  # 앱 실행

    # 종료 시
    print("[Shutdown] 앱 종료")


app = FastAPI(title=settings.app_name, debug=settings.debug, lifespan=lifespan)

# DB 테이블 생성
Base.metadata.create_all(bind=engine)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/v1")
app.include_router(news.router, prefix="/api/v1")
app.include_router(briefing.router, prefix="/api/v1")
app.include_router(feedback.router, prefix="/api/v1")


@app.get("/")
async def root():
    return {"message": "MACNAC API", "version": "1.0.0"}


@app.get("/health")
async def health():
    return {"status": "ok"}
