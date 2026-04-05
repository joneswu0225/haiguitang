from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.config import settings
from app.routers import soups, games, judge

app = FastAPI(
    title=settings.app_title,
    version=settings.app_version,
    docs_url="/docs",
    redoc_url="/redoc"
)

# 配置 CORS - 使用更宽松的配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 联调阶段允许所有源
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
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, PATCH, DELETE, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-User-ID"
    response.headers["Access-Control-Allow-Credentials"] = "true"
    
    return response

# 注册路由
app.include_router(soups.router, prefix="/api/v1", tags=["题库"])
app.include_router(games.router, prefix="/api/v1", tags=["游戏"])
app.include_router(judge.router, prefix="/api/v1", tags=["裁判"])


@app.get("/")
async def root():
    return {
        "message": "AI 海龟汤 API",
        "version": settings.app_version,
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )