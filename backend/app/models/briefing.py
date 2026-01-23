"""데일리 브리핑 모델"""
from datetime import datetime, date
from sqlalchemy import Column, String, DateTime, Date, Integer, ForeignKey, Text, Boolean
from sqlalchemy.orm import relationship
from ..database import Base
import uuid


class DailyBriefing(Base):
    """데일리 브리핑"""
    __tablename__ = "daily_briefings"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    briefing_date = Column(Date, unique=True, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # 관계
    news_items = relationship("BriefingNewsItem", back_populates="briefing")


class BriefingNewsItem(Base):
    """브리핑 내 뉴스 아이템"""
    __tablename__ = "briefing_news_items"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    briefing_id = Column(String, ForeignKey("daily_briefings.id"))
    order = Column(Integer)  # 순서 (1~5)

    # 기본 정보
    title = Column(String(500))
    summary = Column(Text)  # 2-3문장 요약
    publisher = Column(String(100))
    source_url = Column(String(1000))
    tags = Column(String(200))  # 쉼표 구분

    # 토핑 (유료)
    causality_cause = Column(Text, nullable=True)
    causality_effect = Column(Text, nullable=True)
    insight_title = Column(String(200), nullable=True)
    insight_content = Column(Text, nullable=True)
    insight_type = Column(String(20), nullable=True)  # positive, negative, neutral

    # 투자 관련성
    investment_score = Column(Integer, default=0)  # 0~100

    created_at = Column(DateTime, default=datetime.utcnow)

    # 관계
    briefing = relationship("DailyBriefing", back_populates="news_items")
