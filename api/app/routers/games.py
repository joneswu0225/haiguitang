"""
游戏相关路由 - Vercel适配版
使用内存存储，适配Serverless环境
"""

from fastapi import APIRouter, HTTPException, Header
from datetime import datetime
from typing import List, Optional
import time

# 简单的内存存储（Vercel Functions是无状态的，所以每次请求都是新的）
# 在实际生产环境中，应该使用外部数据库（如Supabase、PlanetScale等）

# 内存存储模拟
_memory_store = {
    "games": [],
    "turns": [],
    "last_id": 0
}

def get_next_id():
    _memory_store["last_id"] += 1
    return str(_memory_store["last_id"])

def get_mock_games():
    return _memory_store["games"]

def get_mock_turns():
    return _memory_store["turns"]

def get_game_by_id(game_id: str):
    for game in _memory_store["games"]:
        if game["id"] == game_id:
            return game
    return None

def get_turns_by_game_id(game_id: str):
    return [turn for turn in _memory_store["turns"] if turn["game_id"] == game_id]

def add_game(game_data: dict):
    game_data["id"] = get_next_id()
    _memory_store["games"].append(game_data)
    return game_data

def update_game(game_id: str, updates: dict):
    for i, game in enumerate(_memory_store["games"]):
        if game["id"] == game_id:
            _memory_store["games"][i].update(updates)
            return _memory_store["games"][i]
    return None

def get_user_games(user_id: str):
    return [game for game in _memory_store["games"] if game.get("user_id") == user_id]

# 简单的数据模型
class GameCreate:
    def __init__(self, soup_id: str, user_id: Optional[str] = None):
        self.soup_id = soup_id
        self.user_id = user_id

class ApiResponse:
    def __init__(self, code: int = 200, message: str = "", data: Optional[dict] = None):
        self.code = code
        self.message = message
        self.data = data or {}

router = APIRouter(prefix="/games")

@router.post("/", response_model=ApiResponse)
async def create_game(game_data: dict, x_user_id: Optional[str] = Header(None)):
    """创建新游戏"""
    try:
        soup_id = game_data.get("soup_id", "1")
        user_id = x_user_id or game_data.get("user_id", "anonymous")
        
        new_game = {
            "id": get_next_id(),
            "soup_id": soup_id,
            "user_id": user_id,
            "status": "active",
            "started_at": datetime.now().isoformat(),
            "ended_at": None,
            "turns": [],
            "proximity_score": None,
            "proximity_rationale": None,
            "created_at": int(time.time())
        }
        
        _memory_store["games"].append(new_game)
        
        return ApiResponse(
            code=200,
            message="游戏创建成功",
            data={"game": new_game}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"创建游戏失败: {str(e)}")

@router.get("/{game_id}", response_model=ApiResponse)
async def get_game(game_id: str, x_user_id: Optional[str] = Header(None)):
    """获取游戏详情"""
    game = get_game_by_id(game_id)
    
    if not game:
        raise HTTPException(status_code=404, detail="游戏未找到")
    
    # 检查权限（简化版）
    if x_user_id and game.get("user_id") != x_user_id:
        raise HTTPException(status_code=403, detail="无权访问此游戏")
    
    # 获取回合数据
    game_turns = get_turns_by_game_id(game_id)
    game_with_turns = {**game, "turns": game_turns}
    
    return ApiResponse(
        code=200,
        message="获取游戏成功",
        data={"game": game_with_turns}
    )

@router.patch("/{game_id}/complete", response_model=ApiResponse)
async def complete_game(game_id: str, x_user_id: Optional[str] = Header(None)):
    """完成游戏"""
    game = get_game_by_id(game_id)
    
    if not game:
        raise HTTPException(status_code=404, detail="游戏未找到")
    
    if x_user_id and game["user_id"] != x_user_id:
        raise HTTPException(status_code=403, detail="无权操作此游戏")
    
    if game["status"] != "active":
        raise HTTPException(status_code=400, detail="游戏状态不允许完成")
    
    # 获取游戏的所有回合
    game_turns = get_turns_by_game_id(game_id)
    
    # 计算简单的接近度分数（启发式方法）
    proximity_score = 0
    proximity_rationale = ""
    
    if game_turns:
        total_turns = len(game_turns)
        
        # 统计不同类型的回答
        yes_count = sum(1 for turn in game_turns if turn.get("answer") == "yes")
        no_count = sum(1 for turn in game_turns if turn.get("answer") == "no")
        irrelevant_count = sum(1 for turn in game_turns if turn.get("answer") == "irrelevant")
        
        # 启发式评分规则
        base_score = (yes_count * 20) + (no_count * 10) - (irrelevant_count * 5)
        
        # 根据问题数量调整分数
        if 3 <= total_turns <= 8:
            base_score += 20  # 问题数量适中
        elif total_turns > 8:
            base_score -= 10  # 问题太多
        
        # 确保分数在0-100之间
        proximity_score = max(0, min(100, base_score))
        
        # 生成评分理由
        if proximity_score >= 80:
            proximity_rationale = "优秀推理：问题精准，有效获取关键信息"
        elif proximity_score >= 60:
            proximity_rationale = "良好推理：大部分问题相关，推理方向正确"
        elif proximity_score >= 40:
            proximity_rationale = "一般推理：部分问题相关，需要更多关键信息"
        else:
            proximity_rationale = "需要改进：问题相关性不足，推理方向需要调整"
    else:
        proximity_score = 0
        proximity_rationale = "没有提问记录"
    
    updates = {
        "status": "completed",
        "ended_at": datetime.now().isoformat(),
        "proximity_score": proximity_score,
        "proximity_rationale": proximity_rationale
    }
    
    updated_game = update_game(game_id, updates)
    
    if not updated_game:
        raise HTTPException(status_code=500, detail="更新游戏失败")
    
    return ApiResponse(
        code=200,
        message="游戏完成成功",
        data={"game": updated_game}
    )

@router.get("/user/stats", response_model=ApiResponse)
async def get_user_stats(x_user_id: Optional[str] = Header(None)):
    """获取用户统计"""
    if not x_user_id:
        raise HTTPException(status_code=400, detail="需要用户ID")
    
    user_games = get_user_games(x_user_id)
    completed_games = [game for game in user_games if game["status"] == "completed"]
    
    # 1. 已完成局数
    completed_count = len(completed_games)
    
    # 2. 计算总提问数（所有游戏的回合数）
    total_questions = 0
    for game in user_games:
        game_turns = get_turns_by_game_id(game["id"])
        total_questions += len(game_turns)
    
    # 3. 计算成功率（完成游戏中接近度分数达到60分以上的比例）
    successful_games = 0
    total_duration_seconds = 0
    
    for game in completed_games:
        # 检查接近度分数是否达到成功阈值（60分）
        if game.get("proximity_score") is not None and game["proximity_score"] >= 60:
            successful_games += 1
        
        # 计算游戏时长（秒）
        if game.get("started_at") and game.get("ended_at"):
            try:
                started = datetime.fromisoformat(game["started_at"])
                ended = datetime.fromisoformat(game["ended_at"])
                game_duration = (ended - started).total_seconds()
                total_duration_seconds += game_duration
            except (ValueError, TypeError):
                # 如果时间格式无效，跳过
                pass
    
    # 4. 计算平均用时（秒）和成功率
    average_time_seconds = total_duration_seconds / completed_count if completed_count > 0 else 0
    success_rate = (successful_games / completed_count * 100) if completed_count > 0 else 0
    
    stats_data = {
        "completed_games": completed_count,
        "total_questions": total_questions,
        "success_rate": round(success_rate, 1),
        "average_time_seconds": round(average_time_seconds, 1)
    }
    
    return ApiResponse(
        code=200,
        message="获取统计成功",
        data={"stats": stats_data}
    )