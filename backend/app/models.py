# app/models.py
from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean

from .database import Base


class UserQuestion(Base):
    __tablename__ = "user_questions"

    id = Column(Integer, primary_key=True, autoincrement=True)
    category = Column(String(128), nullable=False)
    question = Column(Text, nullable=False)
    email = Column(String(256), nullable=True)
    source = Column(String(64), default="mobile-app")
    created_at = Column(DateTime, default=datetime.utcnow)


class Purchase(Base):
    __tablename__ = "purchases"

    id = Column(Integer, primary_key=True, autoincrement=True)
    device_id = Column(String(256), nullable=True, index=True)
    purchase_token = Column(Text, nullable=False, unique=True)
    product_id = Column(String(128), nullable=False)
    package_name = Column(String(256), nullable=False)
    verified_at = Column(DateTime, default=datetime.utcnow)
    order_id = Column(String(256), nullable=True)
