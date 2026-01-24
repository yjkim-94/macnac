"""
뉴스 필터링 및 선별 파이프라인
1. 뉴스 수집 (RSS)
2. 1차 필터 (단문 제거)
3. 분야 분류 (8개 분야)
4. 중요도 점수 계산
5. 점수 컷
6. 분야별 그룹화
7. 분야당 1개 선정
"""

from difflib import SequenceMatcher

# 분야별 키워드 (8개 분야)
CATEGORY_KEYWORDS = {
    "economy": [  # 경제
        "금리", "환율", "달러", "원화", "채권", "인플레이션", "GDP", "경기",
        "수출", "무역", "연준", "Fed", "한은", "기준금리", "물가", "소비자물가",
        "고용", "실업률", "경제성장", "무역수지", "코스피", "코스닥", "주가", "증시",
    ],
    "industry": [  # 산업
        "반도체", "자동차", "조선", "철강", "화학", "건설", "유통", "항공",
        "해운", "제약", "바이오", "2차전지", "배터리", "전기차", "수소",
        "실적", "매출", "영업이익", "순이익", "수주", "계약",
    ],
    "tech": [  # 기술
        "AI", "인공지능", "클라우드", "빅데이터", "5G", "6G", "메타버스",
        "로봇", "자율주행", "드론", "블록체인", "핀테크", "사이버보안",
        "스타트업", "벤처", "플랫폼", "소프트웨어", "앱", "게임",
    ],
    "policy": [  # 정책
        "정부", "국회", "법안", "규제", "세금", "세제", "보조금", "지원",
        "금융위", "공정위", "산업부", "기획재정부", "정책", "제도",
        "무역협정", "FTA", "관세", "장관", "대통령실",
    ],
    "politics": [  # 정치
        "여당", "야당", "국민의힘", "민주당", "선거", "국정감사", "탄핵",
        "대통령", "총리", "의원", "청문회", "외교", "북한", "미국", "중국",
        "정상회담", "안보", "국방", "군사",
    ],
    "society": [  # 사회
        "사건", "사고", "범죄", "재판", "검찰", "경찰", "법원", "판결",
        "교육", "대학", "입시", "부동산", "아파트", "전세", "월세",
        "환경", "날씨", "재해", "의료", "병원", "건강",
    ],
    "entertainment": [  # 연예
        "연예", "아이돌", "배우", "가수", "드라마", "영화", "예능", "음악",
        "콘서트", "앨범", "시청률", "흥행", "넷플릭스", "디즈니", "웨이브",
        "결혼", "열애", "팬미팅", "컴백", "데뷔",
    ],
    "sports": [  # 스포츠
        "축구", "야구", "농구", "배구", "골프", "테니스", "수영", "육상",
        "올림픽", "월드컵", "프로야구", "K리그", "NBA", "MLB", "EPL",
        "감독", "선수", "우승", "경기", "대회", "메달",
    ],
}

# 분야 한글명
CATEGORY_NAMES = {
    "economy": "경제",
    "industry": "산업",
    "tech": "기술",
    "policy": "정책",
    "politics": "정치",
    "society": "사회",
    "entertainment": "연예",
    "sports": "스포츠",
}

# 중요도 가점 키워드
IMPORTANCE_KEYWORDS = [
    "속보", "단독", "긴급", "최초", "최대", "역대", "사상", "돌파",
    "급등", "급락", "폭등", "폭락", "신기록", "충격", "논란",
    "삼성", "SK", "현대", "LG", "카카오", "네이버", "애플", "테슬라",
]

# 최소 요약 길이
MIN_SUMMARY_LENGTH = 30


def run_pipeline(articles: list, target_count: int = None) -> list:
    """전체 파이프라인 실행 (분야당 1개씩 선정)"""
    # target_count가 None이면 분야 수만큼
    if target_count is None:
        target_count = len(CATEGORY_KEYWORDS)

    # 1. 단문 필터
    filtered = filter_basic(articles)
    print(f"[Pipeline] 단문 필터 후: {len(filtered)}개")

    # 2. 분야 분류
    categorized = [classify_category(a) for a in filtered]
    print(f"[Pipeline] 분야 분류 완료")

    # 3. 중요도 점수 계산
    scored = [calculate_score(a) for a in categorized]
    print(f"[Pipeline] 점수 계산 완료")

    # 4. 점수 컷 (0.15 이상만)
    passed = [a for a in scored if a.get("score", 0) >= 0.15]
    print(f"[Pipeline] 점수 컷 후: {len(passed)}개")

    # 5. 분야별 그룹화 후 각 분야에서 1개씩 선정
    final = select_one_per_category(passed)
    print(f"[Pipeline] 분야별 선정: {len(final)}개")

    return final


def filter_basic(articles: list) -> list:
    """1차 필터: 단문 기사만 제거"""
    result = []
    for article in articles:
        summary = article.get("summary", "")

        # 단문 기사 제외
        if len(summary) < MIN_SUMMARY_LENGTH:
            continue

        result.append(article)

    return result


