"""7일치 브리핑 데이터 생성 스크립트"""
import asyncio
import sys
import os
from datetime import date, timedelta

# 상위 디렉토리를 path에 추가
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database import SessionLocal, engine, Base
from app.models.briefing import DailyBriefing, BriefingNewsItem
from app.services.rss_service import fetch_all_feeds
from app.services.news_filter import run_pipeline
from app.services.claude_service import recreate_news, generate_daily_summary
import uuid


async def generate_briefing_for_date(target_date: date, db):
    """특정 날짜의 브리핑 생성"""
    print(f"\n{'='*50}")
    print(f"[{target_date}] 브리핑 생성 시작...")

    # 이미 존재하는지 확인
    existing = db.query(DailyBriefing).filter(
        DailyBriefing.briefing_date == target_date
    ).first()

    if existing:
        print(f"[{target_date}] 이미 존재함, 건너뜀")
        return False

    # RSS에서 뉴스 수집
    print(f"[{target_date}] RSS 뉴스 수집 중...")
    all_news = fetch_all_feeds(limit_per_feed=10)
    print(f"[{target_date}] 수집된 뉴스: {len(all_news)}개")

    # 파이프라인 실행
    filtered_news = run_pipeline(all_news)
    print(f"[{target_date}] 필터링 후: {len(filtered_news)}개")

    if len(filtered_news) == 0:
        print(f"[{target_date}] 뉴스가 없어서 건너뜀")
        return False

    # 뉴스 재창작
    news_items_data = []
    recreated_titles = []

    for i, news in enumerate(filtered_news):
        print(f"[{target_date}] 뉴스 {i+1}/{len(filtered_news)} 재창작 중...")
        original_text = f"{news['title']}. {news['summary']}"

        try:
            recreated = await recreate_news(original_text)
        except Exception as e:
            print(f"  Claude API 오류: {e}")
            recreated = {"title": news["title"], "summary": news["summary"]}

        recreated_titles.append(recreated.get("title", news["title"]))
        news_items_data.append((news, recreated))

    # 한 줄 요약 생성
    print(f"[{target_date}] 한 줄 요약 생성 중...")
    try:
        daily_summary = await generate_daily_summary(recreated_titles)
    except Exception as e:
        print(f"  요약 생성 오류: {e}")
        daily_summary = None

    # 브리핑 저장
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
    print(f"[{target_date}] 브리핑 생성 완료! (뉴스 {len(news_items_data)}개)")
    return True


async def main():
    """7일치 브리핑 생성"""
    print("=" * 50)
    print("7일치 브리핑 데이터 생성")
    print("=" * 50)

    # DB 테이블 생성
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()

    try:
        today = date.today()
        success_count = 0

        for i in range(7):
            target_date = today - timedelta(days=i)
            result = await generate_briefing_for_date(target_date, db)
            if result:
                success_count += 1

            # API 호출 간격 (rate limit 방지)
            if i < 6:
                print("\n잠시 대기 중... (3초)")
                await asyncio.sleep(3)

        print("\n" + "=" * 50)
        print(f"완료! {success_count}개 브리핑 생성됨")
        print("=" * 50)

    finally:
        db.close()


if __name__ == "__main__":
    asyncio.run(main())
