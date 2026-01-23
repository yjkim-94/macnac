"""브리핑 API"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from datetime import date, datetime, timedelta
from ..database import get_db
from ..models.briefing import DailyBriefing, BriefingNewsItem
from ..services.news_filter import filter_investment_news, calculate_investment_score
from ..services.rss_service import fetch_all_feeds
from ..services.claude_service import recreate_news, analyze_causality, generate_insights
import uuid

router = APIRouter(prefix="/briefing", tags=["briefing"])

# 무료 사용자 보관 기간
FREE_RETENTION_DAYS = 7


@router.get("")
async def get_briefings(
    days: int = Query(FREE_RETENTION_DAYS, ge=1, le=30),
    db: Session = Depends(get_db)
):
    """브리핑 목록 조회 (최근 N일)"""
    cutoff_date = date.today() - timedelta(days=days)

    briefings = db.query(DailyBriefing).filter(
        DailyBriefing.briefing_date >= cutoff_date
    ).order_by(DailyBriefing.briefing_date.desc()).all()

    return {
        "briefings": [
            {
                "id": b.id,
                "date": b.briefing_date.isoformat(),
                "news_count": len(b.news_items),
                "is_today": b.briefing_date == date.today(),
            }
            for b in briefings
        ],
        "retention_days": days,
    }


@router.get("/today")
async def get_today_briefing(db: Session = Depends(get_db)):
    """오늘의 브리핑 조회"""
    today = date.today()

    briefing = db.query(DailyBriefing).filter(
        DailyBriefing.briefing_date == today
    ).first()

    if not briefing:
        raise HTTPException(status_code=404, detail="오늘의 브리핑이 없습니다")

    return _format_briefing(briefing)


@router.get("/{briefing_id}")
async def get_briefing_detail(briefing_id: str, db: Session = Depends(get_db)):
    """브리핑 상세 조회"""
    briefing = db.query(DailyBriefing).filter(
        DailyBriefing.id == briefing_id
    ).first()

    if not briefing:
        raise HTTPException(status_code=404, detail="브리핑을 찾을 수 없습니다")

    return _format_briefing(briefing)


@router.post("/generate")
async def generate_briefing(
    target_date: date = None,
    news_count: int = Query(5, ge=1, le=10),
    db: Session = Depends(get_db)
):
    """브리핑 생성 (RSS 수집 + Claude 분석)"""
    if target_date is None:
        target_date = date.today()

    # 이미 존재하는지 확인
    existing = db.query(DailyBriefing).filter(
        DailyBriefing.briefing_date == target_date
    ).first()

    if existing:
        return {"message": "이미 브리핑이 존재합니다", "briefing_id": existing.id}

    # RSS에서 뉴스 수집
    all_news = fetch_all_feeds(limit_per_feed=7)

    # 투자 관련 뉴스만 필터링
    filtered_news = filter_investment_news(all_news)

    if len(filtered_news) < news_count:
        filtered_news = all_news[:news_count]  # 부족하면 전체에서 선택
    else:
        filtered_news = filtered_news[:news_count]

    # 브리핑 생성
    briefing = DailyBriefing(
        id=str(uuid.uuid4()),
        briefing_date=target_date,
    )
    db.add(briefing)

    # 뉴스 아이템 생성
    for i, news in enumerate(filtered_news):
        original_text = f"{news['title']}. {news['summary']}"

        # Claude API 호출 (선택적)
        try:
            recreated = await recreate_news(original_text)
            causalities = await analyze_causality(original_text)
            insights = await generate_insights(original_text)
        except Exception as e:
            print(f"Claude API error: {e}")
            recreated = {"title": news["title"], "summary": news["summary"]}
            causalities = []
            insights = []

        # 투자 관련성 점수
        score = calculate_investment_score(news["title"], news["summary"])

        item = BriefingNewsItem(
            id=str(uuid.uuid4()),
            briefing_id=briefing.id,
            order=i + 1,
            title=recreated.get("title", news["title"]),
            summary=recreated.get("summary", news["summary"]),
            publisher=news["publisher"],
            source_url=news["source_url"],
            tags=",".join(news.get("tags", [])),
            investment_score=int(score * 100),
        )

        # 인과관계 (첫번째만)
        if causalities:
            item.causality_cause = causalities[0].get("cause", "")
            item.causality_effect = causalities[0].get("effect", "")

        # 인사이트 (첫번째만, 투자 관련성 높은 경우만)
        if insights and score > 0.3:
            item.insight_title = insights[0].get("title", "")
            item.insight_content = insights[0].get("content", "")
            item.insight_type = insights[0].get("type", "neutral")

        db.add(item)

    db.commit()

    return {
        "message": "브리핑 생성 완료",
        "briefing_id": briefing.id,
        "news_count": len(filtered_news),
    }


def _format_briefing(briefing: DailyBriefing) -> dict:
    """브리핑 포맷팅"""
    return {
        "id": briefing.id,
        "date": briefing.briefing_date.isoformat(),
        "is_today": briefing.briefing_date == date.today(),
        "news_items": [
            {
                "id": item.id,
                "order": item.order,
                "title": item.title,
                "summary": item.summary,
                "publisher": item.publisher,
                "source_url": item.source_url,
                "tags": item.tags.split(",") if item.tags else [],
                "investment_score": item.investment_score,
                "causality": {
                    "cause": item.causality_cause,
                    "effect": item.causality_effect,
                } if item.causality_cause else None,
                "insight": {
                    "title": item.insight_title,
                    "content": item.insight_content,
                    "type": item.insight_type,
                } if item.insight_title else None,
            }
            for item in sorted(briefing.news_items, key=lambda x: x.order)
        ],
    }