def classify_category(article: dict) -> dict:
    """분야 분류: 경제/산업/기술/정책"""
    title = article.get("title", "")
    summary = article.get("summary", "")
    text = f"{title} {summary}"

    scores = {}
    for category, keywords in CATEGORY_KEYWORDS.items():
        score = sum(1 for kw in keywords if kw in text)
        scores[category] = score

    # 가장 높은 점수의 분야 선택
    if max(scores.values()) > 0:
        best_category = max(scores, key=scores.get)
    else:
        best_category = "economy"  # 기본값

    article["category"] = best_category
    return article


def calculate_score(article: dict) -> dict:
    """중요도 점수 계산"""
    title = article.get("title", "")
    summary = article.get("summary", "")
    text = f"{title} {summary}"

    # 기본 점수
    score = 0.3

    # 분야 키워드 매칭 가점
    category = article.get("category", "economy")
    category_keywords = CATEGORY_KEYWORDS.get(category, [])
    category_matches = sum(1 for kw in category_keywords if kw in text)
    score += min(category_matches * 0.1, 0.3)

    # 중요도 키워드 가점
    importance_matches = sum(1 for kw in IMPORTANCE_KEYWORDS if kw in text)
    score += min(importance_matches * 0.1, 0.3)

    # 제목 길이 보정 (너무 짧으면 감점)
    if len(title) < 20:
        score -= 0.1

    article["score"] = min(max(score, 0.0), 1.0)
    return article


def group_similar_articles(articles: list, threshold: float = 0.5) -> list:
    """중복 기사 그룹화 (제목 유사도 기반)"""
    groups = []
    used = set()

    for i, article in enumerate(articles):
        if i in used:
            continue

        group = [article]
        used.add(i)

        for j, other in enumerate(articles):
            if j in used:
                continue

            similarity = SequenceMatcher(
                None,
                article.get("title", ""),
                other.get("title", "")
            ).ratio()

            if similarity >= threshold:
                group.append(other)
                used.add(j)

        groups.append(group)

    return groups


def select_representatives(groups: list) -> list:
    """각 그룹에서 대표 기사 선택 (최고 점수)"""
    representatives = []
    for group in groups:
        best = max(group, key=lambda x: x.get("score", 0))
        representatives.append(best)
    return representatives


def select_one_per_category(articles: list) -> list:
    """각 분야에서 최고 점수 기사 1개씩 선정"""
    # 분야별 그룹화
    by_category = {}
    for article in articles:
        cat = article.get("category", "economy")
        if cat not in by_category:
            by_category[cat] = []
        by_category[cat].append(article)

    # 각 분야에서 중복 제거 후 최고 점수 1개 선택
    result = []
    for cat in CATEGORY_KEYWORDS.keys():
        if cat not in by_category or not by_category[cat]:
            continue

        # 해당 분야 내 중복 기사 그룹화
        groups = group_similar_articles(by_category[cat])

        # 각 그룹의 대표 기사 중 최고 점수
        representatives = select_representatives(groups)
        if representatives:
            best = max(representatives, key=lambda x: x.get("score", 0))
            best["category_name"] = CATEGORY_NAMES.get(cat, cat)
            result.append(best)

    # 분야 순서대로 정렬
    category_order = list(CATEGORY_KEYWORDS.keys())
    result.sort(key=lambda x: category_order.index(x.get("category", "economy")))

    return result


def select_balanced(articles: list, count: int = 5) -> list:
    """분야 균형 보정하여 상위 N개 선정 (하위 호환)"""
    # 점수순 정렬
    sorted_articles = sorted(articles, key=lambda x: x.get("score", 0), reverse=True)

    if len(sorted_articles) <= count:
        return sorted_articles

    # 분야별 그룹화
    by_category = {}
    for article in sorted_articles:
        cat = article.get("category", "economy")
        if cat not in by_category:
            by_category[cat] = []
        by_category[cat].append(article)

    # 균형 선정: 각 분야에서 최소 1개씩 (가능하면)
    result = []
    categories = list(by_category.keys())

    # 1단계: 각 분야에서 1개씩 선택
    for cat in categories:
        if by_category[cat] and len(result) < count:
            result.append(by_category[cat].pop(0))

    # 2단계: 나머지는 점수순으로 채움
    remaining = []
    for cat in categories:
        remaining.extend(by_category[cat])
    remaining.sort(key=lambda x: x.get("score", 0), reverse=True)

    for article in remaining:
        if len(result) >= count:
            break
        result.append(article)

    return result


# 하위 호환성 유지
def is_investment_relevant(title: str, summary: str = "") -> bool:
    """투자 관련 뉴스인지 확인 (하위 호환)"""
    text = f"{title} {summary}"
    if any(kw in text for kw in EXCLUDE_KEYWORDS):
        return False
    for keywords in CATEGORY_KEYWORDS.values():
        if any(kw in text for kw in keywords):
            return True
    return False


def filter_investment_news(articles: list) -> list:
    """투자 관련 뉴스만 필터링 (하위 호환)"""
    return [a for a in articles if is_investment_relevant(a.get("title", ""), a.get("summary", ""))]


def calculate_investment_score(title: str, summary: str = "") -> float:
    """투자 관련성 점수 (하위 호환)"""
    article = {"title": title, "summary": summary}
    article = classify_category(article)
    article = calculate_score(article)
    return article.get("score", 0.0)
