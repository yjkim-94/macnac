"""피드백 API"""
from fastapi import APIRouter, Depends, Request, Query
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.feedback import Feedback

router = APIRouter(prefix="/feedback", tags=["feedback"])


class FeedbackRequest(BaseModel):
    content: str
    app_version: Optional[str] = None
    platform: Optional[str] = None  # ios, android, web


@router.post("")
async def submit_feedback(
    body: FeedbackRequest,
    request: Request,
    db: Session = Depends(get_db)
):
    """사용자 피드백 저장"""
    # 클라이언트 정보 추출
    ip = request.client.host if request.client else None
    user_agent = request.headers.get("user-agent", "")

    feedback = Feedback(
        content=body.content,
        ip_address=ip,
        user_agent=user_agent[:500] if user_agent else None,
        app_version=body.app_version,
        platform=body.platform,
    )

    db.add(feedback)
    db.commit()

    return {"message": "피드백이 저장되었습니다", "id": feedback.id}


@router.get("")
async def get_feedbacks(
    is_read: Optional[bool] = Query(None),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """피드백 목록 조회 (관리자용)"""
    query = db.query(Feedback)

    if is_read is not None:
        query = query.filter(Feedback.is_read == is_read)

    feedbacks = query.order_by(Feedback.created_at.desc()).limit(limit).all()

    return {
        "feedbacks": [
            {
                "id": f.id,
                "content": f.content,
                "ip_address": f.ip_address,
                "user_agent": f.user_agent,
                "app_version": f.app_version,
                "platform": f.platform,
                "is_read": f.is_read,
                "created_at": f.created_at.isoformat() if f.created_at else None,
            }
            for f in feedbacks
        ],
        "count": len(feedbacks),
    }


@router.patch("/{feedback_id}/read")
async def mark_as_read(feedback_id: str, db: Session = Depends(get_db)):
    """피드백 읽음 처리"""
    feedback = db.query(Feedback).filter(Feedback.id == feedback_id).first()
    if not feedback:
        return {"error": "피드백을 찾을 수 없습니다"}

    feedback.is_read = True
    db.commit()

    return {"message": "읽음 처리되었습니다"}
