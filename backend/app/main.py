from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .config import get_settings
from .routes import auth, news, briefing
from .database import engine, Base
from .models import user, news as news_model, subscription, briefing as briefing_model

settings = get_settings()

app = FastAPI(title=settings.app_name, debug=settings.debug)

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


@app.get("/")
async def root():
    return {"message": "MACNAC API", "version": "1.0.0"}


@app.get("/health")
async def health():
    return {"status": "ok"}
