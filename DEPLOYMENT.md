# AI海龟汤 - 部署指南

本文档介绍如何将AI海龟汤项目部署到Vercel。

## 📋 部署架构

本项目采用前后端分离架构：

- **前端**: Vue 3 + Vite + TypeScript (部署到Vercel)
- **后端**: FastAPI + Python (可部署到Vercel Functions、Railway、Render等)

## 🚀 Vercel部署步骤

### 步骤1：准备代码
确保代码已提交到Git仓库（GitHub、GitLab或Bitbucket）。

### 步骤2：连接Vercel
1. 访问 [Vercel官网](https://vercel.com)
2. 使用GitHub/GitLab/Bitbucket账号登录
3. 点击"New Project"
4. 导入您的仓库

### 步骤3：配置项目
Vercel会自动检测项目类型，但您可能需要手动配置：

#### 前端配置（推荐）
- **Framework Preset**: Vite
- **Build Command**: `cd frontend && npm run build`
- **Output Directory**: `frontend/dist`
- **Install Command**: `cd frontend && npm install`

#### 环境变量
在Vercel控制台设置以下环境变量：

| 变量名 | 值 | 说明 |
|--------|-----|------|
| `VITE_API_BASE_URL` | `https://your-backend-api.com` | 后端API地址 |

### 步骤4：部署后端（可选）
后端可以部署到不同的平台：

#### 选项1：Vercel Functions（Python运行时）
1. 在项目根目录创建 `api/` 目录
2. 将后端代码移动到 `api/` 目录
3. Vercel会自动将Python文件部署为Serverless Functions

#### 选项2：Railway（推荐）
1. 访问 [Railway官网](https://railway.app)
2. 创建新项目，导入仓库
3. 选择 `backend/` 目录
4. 设置启动命令：`uvicorn app.main:app --host 0.0.0.0 --port $PORT`

#### 选项3：Render
1. 访问 [Render官网](https://render.com)
2. 创建Web Service，导入仓库
3. 选择 `backend/` 目录
4. 设置启动命令：`uvicorn app.main:app --host 0.0.0.0 --port $PORT`

### 步骤5：配置CORS
确保后端API允许前端域名的跨域请求：

```python
# 在backend/app/main.py中添加
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://your-frontend.vercel.app"],  # 前端域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## 🔧 环境变量配置

### 前端环境变量 (`frontend/.env.production`)
```env
VITE_API_BASE_URL=https://your-backend-api.com
```

### 后端环境变量
```env
DATABASE_URL=sqlite:///./data/app.db  # 或使用PostgreSQL
DEEPSEEK_API_KEY=your_api_key_here
DEEPSEEK_BASE_URL=https://api.deepseek.com
DEEPSEEK_MODEL=deepseek-chat
ENVIRONMENT=production
```

## 📁 项目结构建议

### 方案A：前后端分离部署（推荐）
```
ai-haiguitang/
├── frontend/          # 前端代码（部署到Vercel）
│   ├── src/
│   ├── package.json
│   └── vite.config.ts
├── backend/           # 后端代码（部署到Railway/Render）
│   ├── app/
│   ├── pyproject.toml
│   └── requirements.txt
└── README.md
```

### 方案B：全栈Vercel部署
```
ai-haiguitang/
├── frontend/          # 前端代码
│   └── ...           # Vercel自动部署
├── api/              # 后端API（Vercel Functions）
│   ├── main.py       # FastAPI应用
│   └── requirements.txt
└── vercel.json       # Vercel配置
```

## 🛠️ 部署脚本

### 一键部署脚本
创建 `deploy.sh` 脚本：

```bash
#!/bin/bash
# 部署脚本

echo "🚀 开始部署AI海龟汤..."

# 1. 构建前端
echo "📦 构建前端..."
cd frontend
npm run build

# 2. 推送代码到Git
echo "📤 推送代码到Git..."
cd ..
git add .
git commit -m "部署更新"
git push origin main

echo "✅ 部署流程已启动！"
echo "🔗 前端: https://your-frontend.vercel.app"
echo "🔗 后端API: https://your-backend-api.com"
```

### Vercel CLI部署
```bash
# 安装Vercel CLI
npm i -g vercel

# 登录
vercel login

# 部署前端
cd frontend
vercel --prod

# 部署后端（如果使用Vercel Functions）
cd ../api
vercel --prod
```

## 🔍 部署后检查

### 1. 检查前端
```bash
# 访问前端
curl -I https://your-frontend.vercel.app

# 检查构建文件
curl https://your-frontend.vercel.app/assets/index-*.js
```

### 2. 检查后端API
```bash
# 检查API健康
curl https://your-backend-api.com/docs

# 测试API端点
curl -X POST https://your-backend-api.com/api/v1/games/ \
  -H "Content-Type: application/json" \
  -d '{"soup_id": "1"}'
```

### 3. 检查CORS
```bash
# 测试CORS配置
curl -X OPTIONS https://your-backend-api.com/api/v1/games/ \
  -H "Origin: https://your-frontend.vercel.app" \
  -H "Access-Control-Request-Method: POST" \
  -v
```

## 🐛 常见问题

### 1. 构建失败
**问题**: `npm run build` 失败
**解决**:
```bash
# 清理缓存
cd frontend
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
npm run build
```

### 2. CORS错误
**问题**: 前端无法访问后端API
**解决**:
- 检查后端CORS配置
- 确保 `allow_origins` 包含前端域名
- 检查Vercel的headers配置

### 3. 环境变量未生效
**问题**: 环境变量在部署后未生效
**解决**:
- 在Vercel控制台重新设置环境变量
- 重启部署
- 检查变量名是否正确（区分大小写）

### 4. 静态文件404
**问题**: CSS/JS文件404错误
**解决**:
- 检查 `vite.config.ts` 的 `base` 配置
- 检查Vercel的 `outputDirectory` 配置
- 确保构建文件在正确的位置

## 📈 监控和维护

### 1. Vercel Analytics
- 访问量统计
- 性能监控
- 错误跟踪

### 2. 日志查看
```bash
# 使用Vercel CLI查看日志
vercel logs your-project.vercel.app

# 或通过控制台查看
```

### 3. 自动部署
配置GitHub Actions实现自动部署：

```yaml
# .github/workflows/deploy.yml
name: Deploy to Vercel
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
```

## 🔄 更新部署

### 小更新
```bash
# 修改代码后
git add .
git commit -m "修复xxx问题"
git push origin main
# Vercel会自动部署
```

### 大更新
```bash
# 1. 在本地测试
./scripts/start-all.sh --dev

# 2. 运行测试
./scripts/run-tests.sh

# 3. 构建测试
cd frontend && npm run build

# 4. 部署到预览环境
vercel

# 5. 确认无误后部署到生产
vercel --prod
```

## 📞 支持

如果遇到部署问题：

1. 查看Vercel文档：https://vercel.com/docs
2. 检查项目日志：`vercel logs`
3. 在GitHub Issues中报告问题

## 📄 许可证

本项目遵循MIT许可证。详见LICENSE文件。