"""뉴스 선별 로직 - 투자 관련성 필터링"""

# 투자 관련 키워드
INVESTMENT_KEYWORDS = [
    # 시장
    '코스피', '코스닥', '나스닥', '다우', 'S&P', '주가', '증시', '주식',
    # 금융
    '금리', '환율', '달러', '원화', '채권', '펀드', 'ETF',
    # 기업/산업
    '실적', '매출', '영업이익', '순이익', '수주', '계약', 'IPO', '상장',
    '반도체', 'AI', '전기차', '바이오', '배터리', '2차전지',
    # 경제
    '인플레이션', 'GDP', '경기', '수출', '무역', '금융위원회', '연준', 'Fed',
    # 투자
    '투자', '매수', '매도', '상승', '하락', '급등', '급락', '신고가', '저점',
]

# 제외 키워드 (투자 관련성 낮음)
EXCLUDE_KEYWORDS = [
    '연예', '스포츠', '날씨', '사건사고', '범죄', '정치', '선거',
    '문화', '예능', '드라마', '영화', '음악', '공연',
]


def is_investment_relevant(title: str, summary: str = "") -> bool:
    """투자 관련 뉴스인지 확인"""
    text = f"{title} {summary}".lower()

    # 제외 키워드 체크
    for keyword in EXCLUDE_KEYWORDS:
        if keyword in text:
            return False

    # 투자 키워드 체크
    for keyword in INVESTMENT_KEYWORDS:
        if keyword.lower() in text:
            return True

    return False


def filter_investment_news(articles: list) -> list:
    """투자 관련 뉴스만 필터링"""
    return [
        article for article in articles
        if is_investment_relevant(
            article.get('title', ''),
            article.get('summary', '')
        )
    ]


def calculate_investment_score(title: str, summary: str = "") -> float:
    """투자 관련성 점수 계산 (0.0 ~ 1.0)"""
    text = f"{title} {summary}".lower()

    # 제외 키워드 체크
    for keyword in EXCLUDE_KEYWORDS:
        if keyword in text:
            return 0.0

    # 키워드 매칭 수
    matches = sum(1 for kw in INVESTMENT_KEYWORDS if kw.lower() in text)

    # 점수 계산 (최대 1.0)
    score = min(matches / 3, 1.0)
    return score
