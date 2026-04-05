from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field


class TurnBase(BaseModel):
    question: str = Field(..., description="玩家提问")
    answer: str = Field(..., description="裁判回答", pattern="^(yes|no|irrelevant)$")


class TurnCreate(TurnBase):
    game_id: str = Field(..., description="游戏ID")


class Turn(TurnBase):
    id: str = Field(..., description="回合ID")
    game_id: str = Field(..., description="游戏ID")
    created_at: datetime = Field(..., description="创建时间")
    proximity_score: Optional[int] = Field(None, description="接近度分数", ge=0, le=100)
    proximity_rationale: Optional[str] = Field(None, description="接近度理由")
    
    class Config:
        from_attributes = True


class GameBase(BaseModel):
    soup_id: str = Field(..., description="汤ID")
    user_id: Optional[str] = Field(None, description="用户ID（可选，可从请求头获取）")


class GameCreate(GameBase):
    pass


class GameUpdate(BaseModel):
    status: Optional[str] = Field(None, description="游戏状态", pattern="^(active|completed|abandoned)$")
    ended_at: Optional[datetime] = Field(None, description="结束时间")


class Game(GameBase):
    id: str = Field(..., description="游戏ID")
    status: str = Field(..., description="游戏状态")
    started_at: datetime = Field(..., description="开始时间")
    ended_at: Optional[datetime] = Field(None, description="结束时间")
    turns: List[Turn] = Field(default_factory=list, description="回合列表")
    proximity_score: Optional[int] = Field(None, description="整体接近度分数", ge=0, le=100)
    proximity_rationale: Optional[str] = Field(None, description="整体接近度理由")
    
    class Config:
        from_attributes = True


class SoupBase(BaseModel):
    title: str = Field(..., description="标题")
    surface: str = Field(..., description="汤面")
    bottom: str = Field(..., description="汤底")
    key_facts: List[str] = Field(..., description="关键事实列表")
    difficulty: str = Field(..., description="难度", pattern="^(简单|中等|困难)$")
    category: str = Field(..., description="分类")
    estimated_time: str = Field(..., description="预计时长")
    soup_version: Optional[str] = Field("1.0.0", description="汤版本")


class SoupCreate(SoupBase):
    pass


class Soup(SoupBase):
    id: str = Field(..., description="汤ID")
    played_count: int = Field(0, description="已玩次数")
    
    class Config:
        from_attributes = True


class JudgeRequest(BaseModel):
    game_id: str = Field(..., description="游戏ID")
    question: str = Field(..., description="玩家提问")


class JudgeResponse(BaseModel):
    turn: Turn = Field(..., description="创建的回合")
    game_status: str = Field(..., description="游戏状态")


class ProximityScoreRequest(BaseModel):
    turn_id: str = Field(..., description="回合ID")
    soup_id: str = Field(..., description="汤ID")
    question: str = Field(..., description="玩家提问")


class ProximityScoreResponse(BaseModel):
    turn_id: str = Field(..., description="回合ID")
    score: int = Field(..., description="接近度分数", ge=0, le=100)
    rationale: str = Field(..., description="接近度理由")


class StatsResponse(BaseModel):
    completed_games: int = Field(..., description="已完成局数")
    average_time_seconds: float = Field(..., description="平均用时（秒）")
    success_rate: float = Field(..., description="成功率", ge=0, le=100)
    total_questions: int = Field(..., description="总提问数")


class ApiResponse(BaseModel):
    code: int = Field(default=200, description="状态码：200=成功，400=参数错误，500=服务端错误")
    message: str = Field(default="", description="响应消息")
    data: Optional[dict] = Field(default=None, description="响应数据")