"""저작권 준수 검증 테스트"""
import re


def check_consecutive_words(original: str, recreated: str, max_consecutive: int = 3) -> bool:
    """원문과 재창작 텍스트 간 연속 단어 중복 검사

    Returns:
        True: 저작권 준수 (중복 없음)
        False: 저작권 위반 (중복 있음)
    """
    original_words = re.findall(r'\w+', original.lower())
    recreated_words = re.findall(r'\w+', recreated.lower())

    for i in range(len(recreated_words) - max_consecutive + 1):
        phrase = recreated_words[i:i + max_consecutive]
        for j in range(len(original_words) - max_consecutive + 1):
            if original_words[j:j + max_consecutive] == phrase:
                return False
    return True


def check_analysis_ratio(summary_len: int, analysis_len: int, min_ratio: float = 1.0) -> bool:
    """분석(인과관계+인사이트)이 요약보다 많은지 검사

    Returns:
        True: 주종관계 준수 (분석 >= 요약)
        False: 주종관계 위반
    """
    if summary_len == 0:
        return True
    return analysis_len / summary_len >= min_ratio


def check_source_info(data: dict) -> bool:
    """출처 정보 포함 여부 검사

    Returns:
        True: 출처 정보 있음
        False: 출처 정보 없음
    """
    required = ['source_url', 'publisher']
    return all(data.get(field) for field in required)


def validate_copyright(original: str, recreated: dict) -> dict:
    """전체 저작권 검증

    Args:
        original: 원본 텍스트
        recreated: {"summary": str, "causalities": list, "insights": list, "source_url": str, "publisher": str}

    Returns:
        {"valid": bool, "errors": list}
    """
    errors = []

    # 1. 연속 단어 검사
    if not check_consecutive_words(original, recreated.get('summary', '')):
        errors.append("3단어 이상 연속 복제 감지")

    # 2. 주종관계 검사
    summary_len = len(recreated.get('summary', ''))
    analysis_len = sum(len(str(c)) for c in recreated.get('causalities', [])) + \
                   sum(len(str(i)) for i in recreated.get('insights', []))
    if not check_analysis_ratio(summary_len, analysis_len):
        errors.append("분석 콘텐츠가 요약보다 적음")

    # 3. 출처 정보 검사
    if not check_source_info(recreated):
        errors.append("출처 정보 누락")

    return {"valid": len(errors) == 0, "errors": errors}


# 테스트 케이스
if __name__ == "__main__":
    # 테스트 1: 정상 케이스
    original = "테슬라가 3분기 실적을 발표하며 전년 대비 매출 20% 증가를 기록했습니다."
    recreated = {
        "summary": "전기차 기업 테슬라의 3분기 매출이 전년 동기 대비 20% 성장했다.",
        "causalities": [{"cause": "전기차 수요 증가", "effect": "매출 상승"}],
        "insights": [{"title": "테슬라 투자 포인트", "content": "실적 개선으로 주가 상승 기대"}],
        "source_url": "https://example.com/1",
        "publisher": "경제신문"
    }
    result = validate_copyright(original, recreated)
    print(f"테스트 1 (정상): {result}")

    # 테스트 2: 복제 위반
    recreated_bad = {
        "summary": "테슬라가 3분기 실적을 발표하며 매출이 증가했습니다.",  # 원문 복제
        "causalities": [],
        "insights": [],
        "source_url": "https://example.com/1",
        "publisher": "경제신문"
    }
    result = validate_copyright(original, recreated_bad)
    print(f"테스트 2 (복제): {result}")

    # 테스트 3: 출처 누락
    recreated_no_source = {
        "summary": "전기차 기업의 매출이 크게 성장했다.",
        "causalities": [{"cause": "수요 증가", "effect": "매출 상승"}],
        "insights": [{"title": "투자 포인트", "content": "주가 상승 기대"}],
        "source_url": "",
        "publisher": ""
    }
    result = validate_copyright(original, recreated_no_source)
    print(f"테스트 3 (출처누락): {result}")
