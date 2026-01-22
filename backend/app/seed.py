"""Mock 데이터 시딩 스크립트"""
from datetime import datetime, timedelta
from .database import SessionLocal, engine, Base
from .models.news import NewsArticle, CausalityAnalysis, Insight
from .models.user import User
from .models.subscription import ToppingModule
from .services.auth_service import hash_password

# 테이블 생성
Base.metadata.create_all(bind=engine)

def seed():
    db = SessionLocal()

    # 테스트 유저
    if not db.query(User).first():
        db.add(User(id="1", email="test@test.com", hashed_password=hash_password("test1234"), name="테스트 사용자"))

    # 토핑 모듈
    if not db.query(ToppingModule).first():
        modules = [
            ToppingModule(id="1", name="인과관계 분석", description="뉴스의 원인-결과 관계 분석", price=4900),
            ToppingModule(id="2", name="투자 인사이트", description="AI 기반 투자 인사이트", price=9900),
            ToppingModule(id="3", name="실시간 알림", description="관심 키워드 실시간 알림", price=2900),
        ]
        db.add_all(modules)

    # Mock 뉴스
    if not db.query(NewsArticle).first():
        articles = [
            {"id": "1", "title": "테슬라, 3분기 실적 발표... 전년比 20% 증가", "summary": "테슬라가 3분기 실적을 발표하며 전년 대비 매출 20% 증가를 기록했습니다.", "recreated_content": "테슬라의 3분기 매출이 전년 동기 대비 20% 성장했다. 전기차 판매량 증가와 에너지 사업 확대가 주요 요인으로 분석된다.", "publisher": "경제신문", "source_url": "https://example.com/1", "tile_size": "large", "tags": ["테슬라", "실적"]},
            {"id": "2", "title": "반도체 시장 회복세... 삼성전자 주가 상승", "summary": "반도체 시장의 회복세에 따라 삼성전자 주가가 급등했습니다.", "recreated_content": "글로벌 반도체 수요 회복으로 삼성전자 주가가 상승세를 보이고 있다. 메모리 반도체 가격 반등이 실적 개선 기대감을 높이고 있다.", "publisher": "기술뉴스", "source_url": "https://example.com/2", "tile_size": "small", "tags": ["반도체", "삼성전자"]},
            {"id": "3", "title": "금리 인하 전망에 부동산 시장 활기", "summary": "중앙은행의 금리 인하 전망으로 부동산 거래량이 증가하고 있습니다.", "recreated_content": "금리 인하 기대감에 부동산 시장이 활기를 띠고 있다. 주택담보대출 금리 하락 전망이 매수 심리를 자극하고 있다.", "publisher": "부동산뉴스", "source_url": "https://example.com/3", "tile_size": "small", "tags": ["부동산", "금리"]},
            {"id": "4", "title": "AI 스타트업 시리즈 B 투자 유치 성공", "summary": "AI 기반 서비스를 제공하는 스타트업이 대규모 투자를 유치했습니다.", "recreated_content": "국내 AI 스타트업이 시리즈 B 라운드에서 500억원 규모의 투자를 유치했다. 생성형 AI 기술력을 인정받아 글로벌 VC들의 관심을 받았다.", "publisher": "스타트업뉴스", "source_url": "https://example.com/4", "tile_size": "wide", "tags": ["AI", "투자"]},
            {"id": "5", "title": "코스피 2,700선 회복... 외국인 순매수 지속", "summary": "코스피 지수가 2,700선을 회복하며 상승세를 이어가고 있습니다.", "recreated_content": "코스피가 2,700선을 회복했다. 외국인 투자자들의 지속적인 순매수가 지수 상승을 이끌고 있다.", "publisher": "증권뉴스", "source_url": "https://example.com/5", "tile_size": "small", "tags": ["코스피", "주식"]},
            {"id": "6", "title": "전기차 배터리 기술 혁신... 주행거리 2배 증가", "summary": "신규 배터리 기술로 전기차 주행거리가 크게 향상될 전망입니다.", "recreated_content": "차세대 전고체 배터리 기술이 상용화 단계에 접어들었다. 기존 대비 에너지 밀도가 2배 향상되어 주행거리가 대폭 늘어날 전망이다.", "publisher": "과학기술", "source_url": "https://example.com/6", "tile_size": "tall", "tags": ["전기차", "배터리"]},
        ]
        for a in articles:
            article = NewsArticle(**a, original_published_at=datetime.now() - timedelta(hours=len(articles)))
            db.add(article)
            # 인과관계
            db.add(CausalityAnalysis(article_id=a["id"], cause=f"{a['tags'][0]} 관련 이슈 발생", effect="시장 반응 및 투자자 관심 증가", confidence=0.85))
            # 인사이트
            db.add(Insight(article_id=a["id"], title=f"{a['tags'][0]} 투자 포인트", content=f"{a['tags'][0]} 관련 종목에 주목할 필요가 있습니다.", insight_type="positive", importance=0.7))

    db.commit()
    db.close()
    print("Seed 완료!")

if __name__ == "__main__":
    seed()
