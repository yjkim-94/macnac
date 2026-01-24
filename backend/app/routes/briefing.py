"""브리핑 API"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from datetime import date, timedelta
from ..database import get_db
from ..models.briefing import DailyBriefing, BriefingNewsItem
from ..services.news_filter import run_pipeline
from ..services.rss_service import fetch_all_feeds
from ..services.claude_service import recreate_news, generate_daily_summary
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
    news_count: int = Query(8, ge=1, le=15, description="분야당 1개씩 (기본 8개)"),
    force: bool = Query(False, description="기존 브리핑 삭제 후 재생성"),
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
        if force:
            # 기존 브리핑 삭제 (뉴스 아이템도 cascade 삭제)
            db.query(BriefingNewsItem).filter(
                BriefingNewsItem.briefing_id == existing.id
            ).delete()
            db.delete(existing)
            db.commit()
        else:
            return {"message": "이미 브리핑이 존재합니다", "briefing_id": existing.id}

    # RSS에서 뉴스 수집
    all_news = fetch_all_feeds(limit_per_feed=10)

    # 파이프라인 실행 (필터링 + 분류 + 중복제거 + 균형선정)
    filtered_news = run_pipeline(all_news, target_count=news_count)

    if len(filtered_news) < news_count:
        # 부족하면 전체에서 추가 선택
        filtered_news = all_news[:news_count]

    # 뉴스 아이템 생성 (먼저 재창작하여 제목 수집)
    news_items_data = []
    recreated_titles = []

    for i, news in enumerate(filtered_news):
        original_text = f"{news['title']}. {news['summary']}"

        # Claude API 호출 (재창작)
        try:
            recreated = await recreate_news(original_text)
        except Exception as e:
            print(f"Claude API error: {e}")
            recreated = {"title": news["title"], "summary": news["summary"]}

        recreated_titles.append(recreated.get("title", news["title"]))
        news_items_data.append((news, recreated))

    # 한 줄 요약 생성
    try:
        daily_summary = await generate_daily_summary(recreated_titles)
    except Exception as e:
        print(f"Daily summary error: {e}")
        daily_summary = None

    # 브리핑 생성
    briefing = DailyBriefing(
        id=str(uuid.uuid4()),
        briefing_date=target_date,
        daily_summary=daily_summary,
    )
    db.add(briefing)

    # 뉴스 아이템 저장
    for i, (news, recreated) in enumerate(news_items_data):
        item = BriefingNewsItem(
            id=str(uuid.uuid4()),
            briefing_id=briefing.id,
            order=i + 1,
            title=recreated.get("title", news["title"]),
            summary=recreated.get("summary", news["summary"]),
            publisher=news["publisher"],
            source_url=news["source_url"],
            category=news.get("category", "economy"),
        )
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
        "daily_summary": briefing.daily_summary,
        "is_today": briefing.briefing_date == date.today(),
        "news_items": [
            {
                "id": item.id,
                "order": item.order,
                "title": item.title,
                "summary": item.summary,
                "publisher": item.publisher,
                "source_url": item.source_url,
                "category": item.category,
            }
            for item in sorted(briefing.news_items, key=lambda x: x.order)
        ],
    }
