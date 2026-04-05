from fastapi import APIRouter, HTTPException, Header
from datetime import datetime, timedelta
from typing import List, Optional
from app.schemas import Game, GameCreate, GameUpdate, Turn, StatsResponse, ApiResponse
from app.data_store import (
    get_mock_games, get_mock_turns, 
    get_game_by_id, get_turns_by_game_id,
    add_game, update_game, get_user_games
)

router = APIRouter(prefix="/games")

@router.post("/", response_model=ApiResponse)
async def create_game(game: GameCreate, x_user_id: Optional[str] = Header(None)):
    """创建新游戏"""
    user_id = x_user_id or game.user_id
    mock_games = get_mock_games()
    
    new_game = {
        "id": str(len(mock_games) + 1),
        "soup_id": game.soup_id,
        "user_id": user_id,
        "status": "active",
        "started_at": datetime.now().isoformat(),
        "ended_at": None,
        "turns": [],
        "proximity_score": None,
        "proximity_rationale": None
    }
    
    add_game(new_game)
    
    return ApiResponse(
        code=200,
        message="创建游戏成功",
        data={"game": new_game}
    )

@router.get("/", response_model=ApiResponse)
async def get_games(x_user_id: Optional[str] = Header(None)):
    """获取用户的所有游戏"""
    if not x_user_id:
        raise HTTPException(status_code=400, detail="需要用户ID")
    
    user_games = get_user_games(x_user_id)
    
    return ApiResponse(
        code=200,
        message="获取游戏列表成功",
        data={"games": user_games}
    )

@router.get("/{game_id}", response_model=ApiResponse)
async def get_game(game_id: str, x_user_id: Optional[str] = Header(None)):
    """获取指定游戏的详细信息"""
    game = get_game_by_id(game_id)
    
    if not game:
        raise HTTPException(status_code=404, detail="游戏未找到")
    
    if x_user_id and game["user_id"] != x_user_id:
        raise HTTPException(status_code=403, detail="无权访问此游戏")
    
    # 获取该游戏的所有回合
    game_turns = get_turns_by_game_id(game_id)
    game["turns"] = game_turns
    
    return ApiResponse(
        code=200,
        message="获取游戏详情成功",
        data={"game": game}
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
    
    updates = {
        "status": "completed",
        "ended_at": datetime.now().isoformat()
    }
    
    update_game(game_id, updates)
    game.update(updates)
    
    return ApiResponse(
        code=200,
        message="游戏完成成功",
        data={"game": game}
    )

@router.patch("/{game_id}/abandon", response_model=ApiResponse)
async def abandon_game(game_id: str, x_user_id: Optional[str] = Header(None)):
    """放弃游戏"""
    game = get_game_by_id(game_id)
    
    if not game:
        raise HTTPException(status_code=404, detail="游戏未找到")
    
    if x_user_id and game["user_id"] != x_user_id:
        raise HTTPException(status_code=403, detail="无权操作此游戏")
    
    if game["status"] != "active":
        raise HTTPException(status_code=400, detail="游戏状态不允许放弃")
    
    updates = {
        "status": "abandoned",
        "ended_at": datetime.now().isoformat()
    }
    
    update_game(game_id, updates)
    game.update(updates)
    
    return ApiResponse(
        code=200,
        message="游戏放弃成功",
        data={"game": game}
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
    
    # 5. 计算其他统计（用于显示）
    total_games = len(user_games)
    abandoned_count = len([game for game in user_games if game["status"] == "abandoned"])
    
    # 计算平均接近度分数
    proximity_scores = [game["proximity_score"] for game in completed_games if game["proximity_score"] is not None]
    avg_proximity = sum(proximity_scores) / len(proximity_scores) if proximity_scores else 0
    
    # 格式化显示数据
    stats = {
        # 主要统计（符合AGENTS.md规范）
        "completed_games": completed_count,
        "average_time_seconds": round(average_time_seconds, 1),
        "success_rate": round(success_rate, 1),
        "total_questions": total_questions,
        
        # 额外统计（用于显示）
        "total_games": total_games,
        "abandoned_games": abandoned_count,
        "avg_proximity_score": round(avg_proximity, 1),
        "avg_game_duration": f"{int(average_time_seconds // 60)}分钟{int(average_time_seconds % 60)}秒",
        "total_play_time": f"{int(total_duration_seconds // 60)}分钟",
        "successful_games": successful_games
    }
    
    return ApiResponse(
        code=200,
        message="获取用户统计成功",
        data={"stats": stats}
    )

@router.get("/{game_id}/stats", response_model=ApiResponse)
async def get_game_stats(game_id: str, x_user_id: Optional[str] = Header(None)):
    """获取游戏统计"""
    game = get_game_by_id(game_id)
    
    if not game:
        raise HTTPException(status_code=404, detail="游戏未找到")
    
    if x_user_id and game["user_id"] != x_user_id:
        raise HTTPException(status_code=403, detail="无权访问此游戏")
    
    game_turns = get_turns_by_game_id(game_id)
    
    stats = {
        "total_turns": len(game_turns),
        "yes_count": sum(1 for turn in game_turns if turn["answer"] == "yes"),
        "no_count": sum(1 for turn in game_turns if turn["answer"] == "no"),
        "irrelevant_count": sum(1 for turn in game_turns if turn["answer"] == "irrelevant"),
        "game_duration": None
    }
    
    if game["started_at"] and game["ended_at"]:
        started = datetime.fromisoformat(game["started_at"])
        ended = datetime.fromisoformat(game["ended_at"])
        duration = ended - started
        stats["game_duration"] = f"{duration.total_seconds() // 60}分钟"
    
    return ApiResponse(
        code=200,
        message="获取游戏统计成功",
        data={"stats": stats}
    )