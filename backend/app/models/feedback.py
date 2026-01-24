"""피드백 모델"""
from sqlalchemy import Column, String, DateTime, Text, Boolean
from datetime import datetime
import uuid
from ..database import Base


class Feedback(Base):
    __tablename__ = "feedbacks"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    content = Column(Text, nullable=False)

    # 분석용 로깅
    ip_address = Column(String(50), nullable=True)
    user_agent = Column(String(500), nullable=True)  # 디바이스/브라우저 정보
    app_version = Column(String(20), nullable=True)
    platform = Column(String(20), nullable=True)  # ios, android, web

    # 관리
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
