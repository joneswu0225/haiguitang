from fastapi import APIRouter, HTTPException, Header
from datetime import datetime
from typing import Optional
from app.schemas import JudgeRequest, JudgeResponse, ApiResponse
from app.data_store import get_mock_turns, add_turn, get_turns_by_game_id
from app.ai_service import ai_service

router = APIRouter(prefix="/judge")

@router.post("/", response_model=ApiResponse)
async def judge_question(request: JudgeRequest, x_user_id: Optional[str] = Header(None)):
    """裁判判断玩家提问"""
    # 调用 AI 服务进行裁判判断
    try:
        # 获取游戏信息以获取 soup_id
        # 这里需要从游戏数据中获取 soup_id，暂时使用默认值
        # 在实际应用中，应该查询游戏数据库获取 soup_id
        soup_id = "1"  # 默认值，实际应该从游戏数据获取
        
        # 调用 AI 服务
        ai_result = await ai_service.judge_question(
            soup_id=soup_id,
            question=request.question,
            game_id=request.game_id
        )
        
        answer = ai_result["answer"]
        rationale = ai_result["rationale"]
        source = ai_result["source"]
        
    except Exception as e:
        # AI 服务失败时回退到启发式方法
        import random
        question_lower = request.question.lower()
        
        if "是不是" in question_lower or "是否" in question_lower or "有没有" in question_lower:
            answer = random.choice(["yes", "no"])
            rationale = f"启发式判断：问题形式为是非问句"
        elif "什么" in question_lower or "为什么" in question_lower or "如何" in question_lower:
            answer = "irrelevant"
            rationale = f"启发式判断：问题为开放性问题"
        else:
            answers = ["yes", "no", "irrelevant"]
            weights = [0.4, 0.4, 0.2]
            answer = random.choices(answers, weights=weights)[0]
            rationale = f"启发式判断：随机选择"
        
        source = "fallback"
    
    mock_turns = get_mock_turns()
    
    new_turn = {
        "id": str(len(mock_turns) + 1),
        "game_id": request.game_id,
        "question": request.question,
        "answer": answer,
        "created_at": datetime.now().isoformat(),
        "proximity_score": None,
        "proximity_rationale": None,
        "judge_rationale": rationale,  # 添加裁判判断理由
        "judge_source": source  # 添加判断来源
    }
    
    add_turn(new_turn)
    
    # 检查游戏状态（这里应该查询真实数据库）
    # 暂时模拟游戏状态
    game_status = "active"
    
    return ApiResponse(
        code=200,
        message="裁判判断完成",
        data={
            "turn": new_turn,
            "game_status": game_status,
            "judge_info": {
                "source": source,
                "rationale": rationale
            }
        }
    )

@router.post("/batch-score", response_model=ApiResponse)
async def batch_score_proximity(game_id: str, x_user_id: Optional[str] = Header(None)):
    """批量评分（局后调用）"""
    if not x_user_id:
        raise HTTPException(status_code=400, detail="需要用户ID")
    
    # 获取该游戏的所有回合
    game_turns = get_turns_by_game_id(game_id)
    
    if not game_turns:
        raise HTTPException(status_code=404, detail="未找到该游戏的回合")
    
    # 批量评分
    scored_turns = []
    for turn in game_turns:
        try:
            # 使用 AI 服务进行接近度评分
            # 需要获取 soup_id，这里使用默认值
            soup_id = "1"  # 实际应该从游戏数据获取
            
            score_result = await ai_service.score_proximity(
                soup_id=soup_id,
                question=turn.get("question", ""),
                answer=turn.get("answer", "")
            )
            
            score = score_result["score"]
            rationale = score_result["rationale"]
            score_source = score_result["source"]
            
        except Exception as e:
            # AI 评分失败时使用启发式评分
            import random
            answer = turn.get("answer", "")
            
            if answer == "yes":
                score = random.randint(60, 90)
                rationale = "启发式评分：得到肯定回答，接近真相"
            elif answer == "no":
                score = random.randint(30, 70)
                rationale = "启发式评分：得到否定回答，需要进一步推理"
            else:  # irrelevant
                score = random.randint(10, 40)
                rationale = "启发式评分：问题无关，偏离推理方向"
            
            score_source = "fallback"
        
        scored_turn = {
            **turn,
            "proximity_score": score,
            "proximity_rationale": rationale,
            "score_source": score_source
        }
        scored_turns.append(scored_turn)
    
    # 计算整体评分
    overall_score = sum(t["proximity_score"] for t in scored_turns) // len(scored_turns) if scored_turns else 0
    
    # 生成整体理由
    if overall_score >= 80:
        overall_rationale = "整体推理表现优秀，接近真相"
    elif overall_score >= 60:
        overall_rationale = "推理过程良好，接近关键事实"
    elif overall_score >= 40:
        overall_rationale = "推理过程一般，部分提问偏离方向"
    else:
        overall_rationale = "需要改进提问策略，关注核心线索"
    
    return ApiResponse(
        code=200,
        message="批量评分完成",
        data={
            "turns": scored_turns,
            "overall_score": overall_score,
            "overall_rationale": overall_rationale
        }
    )

@router.get("/heuristic-example", response_model=ApiResponse)
async def get_heuristic_example():
    """获取启发式评分示例"""
    example = {
        "soup": {
            "surface": "一个人走进酒吧，向酒保要了一杯水。酒保掏出一把枪指着他。这个人说了一声谢谢，然后离开了。",
            "key_facts": ["这个人打嗝", "酒保用枪吓他", "打嗝停止了"]
        },
        "questions": [
            {
                "question": "这个人是不是生病了？",
                "expected_score": 60,
                "rationale": "问题相关但不够具体，打嗝是一种生理现象但不是疾病"
            },
            {
                "question": "这个人是不是在打嗝？",
                "expected_score": 90,
                "rationale": "直接触及核心事实，打嗝是关键线索"
            },
            {
                "question": "酒吧是不是在火星上？",
                "expected_score": 10,
                "rationale": "完全偏离推理方向，与关键事实无关"
            }
        ]
    }
    
    return ApiResponse(
        code=200,
        message="获取启发式评分示例成功",
        data={"example": example}
    )