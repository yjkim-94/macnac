"""데일리 브리핑 모델"""
from datetime import datetime, date
from sqlalchemy import Column, String, DateTime, Date, Integer, ForeignKey, Text
from sqlalchemy.orm import relationship
from ..database import Base
import uuid


class DailyBriefing(Base):
    """데일리 브리핑"""
    __tablename__ = "daily_briefings"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    briefing_date = Column(Date, unique=True, index=True)
    daily_summary = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    news_items = relationship("BriefingNewsItem", back_populates="briefing")


class BriefingNewsItem(Base):
    """브리핑 내 뉴스 아이템"""
    __tablename__ = "briefing_news_items"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    briefing_id = Column(String, ForeignKey("daily_briefings.id"))
    order = Column(Integer)
    title = Column(String(500))
    summary = Column(Text)
    publisher = Column(String(100))
    source_url = Column(String(1000))
    category = Column(String(20), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    briefing = relationship("DailyBriefing", back_populates="news_items")
