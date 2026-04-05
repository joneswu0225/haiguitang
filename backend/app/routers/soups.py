from fastapi import APIRouter, HTTPException
from typing import List
from app.schemas import Soup, SoupCreate, ApiResponse

router = APIRouter(prefix="/soups")

# 模拟数据
mock_soups = [
    {
        "id": "1",
        "title": "消失的乘客",
        "surface": "一名乘客在火车上消失了，但火车一直在行驶，没有人看到有人下车。",
        "bottom": "乘客是一名魔术师，他在火车行驶时表演了消失魔术，实际上他藏在了行李车厢。",
        "key_facts": ["乘客是魔术师", "火车在行驶中", "没有人看到下车", "使用了魔术技巧"],
        "difficulty": "简单",
        "category": "推理",
        "estimated_time": "10分钟",
        "soup_version": "1.0.0",
        "played_count": 124
    },
    {
        "id": "2",
        "title": "雨夜凶杀",
        "surface": "一个雨夜，有人被发现死在公园里，周围没有任何脚印。",
        "bottom": "死者是被人从远处用弓箭射杀的，所以周围没有脚印。",
        "key_facts": ["雨夜", "公园", "没有脚印", "远程武器"],
        "difficulty": "中等",
        "category": "悬疑",
        "estimated_time": "15分钟",
        "soup_version": "1.0.0",
        "played_count": 89
    },
    {
        "id": "3",
        "title": "密室之谜",
        "surface": "一个房间从内部反锁，里面的人却消失了，窗户也无法打开。",
        "bottom": "房间有密道，密道入口在书架后面。",
        "key_facts": ["内部反锁", "窗户无法打开", "密道", "书架"],
        "difficulty": "困难",
        "category": "密室",
        "estimated_time": "20分钟",
        "soup_version": "1.0.0",
        "played_count": 56
    }
]

@router.get("/", response_model=ApiResponse)
async def get_soups():
    """获取所有汤列表"""
    return ApiResponse(
        code=200,
        message="获取汤列表成功",
        data={"soups": mock_soups}
    )

@router.get("/{soup_id}", response_model=ApiResponse)
async def get_soup(soup_id: str):
    """获取指定汤的详细信息"""
    for soup in mock_soups:
        if soup["id"] == soup_id:
            return ApiResponse(
        code=200,
        message="获取汤详情成功",
        data={"soup": soup}
    )
    
    raise HTTPException(status_code=404, detail="汤未找到")

@router.post("/", response_model=ApiResponse)
async def create_soup(soup: SoupCreate):
    """创建新汤（管理员功能）"""
    new_soup = {
        "id": str(len(mock_soups) + 1),
        **soup.dict(),
        "played_count": 0
    }
    mock_soups.append(new_soup)
    
    return ApiResponse(
        code=200,
        message="创建汤成功",
        data={"soup": new_soup}
    )