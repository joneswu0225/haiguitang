"""
AI海龟汤 - Vercel环境专用FastAPI应用
适配Serverless环境，使用内存存储
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import os

# 创建FastAPI应用
app = FastAPI(
    title="AI海龟汤 API",
    version="1.0.0",
    description="AI海龟汤游戏后端API - Vercel部署版",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json"
)

# Vercel环境配置
IS_VERCEL = os.environ.get("VERCEL") == "1"
ENVIRONMENT = os.environ.get("ENVIRONMENT", "production")

# 配置CORS - Vercel环境需要正确配置
allowed_origins = ["*"]  # 生产环境应该限制为具体域名

if IS_VERCEL:
    # 获取Vercel部署的域名
    vercel_url = os.environ.get("VERCEL_URL")
    if vercel_url:
        allowed_origins.append(f"https://{vercel_url}")
    
    # 添加自定义域名
    custom_domain = os.environ.get("CUSTOM_DOMAIN")
    if custom_domain:
        allowed_origins.append(f"https://{custom_domain}")

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# 添加自定义中间件确保CORS头被设置
@app.middleware("http")
async def add_cors_headers(request: Request, call_next):
    # 处理OPTIONS预检请求
    if request.method == "OPTIONS":
        response = JSONResponse(content={"message": "CORS预检请求通过"})
    else:
        response = await call_next(request)
    
    # 添加CORS头
    origin = request.headers.get("origin", "*")
    response.headers["Access-Control-Allow-Origin"] = origin
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, PATCH, DELETE, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-User-ID"
    response.headers["Access-Control-Allow-Credentials"] = "true"
    response.headers["Access-Control-Max-Age"] = "86400"  # 24小时
    
    return response

# 导入路由
try:
    from app.routers import soups, games, judge
    
    # 注册路由，前缀为 /api/v1
    app.include_router(soups.router, prefix="/api/v1", tags=["题库"])
    app.include_router(games.router, prefix="/api/v1", tags=["游戏"])
    app.include_router(judge.router, prefix="/api/v1", tags=["裁判"])
    
except ImportError as e:
    print(f"警告：无法导入路由模块: {e}")
    
    # 创建简单的路由作为回退
    @app.get("/api/v1/health")
    async def health_check():
        return {"status": "ok", "environment": ENVIRONMENT, "vercel": IS_VERCEL}

# 根路由
@app.get("/")
async def root():
    return {
        "message": "AI海龟汤 API - Vercel部署版",
        "version": "1.0.0",
        "environment": ENVIRONMENT,
        "vercel": IS_VERCEL,
        "docs": "/api/docs",
        "endpoints": {
            "题库": "/api/v1/soups",
            "游戏": "/api/v1/games",
            "裁判": "/api/v1/judge",
            "健康检查": "/api/v1/health"
        }
    }

# 健康检查端点
@app.get("/api/health")
async def api_health():
    return {
        "status": "healthy",
        "service": "ai-haiguitang-api",
        "environment": ENVIRONMENT,
        "vercel": IS_VERCEL,
        "timestamp": "2024-01-01T00:00:00Z"  # 实际应该使用datetime.now()
    }

# 404处理器
@app.exception_handler(404)
async def not_found_exception_handler(request: Request, exc):
    return JSONResponse(
        status_code=404,
        content={
            "code": 404,
            "message": f"未找到资源: {request.url.path}",
            "suggestions": [
                "检查URL是否正确",
                "查看API文档: /api/docs",
                "确认API端点是否存在"
            ]
        }
    )

# 全局异常处理器
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={
            "code": 500,
            "message": "服务器内部错误",
            "detail": str(exc) if ENVIRONMENT == "development" else "内部服务器错误",
            "request_id": request.headers.get("x-vercel-id", "unknown")
        }
    )

# 冷启动优化：预加载一些数据
@app.on_event("startup")
async def startup_event():
    """应用启动时执行"""
    print(f"AI海龟汤API启动 - 环境: {ENVIRONMENT}, Vercel: {IS_VERCEL}")
    
    # 初始化内存存储
    try:
        from app.data_store import init_memory_store
        init_memory_store()
        print("内存存储初始化完成")
    except ImportError:
        print("警告：无法初始化内存存储")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)