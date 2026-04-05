"""
题库相关路由 - Vercel适配版
"""

from fastapi import APIRouter, HTTPException
from typing import List, Optional

# 简单的数据模型
class ApiResponse:
    def __init__(self, code: int = 200, message: str = "", data: Optional[dict] = None):
        self.code = code
        self.message = message
        self.data = data or {}

# 模拟题库数据
MOCK_SOUPS = [
    {
        "id": "1",
        "title": "酒吧里的陌生人",
        "description": "一个人走进酒吧，向酒保要了一杯水。酒保拿出一把枪指着他。陌生人说谢谢，然后离开了。发生了什么？",
        "key_facts": [
            "陌生人打嗝",
            "酒保用枪指着他帮助他",
            "陌生人需要打嗝",
            "酒保理解了他的问题"
        ],
        "solution": "陌生人打嗝，需要水来缓解。酒保拿出一把枪指着他，吓了他一跳，打嗝就好了。陌生人道谢后离开。",
        "difficulty": "中等"
    },
    {
        "id": "2",
        "title": "电梯里的人",
        "description": "一个人住在10楼。每天他乘电梯到1楼去上班。晚上回家时，他乘电梯到7楼，然后走楼梯到10楼。为什么？",
        "key_facts": [
            "这个人是个小孩",
            "他够不到10楼的按钮",
            "他只能按到7楼的按钮",
            "7楼以上需要大人帮忙"
        ],
        "solution": "这个人是个小孩，身高只够按到7楼的按钮。所以到7楼后，他需要走楼梯到10楼的家。",
        "difficulty": "简单"
    },
    {
        "id": "3",
        "title": "沙漠中的死者",
        "description": "在沙漠中发现一具尸体，旁边有一个未打开的背包。死者是怎么死的？",
        "key_facts": [
            "死者是跳伞者",
            "背包是降落伞",
            "降落伞没有打开",
            "他从飞机上跳下"
        ],
        "solution": "死者是跳伞者，降落伞（背包）没有打开，导致他坠亡在沙漠中。",
        "difficulty": "中等"
    }
]

router = APIRouter(prefix="/soups")

@router.get("/", response_model=ApiResponse)
async def get_soups():
    """获取所有汤谜题"""
    return ApiResponse(
        code=200,
        message="获取汤谜题成功",
        data={"soups": MOCK_SOUPS}
    )

@router.get("/{soup_id}", response_model=ApiResponse)
async def get_soup(soup_id: str):
    """获取指定汤谜题"""
    for soup in MOCK_SOUPS:
        if soup["id"] == soup_id:
            return ApiResponse(
                code=200,
                message="获取汤谜题成功",
                data={"soup": soup}
            )
    
    raise HTTPException(status_code=404, detail="汤谜题未找到")

@router.get("/{soup_id}/solution", response_model=ApiResponse)
async def get_soup_solution(soup_id: str):
    """获取汤谜题答案"""
    for soup in MOCK_SOUPS:
        if soup["id"] == soup_id:
            return ApiResponse(
                code=200,
                message="获取汤底成功",
                data={
                    "soup_id": soup_id,
                    "title": soup["title"],
                    "solution": soup["solution"]
                }
            )
    
    raise HTTPException(status_code=404, detail="汤谜题未找到")