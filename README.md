# AI 海龟汤游戏

基于 AI 裁判的海龟汤推理游戏，玩家通过提问逐步还原真相，获得局后复盘与个人统计数据。

## 项目结构

```
haiguitang/
├── PRD.md                 # 产品需求文档
├── TECH_DESIGN.md         # 技术设计文档
├── AGENTS.md              # AI 代理协作规范
├── RESEARCH.md            # 研究文档
├── frontend/              # 前端应用 (Vue 3 + TypeScript + Vite)
│   ├── package.json
│   ├── vite.config.ts
│   ├── tailwind.config.ts
│   ├── postcss.config.js
│   ├── tsconfig.json
│   ├── index.html
│   └── src/
│       ├── main.ts
│       ├── App.vue
│       ├── router/
│       ├── views/
│       ├── components/
│       ├── api/
│       ├── lib/
│       └── types.ts
└── backend/               # 后端 API (Python + FastAPI)
    ├── pyproject.toml
    ├── .env.example
    └── app/
        ├── main.py
        ├── config.py
        ├── schemas.py
        └── routers/
```

## 技术栈

### 前端
- Vue 3 + Composition API
- TypeScript
- Vite
- Tailwind CSS
- Vue Router
- Pinia (状态管理)
- Axios (HTTP 客户端)

### 后端
- Python 3.9+
- FastAPI
- SQLite (MVP)
- Pydantic (数据验证)
- DeepSeek API (LLM 集成)

## 快速开始

### 1. 环境准备

确保已安装：
- Node.js 18+ 和 npm
- Python 3.9+ 和 pip
- Git

### 2. 前端启动

```bash
# 进入前端目录
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

前端将在 http://localhost:5173 启动

### 3. 后端启动

```bash
# 进入后端目录
cd backend

# 安装依赖 (使用 poetry)
pip install poetry
poetry install

# 复制环境变量文件
cp .env.example .env

# 启动开发服务器
poetry run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

后端将在 http://localhost:8000 启动，API 文档在 http://localhost:8000/docs

### 4. 环境变量配置

#### 前端 (.env)
```env
VITE_API_BASE_URL=http://localhost:8000
```

#### 后端 (.env)
```env
DATABASE_URL=sqlite:///./data/app.db
# DEEPSEEK_API_KEY=your_api_key_here (可选)
DEEPSEEK_BASE_URL=https://api.deepseek.com
DEEPSEEK_MODEL=deepseek-chat
```

## 核心功能

### 游戏流程
1. **大厅**：选择海龟汤谜题
2. **对局**：通过提问获取 AI 裁判的「是/不是/无关」回答
3. **复盘**：完成游戏后查看汤底和接近度评分

### 数据模型
- `Game`：游戏对局，包含状态、时间、回合列表
- `Turn`：单个问答回合，包含问题、回答、接近度评分
- `Soup`：海龟汤谜题，包含汤面、汤底、关键事实

### 状态管理
- `active`：进行中的游戏
- `completed`：已完成并计入统计的游戏
- `abandoned`：已放弃不计入统计的游戏

## 开发规范

### 代码风格
- 组件名使用 PascalCase (`GamePlayView.vue`)
- 函数名使用 camelCase (`computeStats`)
- 常量使用 UPPER_SNAKE_CASE (`MAX_TURNS = 3`)
- 类型定义以 `T` 开头 (`TGame`, `TTurn`)

### 安全要求
- API Key 仅存在于后端环境变量
- 前端构建产物不包含敏感信息
- 无密钥 CI 测试环境

## 测试

### 前端测试
```bash
cd frontend
npm run test        # 运行测试
npm run test:ui     # 运行测试 UI
npm run typecheck   # 类型检查
```

### 后端测试
```bash
cd backend
poetry run pytest   # 运行测试
```

## 部署

### 前端部署
```bash
cd frontend
npm run build      # 构建生产版本
```

构建产物在 `dist/` 目录，可部署到静态托管服务。

### 后端部署
```bash
cd backend
poetry install --no-dev  # 安装生产依赖
```

推荐使用 Railway、Fly.io 或 VPS 部署。

## 许可证

MIT License