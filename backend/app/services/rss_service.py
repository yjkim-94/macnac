"""RSS 뉴스 수집 서비스"""
import feedparser
from datetime import datetime

# 한국 뉴스 RSS 피드
RSS_FEEDS = {
    # 종합 일간지
    "chosun": "https://www.chosun.com/arc/outboundfeeds/rss/?outputType=xml",  # 조선일보
    "joongang": "https://rss.joins.com/joins_news_list.xml",        # 중앙일보
    "donga": "https://rss.donga.com/total.xml",                     # 동아일보
    "hani": "https://www.hani.co.kr/rss/",                          # 한겨레
    "khan": "https://www.khan.co.kr/rss/rssdata/total_news.xml",    # 경향신문
    # 방송사
    "kbs": "https://news.kbs.co.kr/api/rss/main.html",              # KBS
    "sbs": "https://news.sbs.co.kr/news/RSS.do?plink=RSSREADER",    # SBS
    "ytn": "https://www.ytn.co.kr/rss/headline.xml",                # YTN
    "jtbc": "https://fs.jtbc.co.kr/RSS/newsflash.xml",              # JTBC
    # 경제 전문
    "hankyung": "https://www.hankyung.com/feed/all-news",           # 한국경제
    "mk": "https://www.mk.co.kr/rss/30000001/",                     # 매일경제
    "sedaily": "https://www.sedaily.com/RSS/Economy",               # 서울경제
    "edaily": "https://www.edaily.co.kr/rss/economy.xml",           # 이데일리
    "mt": "https://rss.mt.co.kr/mt_economy.xml",                    # 머니투데이
    # IT/기술
    "zdnet": "https://zdnet.co.kr/rss/all.xml",                     # ZDNet Korea
    "etnews": "https://rss.etnews.com/Section901.xml",              # 전자신문
    # 연예/스포츠
    "sportschosun": "https://sports.chosun.com/rss/rss.htm",        # 스포츠조선
    "sportsdonga": "https://rss.donga.com/sports.xml",              # 스포츠동아
    # 통신사
    "yonhap": "https://www.yonhapnewstv.co.kr/browse/feed/",        # 연합뉴스
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
