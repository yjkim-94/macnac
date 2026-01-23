"""RSS 뉴스 수집 서비스"""
import feedparser
from datetime import datetime

# 한국 경제 뉴스 RSS 피드
RSS_FEEDS = {
    "hankyung": "https://www.hankyung.com/feed/all-news",
    "mk": "https://www.mk.co.kr/rss/30000001/",
    "sedaily": "https://www.sedaily.com/RSS/Economy",
}


def fetch_rss(feed_url: str, limit: int = 10) -> list:
    """RSS 피드에서 뉴스 수집"""
    feed = feedparser.parse(feed_url)
    articles = []

    for entry in feed.entries[:limit]:
        articles.append({
            "title": entry.get("title", ""),
            "summary": entry.get("summary", entry.get("description", "")),
            "source_url": entry.get("link", ""),
            "published_at": entry.get("published", ""),
            "publisher": feed.feed.get("title", "Unknown"),
        })

    return articles


def fetch_all_feeds(limit_per_feed: int = 5) -> list:
    """모든 RSS 피드에서 뉴스 수집"""
    all_articles = []

    for name, url in RSS_FEEDS.items():
        try:
            articles = fetch_rss(url, limit_per_feed)
            all_articles.extend(articles)
        except Exception as e:
            print(f"RSS fetch error ({name}): {e}")

    return all_articles


if __name__ == "__main__":
    articles = fetch_all_feeds(3)
    for a in articles:
        print(f"[{a['publisher']}] {a['title'][:30]}...")
