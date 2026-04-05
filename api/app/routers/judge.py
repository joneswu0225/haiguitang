"""
裁判相关路由 - Vercel适配版
处理玩家提问，判断是否相关
"""

from fastapi import APIRouter, HTTPException
from datetime import datetime
import random
from typing import Optional

# 简单的数据模型
class JudgeRequest:
    def __init__(self, game_id: str, question: str):
        self.game_id = game_id
        self.question = question

class ApiResponse:
    def __init__(self, code: int = 200, message: str = "", data: Optional[dict] = None):
        self.code = code
        self.message = message
        self.data = data or {}

# 模拟AI裁判的简单实现
class SimpleJudge:
    """简单的启发式裁判"""
    
    # 关键词匹配
    KEYWORD_PATTERNS = {
        "yes": [
            "是不是", "有没有", "会不会", "能不能", "可不可以",
            "是否", "有无", "活着", "认识", "想喝水",
            "相关", "正确", "对的", "是的"
        ],
        "no": [
            "不是", "没有", "不会", "不能", "不可以",
            "无关", "错误", "错的", "不是的", "火星上"
        ]
    }
    
    @staticmethod
    def judge_question(question: str) -> dict:
        """判断问题是否相关"""
        question_lower = question.lower()
        
        # 检查关键词
        yes_score = 0
        no_score = 0
        
        for keyword in SimpleJudge.KEYWORD_PATTERNS["yes"]:
            if keyword in question_lower:
                yes_score += 1
        
        for keyword in SimpleJudge.KEYWORD_PATTERNS["no"]:
            if keyword in question_lower:
                no_score += 1
        
        # 简单决策逻辑
        if yes_score > no_score:
            answer = "yes"
            rationale = "问题包含相关关键词，可能获取有用信息"
        elif no_score > yes_score:
            answer = "no"
            rationale = "问题包含否定或无关关键词"
        else:
            # 随机或根据问题长度决定
            if len(question) > 10:
                answer = "yes"
                rationale = "问题较详细，可能相关"
            else:
                answer = "irrelevant"
                rationale = "问题过于简单或模糊，无法判断相关性"
        
        # 添加一些随机性使回答更自然
        if random.random() < 0.2:  # 20%概率改变答案
            answers = ["yes", "no", "irrelevant"]
            current_index = answers.index(answer)
            answer = answers[(current_index + 1) % len(answers)]
            rationale = f"经过重新考虑，认为问题{answer}"
        
        return {
            "answer": answer,
            "rationale": rationale,
            "confidence": random.uniform(0.6, 0.9),
            "source": "simple_heuristic"
        }

router = APIRouter(prefix="/judge")

@router.post("/", response_model=ApiResponse)
async def judge_question(request: dict):
    """裁判判断问题"""
    try:
        game_id = request.get("game_id")
        question = request.get("question")
        
        if not game_id:
            raise HTTPException(status_code=400, detail="需要游戏ID")
        
        if not question or not question.strip():
            raise HTTPException(status_code=400, detail="问题不能为空")
        
        # 使用简单裁判判断
        judgment = SimpleJudge.judge_question(question)
        
        # 创建回合记录
        new_turn = {
            "id": str(int(datetime.now().timestamp())),
            "game_id": game_id,
            "question": question,
            "answer": judgment["answer"],
            "rationale": judgment["rationale"],
            "confidence": judgment["confidence"],
            "source": judgment["source"],
            "created_at": datetime.now().isoformat()
        }
        
        # 这里应该保存到数据库，这里简化处理
        # 在实际应用中，应该将回合保存到数据库
        
        return ApiResponse(
            code=200,
            message="裁判判断完成",
            data={
                "turn": new_turn,
                "judgment": judgment
            }
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"裁判判断失败: {str(e)}")

@router.post("/batch", response_model=ApiResponse)
async def judge_questions_batch(request: dict):
    """批量判断问题"""
    try:
        game_id = request.get("game_id")
        questions = request.get("questions", [])
        
        if not game_id:
            raise HTTPException(status_code=400, detail="需要游戏ID")
        
        if not isinstance(questions, list) or len(questions) == 0:
            raise HTTPException(status_code=400, detail="问题列表不能为空")
        
        results = []
        turns = []
        
        for i, question in enumerate(questions):
            if not question or not question.strip():
                continue
                
            judgment = SimpleJudge.judge_question(question)
            
            new_turn = {
                "id": f"{int(datetime.now().timestamp())}_{i}",
                "game_id": game_id,
                "question": question,
                "answer": judgment["answer"],
                "rationale": judgment["rationale"],
                "confidence": judgment["confidence"],
                "source": judgment["source"],
                "created_at": datetime.now().isoformat()
            }
            
            turns.append(new_turn)
            results.append({
                "question": question,
                "judgment": judgment
            })
        
        return ApiResponse(
            code=200,
            message="批量判断完成",
            data={
                "turns": turns,
                "results": results,
                "total": len(results)
            }
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"批量判断失败: {str(e)}")

@router.get("/health", response_model=ApiResponse)
async def judge_health():
    """裁判服务健康检查"""
    return ApiResponse(
        code=200,
        message="裁判服务运行正常",
        data={
            "service": "ai_judge",
            "version": "1.0.0",
            "status": "healthy",
            "judge_type": "simple_heuristic",
            "capabilities": ["single_judgment", "batch_judgment"]
        }
    )