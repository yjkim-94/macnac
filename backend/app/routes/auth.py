from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel, EmailStr
from ..database import get_db
from ..services import auth_service

router = APIRouter(prefix="/auth", tags=["auth"])


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    name: str | None = None


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "Bearer"
    user: dict


@router.post("/login", response_model=AuthResponse)
async def login(req: LoginRequest, db: Session = Depends(get_db)):
    user = auth_service.get_user_by_email(db, req.email)
    if not user or not auth_service.verify_password(req.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="이메일 또는 비밀번호가 올바르지 않습니다.")
    token = auth_service.create_access_token({"sub": user.id})
    return {"access_token": token, "user": {"id": user.id, "email": user.email, "name": user.name, "created_at": user.created_at.isoformat(), "subscriptions": []}}


@router.post("/register", response_model=AuthResponse)
async def register(req: RegisterRequest, db: Session = Depends(get_db)):
    if auth_service.get_user_by_email(db, req.email):
        raise HTTPException(status_code=400, detail="이미 존재하는 이메일입니다.")
    user = auth_service.create_user(db, req.email, req.password, req.name)
    token = auth_service.create_access_token({"sub": user.id})
    return {"access_token": token, "user": {"id": user.id, "email": user.email, "name": user.name, "created_at": user.created_at.isoformat(), "subscriptions": []}}
