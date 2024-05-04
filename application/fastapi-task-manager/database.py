# database.py
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

db_host = os.getenv("DB_HOST", "localhost")
db_port = os.getenv("DB_PORT", "5432")
db_user = os.getenv("DB_USER", "default_user")
db_password = os.getenv("DB_PASSWORD", "default_password")
db_name = os.getenv("DB_DATABASE", "default_db")

DATABASE_URL = f"postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def init_db():
    from models import Base
    Base.metadata.create_all(bind=engine)
