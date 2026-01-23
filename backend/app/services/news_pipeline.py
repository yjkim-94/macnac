"""뉴스 수집 및 분석 파이프라인"""
import uuid
from datetime import datetime
from sqlalchemy.orm import Session
from .rss_service import fetch_all_feeds
from .claude_service import recreate_news
from ..models.news import NewsArticle, CausalityAnalysis, Insight
from ..database import SessionLocal


async def process_single_news(article: dict, db: Session) -> NewsArticle | None:
    """단일 뉴스 처리: 재창작 + 분석 + DB 저장"""
    # 중복 체크
    exists = db.query(NewsArticle).filter(NewsArticle.source_url == article["source_url"]).first()
    if exists:
        return None

    original_text = f"{article['title']}. {article['summary']}"

    try:
        # Claude API 호출
        recreated = await recreate_news(original_text)
    except Exception as e:
        print(f"Claude API error: {e}")
        # API 실패시 원본 사용
        recreated = {"title": article["title"], "summary": article["summary"], "content": article["summary"]}

    # MVP: 인과관계/인사이트 미사용
    causalities = []
    insights = []

    # DB 저장
    news = NewsArticle(
        id=str(uuid.uuid4()),
        title=recreated.get("title", article["title"]),
        summary=recreated.get("summary", article["summary"]),
        recreated_content=recreated.get("content", ""),
        publisher=article["publisher"],
        source_url=article["source_url"],
        original_published_at=datetime.now(),
        tile_size="small",
        tags=[],
    )
    db.add(news)

    for c in causalities:
        db.add(CausalityAnalysis(article_id=news.id, cause=c["cause"], effect=c["effect"], confidence=c.get("confidence", 0.8)))

    for i in insights:
        db.add(Insight(article_id=news.id, title=i["title"], content=i["content"], insight_type=i.get("type", "neutral"), importance=i.get("importance", 0.5)))

    db.commit()
    return news


async def run_pipeline(limit: int = 5) -> dict:
    """전체 파이프라인 실행"""
    db = SessionLocal()
    articles = fetch_all_feeds(limit)
    processed = 0
    skipped = 0

    for article in articles:
        result = await process_single_news(article, db)
        if result:
            processed += 1
        else:
            skipped += 1

    db.close()
    return {"processed": processed, "skipped": skipped, "total": len(articles)}
