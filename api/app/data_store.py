"""
数据存储模块 - Vercel适配版
使用内存存储，适配Serverless环境
注意：Vercel Functions是无状态的，每次请求都是新的实例
实际生产环境应该使用外部数据库
"""

import time
from typing import List, Dict, Optional

# 内存存储（每次请求都是新的实例）
_memory_store = {
    "games": [],
    "turns": [],
    "last_game_id": 0,
    "last_turn_id": 0
}

def init_memory_store():
    """初始化内存存储"""
    # 清空存储
    _memory_store["games"] = []
    _memory_store["turns"] = []
    _memory_store["last_game_id"] = 0
    _memory_store["last_turn_id"] = 0
    
    # 添加一些模拟数据
    add_mock_data()
    
    return _memory_store

def add_mock_data():
    """添加模拟数据"""
    # 添加模拟游戏
    mock_games = [
        {
            "id": "1",
            "soup_id": "1",
            "user_id": "test-user-1",
            "status": "completed",
            "started_at": "2024-01-01T10:00:00",
            "ended_at": "2024-01-01T10:05:00",
            "proximity_score": 85,
            "proximity_rationale": "优秀推理：问题精准，有效获取关键信息",
            "created_at": int(time.time()) - 86400  # 1天前
        },
        {
            "id": "2",
            "soup_id": "2",
            "user_id": "test-user-1",
            "status": "completed",
            "started_at": "2024-01-02T14:00:00",
            "ended_at": "2024-01-02T14:03:00",
            "proximity_score": 70,
            "proximity_rationale": "良好推理：大部分问题相关，推理方向正确",
            "created_at": int(time.time()) - 43200  # 半天前
        }
    ]
    
    _memory_store["games"].extend(mock_games)
    _memory_store["last_game_id"] = 2
    
    # 添加模拟回合
    mock_turns = [
        {
            "id": "1",
            "game_id": "1",
            "question": "这个人是不是还活着？",
            "answer": "no",
            "rationale": "问题包含相关关键词，可能获取有用信息",
            "confidence": 0.8,
            "source": "simple_heuristic",
            "created_at": "2024-01-01T10:01:00"
        },
        {
            "id": "2",
            "game_id": "1",
            "question": "酒吧是不是在火星上？",
            "answer": "no",
            "rationale": "问题包含否定或无关关键词",
            "confidence": 0.9,
            "source": "simple_heuristic",
            "created_at": "2024-01-01T10:02:00"
        },
        {
            "id": "3",
            "game_id": "2",
            "question": "这个人是不是想喝水？",
            "answer": "yes",
            "rationale": "问题包含相关关键词，可能获取有用信息",
            "confidence": 0.7,
            "source": "simple_heuristic",
            "created_at": "2024-01-02T14:01:00"
        }
    ]
    
    _memory_store["turns"].extend(mock_turns)
    _memory_store["last_turn_id"] = 3
    
    return _memory_store


def get_next_game_id() -> str:
    """获取下一个游戏ID"""
    _memory_store["last_game_id"] += 1
    return str(_memory_store["last_game_id"])


def get_next_turn_id() -> str:
    """获取下一个回合ID"""
    _memory_store["last_turn_id"] += 1
    return str(_memory_store["last_turn_id"])


def get_mock_games() -> List[Dict]:
    """获取所有游戏"""
    return _memory_store["games"]


def get_mock_turns() -> List[Dict]:
    """获取所有回合"""
    return _memory_store["turns"]


def get_game_by_id(game_id: str) -> Optional[Dict]:
    """根据ID获取游戏"""
    for game in _memory_store["games"]:
        if game["id"] == game_id:
            return game
    return None


def get_turns_by_game_id(game_id: str) -> List[Dict]:
    """根据游戏ID获取回合"""
    return [turn for turn in _memory_store["turns"] if turn["game_id"] == game_id]


def add_game(game_data: Dict) -> Dict:
    """添加新游戏"""
    game_data["id"] = get_next_game_id()
    game_data["created_at"] = int(time.time())
    
    # 确保必要字段存在
    if "status" not in game_data:
        game_data["status"] = "active"
    
    if "started_at" not in game_data:
        import datetime
        game_data["started_at"] = datetime.datetime.now().isoformat()
    
    _memory_store["games"].append(game_data)
    return game_data


def update_game(game_id: str, updates: Dict) -> Optional[Dict]:
    """更新游戏"""
    for i, game in enumerate(_memory_store["games"]):
        if game["id"] == game_id:
            _memory_store["games"][i].update(updates)
            return _memory_store["games"][i]
    return None


def get_user_games(user_id: str) -> List[Dict]:
    """获取用户的所有游戏"""
    return [game for game in _memory_store["games"] if game.get("user_id") == user_id]


def add_turn(turn_data: Dict) -> Dict:
    """添加新回合"""
    turn_data["id"] = get_next_turn_id()
    _memory_store["turns"].append(turn_data)
    return turn_data


def clear_memory_store():
    """清空内存存储"""
    _memory_store["games"] = []
    _memory_store["turns"] = []
    _memory_store["last_game_id"] = 0
    _memory_store["last_turn_id"] = 0
    
    return _memory_store


def get_store_stats() -> Dict:
    """获取存储统计"""
    return {
        "total_games": len(_memory_store["games"]),
        "total_turns": len(_memory_store["turns"]),
        "last_game_id": _memory_store["last_game_id"],
        "last_turn_id": _memory_store["last_turn_id"],
        "timestamp": int(time.time())
    }