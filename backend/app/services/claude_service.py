import json
import logging
import re
from anthropic import Anthropic
from ..config import get_settings
from ..prompts.templates import RECREATION_PROMPT, DAILY_SUMMARY_PROMPT
# MVP 이후: CAUSALITY_PROMPT, INSIGHT_PROMPT

settings = get_settings()
client = Anthropic(api_key=settings.anthropic_api_key)
logger = logging.getLogger(__name__)


def calculate_similarity(text1: str, text2: str) -> float:
    """두 텍스트의 단어 기반 유사도 계산 (Jaccard)"""
    if not text1 or not text2:
        return 0.0
    words1 = set(text1.lower().split())
    words2 = set(text2.lower().split())
    if not words1 or not words2:
        return 0.0
    intersection = words1 & words2
    union = words1 | words2
    return len(intersection) / len(union)


def validate_recreation(original_text: str, recreated: dict) -> tuple[bool, str]:
    """재작성 결과 검증 (완화된 조건)"""
    title = recreated.get("title", "")
    summary = recreated.get("summary", "")

    # 제목이 비어있으면 실패
    if not title or len(title) < 5:
        return False, "제목이 너무 짧음"

    # 요약이 비어있으면 실패 (20자 이상이면 OK)
    if not summary or len(summary) < 20:
        return False, "요약이 너무 짧음"

    # 본문 유사도 체크 (60% 이상이면 실패 - 완화)
    summary_similarity = calculate_similarity(original_text, summary)
    if summary_similarity > 0.6:
        return False, f"본문 유사도 높음: {summary_similarity:.2f}"

    return True, "OK"


async def recreate_news(original_text: str, max_retries: int = 3) -> dict:
    """뉴스 재창작 (저작권 준수, 검증 포함)"""
    last_result = None

    for attempt in range(max_retries + 1):
        try:
            response = client.messages.create(
                model="claude-3-haiku-20240307",
                max_tokens=2048,
                messages=[{"role": "user", "content": RECREATION_PROMPT.format(original_text=original_text)}]
            )

            # 응답 텍스트
            raw_text = response.content[0].text.strip()

            # 정규식으로 title과 summary 직접 추출 (JSON 파싱 우회)
            title_match = re.search(r'"title"[:\s]*"?([^"]+)"?', raw_text)
            summary_match = re.search(r'"summary"[:\s]*"?(.+?)(?:"\s*}|$)', raw_text, re.DOTALL)

            if title_match and summary_match:
                title = title_match.group(1).strip().strip('"').strip("'")
                summary = summary_match.group(1).strip().strip('"').strip("'")
                # 연속 공백/줄바꿈 정리
                summary = re.sub(r'\s+', ' ', summary)
                result = {"title": title, "summary": summary}
            else:
                # 정규식 실패 시 JSON 파싱 시도
                text = raw_text
                if "```json" in text:
                    text = text.split("```json")[1].split("```")[0].strip()
                elif "```" in text:
                    parts = text.split("```")
                    if len(parts) >= 2:
                        text = parts[1].strip()
                result = json.loads(text)
            last_result = result

            # 검증
            is_valid, reason = validate_recreation(original_text, result)
            if is_valid:
                return result

            logger.warning(f"재창작 검증 실패 (시도 {attempt + 1}/{max_retries + 1}): {reason}")

        except json.JSONDecodeError as e:
            logger.warning(f"JSON 파싱 실패 (시도 {attempt + 1}): {e}")
            print(f"  [DEBUG] 파싱 실패 텍스트: {text[:200] if 'text' in dir() else 'N/A'}...")
        except Exception as e:
            logger.warning(f"재창작 오류 (시도 {attempt + 1}): {e}")

    # 최대 재시도 후에도 실패하면 마지막 결과 또는 기본값 반환
    if last_result:
        logger.error(f"재창작 검증 최종 실패, 마지막 결과 사용: {original_text[:30]}...")
        return last_result

    # 완전 실패 시 기본 재작성 시도
    logger.error(f"재창작 완전 실패: {original_text[:30]}...")
    return {
        "title": original_text[:50] + "..." if len(original_text) > 50 else original_text,
        "summary": "해당 뉴스의 상세 내용은 원문을 참조해 주세요."
    }


# MVP 이후 기능 (현재 미사용)
# async def analyze_causality(news_content: str) -> list:
#     """인과관계 분석"""
#     response = client.messages.create(
#         model="claude-3-haiku-20240307",
#         max_tokens=1024,
#         messages=[{"role": "user", "content": CAUSALITY_PROMPT.format(news_content=news_content)}]
#     )
#     return json.loads(response.content[0].text)


# async def generate_insights(news_content: str) -> list:
#     """투자 인사이트 생성"""
#     response = client.messages.create(
#         model="claude-3-haiku-20240307",
#         max_tokens=1024,
#         messages=[{"role": "user", "content": INSIGHT_PROMPT.format(news_content=news_content)}]
#     )
#     return json.loads(response.content[0].text)


async def generate_daily_summary(news_titles: list) -> str:
    """오늘의 요약 생성 (1~2문장)"""
    titles_text = "\n".join([f"- {title}" for title in news_titles])
    response = client.messages.create(
        model="claude-3-haiku-20240307",
        max_tokens=2048,
        messages=[{"role": "user", "content": DAILY_SUMMARY_PROMPT.format(news_titles=titles_text)}]
    )
    return response.content[0].text.strip()
