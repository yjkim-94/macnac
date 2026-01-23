from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.news import NewsArticle, CausalityAnalysis, Insight
from ..services.claude_service import recreate_news, analyze_causality, generate_insights

router = APIRouter(prefix="/news", tags=["news"])


class AnalyzeRequest(BaseModel):
    text: str


@router.get("")
async def get_news_list(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    sort_by: str = Query("latest"),
    db: Session = Depends(get_db)
):
    offset = (page - 1) * limit
    query = db.query(NewsArticle)
    if sort_by == "latest":
        query = query.order_by(NewsArticle.created_at.desc())
    articles = query.offset(offset).limit(limit).all()
    total = db.query(NewsArticle).count()
    return {
        "articles": [{"id": a.id, "title": a.title, "summary": a.summary, "image_url": a.image_url,
                      "publisher": a.publisher, "source_url": a.source_url, "published_at": a.original_published_at.isoformat(),
                      "tile_size": a.tile_size, "tags": a.tags} for a in articles],
        "total": total, "page": page, "limit": limit, "has_more": offset + limit < total
    }


@router.get("/{news_id}")
async def get_news_detail(news_id: str, db: Session = Depends(get_db)):
    article = db.query(NewsArticle).filter(NewsArticle.id == news_id).first()
    if not article:
        raise HTTPException(status_code=404, detail="뉴스를 찾을 수 없습니다.")
    return {
        "article": {"id": article.id, "title": article.title, "summary": article.summary, "image_url": article.image_url,
                    "publisher": article.publisher, "source_url": article.source_url, "published_at": article.original_published_at.isoformat(),
                    "tile_size": article.tile_size, "tags": article.tags},
        "recreated_content": article.recreated_content,
        "causalities": [{"cause": c.cause, "effect": c.effect, "confidence": c.confidence} for c in article.causalities],
        "insights": [{"title": i.title, "content": i.content, "type": i.insight_type, "importance": i.importance} for i in article.insights],
        "related_tags": article.tags
    }


@router.post("/analyze/recreate")
async def analyze_recreate(req: AnalyzeRequest):
    """원문을 재창작 (저작권 준수)"""
    return await recreate_news(req.text)


@router.post("/analyze/causality")
async def analyze_causality_endpoint(req: AnalyzeRequest):
    """인과관계 분석"""
    return await analyze_causality(req.text)


@router.post("/analyze/insights")
async def analyze_insights_endpoint(req: AnalyzeRequest):
    """투자 인사이트 생성"""
    return await generate_insights(req.text)
