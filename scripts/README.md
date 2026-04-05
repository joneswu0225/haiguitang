# AI海龟汤 - 运行脚本

本目录包含AI海龟汤项目的各种运行脚本，方便开发、测试和部署。

## 📁 脚本列表

### 1. 安装脚本
- **`install-deps.sh`** - 一键安装前后端所有依赖
- **`start-backend.sh`** - 启动后端服务
- **`start-frontend.sh`** - 启动前端服务

### 2. 启动脚本
- **`start-all.sh`** - 同时启动前后端服务
- **`stop-all.sh`** - 停止所有服务（由start-all.sh自动生成）

### 3. 测试脚本
- **`run-tests.sh`** - 运行前后端测试

## 🚀 快速开始

### 方法1：一键启动（推荐）
```bash
# 安装所有依赖
./scripts/install-deps.sh

# 启动所有服务
./scripts/start-all.sh
```

### 方法2：分步启动
```bash
# 仅启动后端
./scripts/start-backend.sh

# 仅启动前端（新终端）
./scripts/start-frontend.sh
```

### 方法3：使用tmux分屏启动
```bash
./scripts/start-all.sh --tmux
```

## 🔧 脚本详细说明

### `install-deps.sh`
安装项目所有依赖，支持多种包管理器：

**后端包管理器优先级：**
1. `uv` (推荐) - 极速Python包管理器
2. `poetry` - Python依赖管理工具
3. `pip` - Python标准包管理器

**前端包管理器优先级：**
1. `pnpm` - 快速、节省磁盘空间的包管理器
2. `yarn` - Facebook开发的包管理器
3. `npm` - Node.js默认包管理器

**常用选项：**
```bash
# 安装所有依赖
./scripts/install-deps.sh

# 仅安装后端依赖
./scripts/install-deps.sh --backend

# 仅安装前端依赖
./scripts/install-deps.sh --frontend

# 清理后重新安装
./scripts/install-deps.sh --clean

# 安装开发依赖
./scripts/install-deps.sh --dev
```

### `start-all.sh`
同时启动前后端服务，支持多种启动模式：

**常用选项：**
```bash
# 开发模式启动（默认）
./scripts/start-all.sh

# 使用tmux分屏
./scripts/start-all.sh --tmux

# 指定端口
./scripts/start-all.sh --backend-port 8080 --frontend-port 3000

# 生产模式构建
./scripts/start-all.sh --build
```

**服务地址：**
- 前端：http://localhost:5174
- 后端API：http://localhost:8000
- API文档：http://localhost:8000/docs

### `run-tests.sh`
运行项目测试，支持单元测试和集成测试：

**常用选项：**
```bash
# 运行所有测试
./scripts/run-tests.sh

# 仅后端测试
./scripts/run-tests.sh --backend

# 仅前端测试
./scripts/run-tests.sh --frontend

# 生成覆盖率报告
./scripts/run-tests.sh --coverage

# 详细输出
./scripts/run-tests.sh --verbose
```

## 📦 包管理器说明

### 后端包管理器

#### 1. **uv** (推荐)
极速的Python包管理器，由Astral开发（Ruff、Astral的创建者）。

**安装uv：**
```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# 或使用pip
pip install uv
```

**使用uv：**
```bash
# 安装依赖
uv pip install -e .

# 安装开发依赖
uv pip install -e .[dev]

# 同步依赖
uv sync
```

#### 2. **poetry**
传统的Python依赖管理工具。

**安装poetry：**
```bash
# macOS/Linux
curl -sSL https://install.python-poetry.org | python3 -

# 或使用pip
pip install poetry
```

#### 3. **pip**
Python标准包管理器，无需额外安装。

### 前端包管理器

#### 1. **pnpm** (推荐)
快速、节省磁盘空间的包管理器。

**安装pnpm：**
```bash
# macOS/Linux
curl -fsSL https://get.pnpm.io/install.sh | sh

# 或使用npm
npm install -g pnpm
```

#### 2. **yarn**
Facebook开发的包管理器。

**安装yarn：**
```bash
# macOS
brew install yarn

# 或使用npm
npm install -g yarn
```

#### 3. **npm**
Node.js默认包管理器，无需额外安装。

## 🔍 环境要求

### 后端
- Python 3.9+
- 推荐使用 `uv` 作为包管理器

### 前端
- Node.js 16.0.0+
- 推荐使用 `pnpm` 作为包管理器

## 🛠️ 开发工作流

### 1. 克隆项目
```bash
git clone <repository-url>
cd ai-haiguitang
```

### 2. 安装依赖
```bash
./scripts/install-deps.sh
```

### 3. 启动开发服务器
```bash
# 开发模式
./scripts/start-all.sh --dev

# 或分步启动
./scripts/start-backend.sh --dev
./scripts/start-frontend.sh --dev
```

### 4. 运行测试
```bash
# 运行所有测试
./scripts/run-tests.sh

# 运行特定测试
./scripts/run-tests.sh --backend
./scripts/run-tests.sh --frontend
```

### 5. 构建生产版本
```bash
# 前端构建
cd frontend
npm run build

# 或使用脚本
./scripts/start-frontend.sh --build
```

## 🐛 故障排除

### 1. 端口被占用
```bash
# 检查端口占用
lsof -i :8000
lsof -i :5174

# 停止占用进程
kill -9 <PID>
```

### 2. 依赖安装失败
```bash
# 清理后重新安装
./scripts/install-deps.sh --clean

# 或强制重新安装
./scripts/install-deps.sh --force
```

### 3. 服务无法启动
```bash
# 检查日志
tail -f backend.log
tail -f frontend.log

# 检查环境变量
cat backend/.env
cat frontend/.env
```

### 4. 测试失败
```bash
# 详细输出
./scripts/run-tests.sh --verbose

# 更新快照
./scripts/run-tests.sh --update
```

## 📝 环境变量

### 后端环境变量 (`backend/.env`)
```env
DATABASE_URL=sqlite:///./data/app.db
DEEPSEEK_API_KEY=your_api_key_here
DEEPSEEK_BASE_URL=https://api.deepseek.com
DEEPSEEK_MODEL=deepseek-chat
ENVIRONMENT=development
```

### 前端环境变量 (`frontend/.env`)
```env
VITE_API_BASE_URL=http://localhost:8000
```

## 🚢 部署

### Vercel部署
项目已配置Vercel部署，只需将代码推送到Git仓库即可自动部署。

### 手动部署
```bash
# 构建前端
cd frontend
npm run build

# 启动后端（生产模式）
cd backend
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

## 📄 许可证

本项目遵循MIT许可证。详见LICENSE文件。