from datetime import datetime, timedelta
from jose import jwt
import bcrypt
from sqlalchemy.orm import Session
from ..config import get_settings
from ..models.user import User

settings = get_settings()


def verify_password(plain: str, hashed: str) -> bool:
    return bcrypt.checkpw(plain.encode(), hashed.encode())


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def create_access_token(data: dict) -> str:
    expire = datetime.utcnow() + timedelta(minutes=settings.access_token_expire_minutes)
    return jwt.encode({**data, "exp": expire}, settings.secret_key, algorithm=settings.jwt_algorithm)


def get_user_by_email(db: Session, email: str) -> User | None:
    return db.query(User).filter(User.email == email).first()


def create_user(db: Session, email: str, password: str, name: str = None) -> User:
    user = User(email=email, hashed_password=hash_password(password), name=name)
    db.add(user)
    db.commit()
    db.refresh(user)
    return user
