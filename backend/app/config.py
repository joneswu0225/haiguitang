from typing import Optional
from pydantic_settings import BaseSettings
from pydantic import Field


class Settings(BaseSettings):
    # 数据库配置
    database_url: str = Field(
        default="sqlite:///./data/app.db",
        description="SQLite 数据库连接字符串"
    )
    
    # DeepSeek API 配置
    deepseek_api_key: Optional[str] = Field(
        default=None,
        description="DeepSeek API 密钥，可选，缺省时使用启发式方法"
    )
    
    deepseek_base_url: str = Field(
        default="https://api.deepseek.com",
        description="DeepSeek API 基础 URL"
    )
    
    deepseek_model: str = Field(
        default="deepseek-chat",
        description="DeepSeek 模型名称"
    )
    
    # 应用配置
    app_title: str = Field(
        default="AI 海龟汤 API",
        description="应用标题"
    )
    
    app_version: str = Field(
        default="0.1.0",
        description="应用版本"
    )
    
    cors_origins: list[str] = Field(
        default=["http://localhost:5173", "http://localhost:5174"],
        description="CORS 允许的源"
    )
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()