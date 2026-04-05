"""
AI 服务模块
集成 DeepSeek API 进行海龟汤裁判判断
"""

import httpx
import json
import logging
from typing import Optional, Dict, Any
from app.config import settings

logger = logging.getLogger(__name__)


class AIService:
    """AI 服务类"""
    
    def __init__(self):
        self.api_key = settings.deepseek_api_key
        self.base_url = settings.deepseek_base_url
        self.model = settings.deepseek_model
        self.use_ai = self.api_key is not None
        
        if not self.use_ai:
            logger.warning("未配置 DeepSeek API Key，将使用启发式方法")
    
    async def judge_question(self, soup_id: str, question: str, game_id: str) -> Dict[str, Any]:
        """
        裁判判断玩家提问
        
        Args:
            soup_id: 汤ID
            question: 玩家提问
            game_id: 游戏ID
            
        Returns:
            包含回答和理由的字典
        """
        if not self.use_ai:
            # 使用启发式方法
            return await self._heuristic_judge(question)
        
        try:
            # 使用 DeepSeek API
            return await self._deepseek_judge(soup_id, question, game_id)
        except Exception as e:
            logger.error(f"DeepSeek API 调用失败: {e}")
            # 失败时回退到启发式方法
            return await self._heuristic_judge(question)
    
    async def _deepseek_judge(self, soup_id: str, question: str, game_id: str) -> Dict[str, Any]:
        """
        使用 DeepSeek API 进行裁判判断
        
        注意：这里需要根据实际的汤谜题内容来设计提示词
        由于我们没有真实的汤底数据，这里使用通用提示词
        """
        # 获取汤的详细信息（这里需要从数据库或配置中获取）
        # 暂时使用通用提示词
        
        prompt = f"""
        你是一个海龟汤游戏的AI裁判。玩家正在玩一个海龟汤谜题。
        
        玩家的提问是："{question}"
        
        请根据海龟汤游戏的规则，给出以下三种回答之一：
        1. "yes" - 如果问题的答案是肯定的
        2. "no" - 如果问题的答案是否定的  
        3. "irrelevant" - 如果问题与谜题无关或无法回答
        
        请只返回一个单词：yes、no 或 irrelevant。
        不要解释，不要添加其他内容。
        """
        
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        data = {
            "model": self.model,
            "messages": [
                {"role": "system", "content": "你是一个海龟汤游戏的AI裁判，负责回答玩家的问题。"},
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.3,
            "max_tokens": 10
        }
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                f"{self.base_url}/chat/completions",
                headers=headers,
                json=data
            )
            
            if response.status_code == 200:
                result = response.json()
                answer_text = result["choices"][0]["message"]["content"].strip().lower()
                
                # 标准化回答
                if "yes" in answer_text:
                    answer = "yes"
                elif "no" in answer_text:
                    answer = "no"
                else:
                    answer = "irrelevant"
                
                return {
                    "answer": answer,
                    "rationale": f"AI裁判判断：{answer}",
                    "source": "deepseek"
                }
            else:
                raise Exception(f"API 调用失败: {response.status_code} - {response.text}")
    
    async def _heuristic_judge(self, question: str) -> Dict[str, Any]:
        """
        启发式裁判判断（当没有AI可用时使用）
        
        根据问题内容进行简单的模式匹配
        """
        import random
        
        question_lower = question.lower()
        
        # 简单启发式规则
        if "是不是" in question_lower or "是否" in question_lower or "有没有" in question_lower:
            # 这类问题更可能得到 yes/no 回答
            answer = random.choice(["yes", "no"])
            rationale = f"启发式判断：问题形式为是非问句"
        elif "什么" in question_lower or "为什么" in question_lower or "如何" in question_lower:
            # 开放性问题更可能得到 irrelevant 回答
            answer = "irrelevant"
            rationale = f"启发式判断：问题为开放性问题"
        else:
            # 随机选择，但调整权重
            answers = ["yes", "no", "irrelevant"]
            weights = [0.4, 0.4, 0.2]
            answer = random.choices(answers, weights=weights)[0]
            rationale = f"启发式判断：随机选择"
        
        return {
            "answer": answer,
            "rationale": rationale,
            "source": "heuristic"
        }
    
    async def score_proximity(self, soup_id: str, question: str, answer: str) -> Dict[str, Any]:
        """
        评分接近度（局后调用）
        
        Args:
            soup_id: 汤ID
            question: 玩家提问
            answer: 裁判回答
            
        Returns:
            包含分数和理由的字典
        """
        if not self.use_ai:
            # 使用启发式评分
            return await self._heuristic_score(question, answer)
        
        try:
            # 使用 DeepSeek API 评分
            return await self._deepseek_score(soup_id, question, answer)
        except Exception as e:
            logger.error(f"DeepSeek API 评分失败: {e}")
            return await self._heuristic_score(question, answer)
    
    async def _deepseek_score(self, soup_id: str, question: str, answer: str) -> Dict[str, Any]:
        """
        使用 DeepSeek API 进行接近度评分
        """
        prompt = f"""
        你正在评估一个海龟汤游戏中玩家提问的接近度。
        
        玩家的提问是："{question}"
        裁判的回答是："{answer}"
        
        请评估这个提问与谜题真相的接近程度，给出一个0-100的分数。
        同时提供简短的评分理由（不超过50字）。
        
        请以JSON格式返回，包含以下字段：
        - "score": 整数，0-100
        - "rationale": 字符串，评分理由
        
        示例：
        {{"score": 75, "rationale": "问题触及了核心矛盾，但不够具体"}}
        """
        
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        data = {
            "model": self.model,
            "messages": [
                {"role": "system", "content": "你是一个海龟汤游戏的评分专家，负责评估玩家提问的接近度。"},
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.2,
            "max_tokens": 200
        }
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                f"{self.base_url}/chat/completions",
                headers=headers,
                json=data
            )
            
            if response.status_code == 200:
                result = response.json()
                content = result["choices"][0]["message"]["content"].strip()
                
                try:
                    score_data = json.loads(content)
                    return {
                        "score": score_data.get("score", 50),
                        "rationale": score_data.get("rationale", "AI评分"),
                        "source": "deepseek"
                    }
                except json.JSONDecodeError:
                    # 如果返回的不是JSON，使用默认值
                    return {
                        "score": 50,
                        "rationale": "AI评分解析失败，使用默认分数",
                        "source": "deepseek_fallback"
                    }
            else:
                raise Exception(f"API 调用失败: {response.status_code} - {response.text}")
    
    async def _heuristic_score(self, question: str, answer: str) -> Dict[str, Any]:
        """
        启发式接近度评分
        """
        import random
        
        # 简单的启发式评分
        if answer == "yes":
            # 得到肯定回答的问题通常更接近真相
            score = random.randint(60, 90)
            rationale = "启发式评分：得到肯定回答，接近真相"
        elif answer == "no":
            # 得到否定回答的问题可能接近也可能不接近
            score = random.randint(30, 70)
            rationale = "启发式评分：得到否定回答，需要进一步推理"
        else:  # irrelevant
            # 无关问题通常不接近真相
            score = random.randint(10, 40)
            rationale = "启发式评分：问题无关，偏离推理方向"
        
        return {
            "score": score,
            "rationale": rationale,
            "source": "heuristic"
        }


# 创建全局AI服务实例
ai_service = AIService()