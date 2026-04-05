"""
共享数据存储模块
用于在内存中模拟数据库，确保所有路由器共享相同的数据
"""

# 全局共享数据存储
mock_games = []
mock_turns = []

def get_mock_games():
    """获取游戏数据存储"""
    return mock_games

def get_mock_turns():
    """获取回合数据存储"""
    return mock_turns

def clear_all_data():
    """清除所有数据（用于测试）"""
    global mock_games, mock_turns
    mock_games.clear()
    mock_turns.clear()

def get_game_by_id(game_id: str):
    """根据ID获取游戏"""
    for game in mock_games:
        if game["id"] == game_id:
            return game
    return None

def get_turns_by_game_id(game_id: str):
    """根据游戏ID获取所有回合"""
    return [turn for turn in mock_turns if turn["game_id"] == game_id]

def add_game(game_data: dict):
    """添加新游戏"""
    mock_games.append(game_data)

def add_turn(turn_data: dict):
    """添加新回合"""
    mock_turns.append(turn_data)

def update_game(game_id: str, updates: dict):
    """更新游戏数据"""
    for game in mock_games:
        if game["id"] == game_id:
            game.update(updates)
            return True
    return False

def get_user_games(user_id: str):
    """获取用户的所有游戏"""
    return [game for game in mock_games if game["user_id"] == user_id]