import json
from anthropic import Anthropic
from ..config import get_settings
from ..prompts.templates import RECREATION_PROMPT, CAUSALITY_PROMPT, INSIGHT_PROMPT, DAILY_SUMMARY_PROMPT

settings = get_settings()
client = Anthropic(api_key=settings.anthropic_api_key)


async def recreate_news(original_text: str) -> dict:
    """뉴스 재창작 (저작권 준수)"""
    response = client.messages.create(
        model="claude-3-haiku-20240307",
        max_tokens=1024,
        messages=[{"role": "user", "content": RECREATION_PROMPT.format(original_text=original_text)}]
    )
    return json.loads(response.content[0].text)


async def analyze_causality(news_content: str) -> list:
    """인과관계 분석"""
    response = client.messages.create(
        model="claude-3-haiku-20240307",
        max_tokens=1024,
        messages=[{"role": "user", "content": CAUSALITY_PROMPT.format(news_content=news_content)}]
    )
    return json.loads(response.content[0].text)


async def generate_insights(news_content: str) -> list:
    """투자 인사이트 생성 (MVP 이후)"""
    response = client.messages.create(
        model="claude-3-haiku-20240307",
        max_tokens=1024,
        messages=[{"role": "user", "content": INSIGHT_PROMPT.format(news_content=news_content)}]
    )
    return json.loads(response.content[0].text)


async def generate_daily_summary(news_titles: list) -> str:
    """오늘의 한 줄 요약 생성"""
    titles_text = "\n".join([f"- {title}" for title in news_titles])
    response = client.messages.create(
        model="claude-3-haiku-20240307",
        max_tokens=100,
        messages=[{"role": "user", "content": DAILY_SUMMARY_PROMPT.format(news_titles=titles_text)}]
    )
    return response.content[0].text.strip()
