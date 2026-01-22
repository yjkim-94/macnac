from sqlalchemy import Column, String, Text, DateTime, Float, ForeignKey, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
from ..database import Base
import uuid

class NewsArticle(Base):
    """재창작된 뉴스 (원문 복제 금지, 출처 필수)"""
    __tablename__ = "news_articles"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String, nullable=False)
    summary = Column(Text, nullable=False)  # 재창작된 요약
    recreated_content = Column(Text, nullable=False)  # 재창작된 본문
    image_url = Column(String)

    # 출처 정보 (저작권 가드레일 필수)
    source_url = Column(String, nullable=False)
    publisher = Column(String, nullable=False)
    original_published_at = Column(DateTime, nullable=False)

    tags = Column(JSON, default=list)
    tile_size = Column(String, default="small")  # small, wide, tall, large

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    causalities = relationship("CausalityAnalysis", back_populates="article")
    insights = relationship("Insight", back_populates="article")


class CausalityAnalysis(Base):
    """인과관계 분석"""
    __tablename__ = "causality_analyses"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    article_id = Column(String, ForeignKey("news_articles.id"), nullable=False)
    cause = Column(Text, nullable=False)  # 원인
    effect = Column(Text, nullable=False)  # 결과
    confidence = Column(Float, default=0.0)  # 신뢰도 0.0~1.0
    created_at = Column(DateTime, default=datetime.utcnow)

    article = relationship("NewsArticle", back_populates="causalities")


class Insight(Base):
    """투자 인사이트"""
    __tablename__ = "insights"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    article_id = Column(String, ForeignKey("news_articles.id"), nullable=False)
    title = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    insight_type = Column(String, default="general")  # positive, negative, neutral, general
    importance = Column(Float, default=0.5)  # 중요도 0.0~1.0
    created_at = Column(DateTime, default=datetime.utcnow)

    article = relationship("NewsArticle", back_populates="insights")
