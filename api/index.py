"""
AI海龟汤 - Vercel Serverless Functions入口点
这个文件是Vercel Functions的入口点，处理所有API请求
"""

import sys
import os

# 添加当前目录到Python路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.main import app

# Vercel需要这个变量
# 所有请求都会被路由到这个FastAPI应用
handler = app