# AI海龟汤 - Vercel全栈部署指南

## 🎯 部署目标

在Vercel上同时部署：
- ✅ **前端**: Vue 3 + Vite应用
- ✅ **后端**: FastAPI Python应用（作为Serverless Functions）
- ✅ **API路由**: `/api/v1/*` 指向Python后端
- ✅ **静态文件**: 所有其他请求指向前端

## 📁 项目结构（Vercel适配版）

```
ai-haiguitang/
├── frontend/                 # 前端代码（Vue 3 + Vite）
│   ├── src/
│   ├── package.json
│   ├── vite.config.ts
│   └── dist/                # 构建输出（自动生成）
├── api/                     # 后端代码（Vercel Functions）
│   ├── index.py            # Vercel Functions入口点
│   ├── requirements.txt    # Python依赖
│   └── app/               # FastAPI应用
│       ├── main.py        # FastAPI应用主文件
│       ├── routers/       # API路由
│       │   ├── soups.py   # 题库路由
│       │   ├── games.py   # 游戏路由
│       │   └── judge.py   # 裁判路由
│       └── data_store.py  # 内存存储（生产环境应使用数据库）
├── scripts/                # 构建和运行脚本
│   ├── build-fullstack.sh # 全栈构建脚本
│   ├── start-all.sh       # 本地启动脚本
│   └── ...
├── vercel.json            # Vercel配置（主配置）
├── vercel-fullstack.json  # 全栈配置（备用）
└── README.md              # 项目说明
```

## 🔧 Vercel配置详解

### `vercel.json` - 核心配置
```json
{
  "version": 2,
  "builds": [
    {
      "src": "frontend/package.json",
      "use": "@vercel/static-build",
      "config": { "distDir": "dist" }
    },
    {
      "src": "api/**/*.py",
      "use": "@vercel/python"
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "/api/$1"
    },
    {
      "src": "/(.*)",
      "dest": "/$1"
    }
  ]
}
```

### 配置说明
1. **`builds`**: 定义构建配置
   - 前端: 使用 `@vercel/static-build` 构建Vite应用
   - 后端: 使用 `@vercel/python` 处理Python文件

2. **`routes`**: 定义路由规则
   - `/api/*` → 后端Python Functions
   - `/*` → 前端静态文件

3. **`functions`** (可选): 配置Serverless Functions
   - `maxDuration`: 最大执行时间（秒）
   - `memory`: 内存分配（MB）
   - `runtime`: Python版本

## 🚀 部署步骤

### 步骤1：准备代码
```bash
# 确保所有文件已提交
git add .
git commit -m "准备Vercel全栈部署"
git push origin main
```

### 步骤2：连接Vercel
1. 访问 [Vercel官网](https://vercel.com)
2. 使用GitHub/GitLab/Bitbucket登录
3. 点击"New Project"
4. 导入您的仓库

### 步骤3：配置项目
Vercel会自动检测配置，但您可以手动设置：

| 设置项 | 值 | 说明 |
|--------|-----|------|
| **Framework Preset** | Vite | 前端框架 |
| **Build Command** | `cd frontend && npm run build` | 前端构建命令 |
| **Output Directory** | `frontend/dist` | 构建输出目录 |
| **Install Command** | `cd frontend && npm install` | 依赖安装 |

### 步骤4：设置环境变量
在Vercel控制台的"Environment Variables"中设置：

| 变量名 | 值 | 必需 | 说明 |
|--------|-----|------|------|
| `VITE_API_BASE_URL` | `/api` | ✅ | 前端API地址 |
| `ENVIRONMENT` | `production` | ⚠️ | 环境标识 |
| `PYTHON_VERSION` | `3.9` | ⚠️ | Python版本 |

### 步骤5：部署
点击"Deploy"，等待构建完成（约2-5分钟）。

## 🔍 验证部署

### 1. 检查前端
```bash
# 访问部署的URL
curl -I https://your-project.vercel.app

# 检查静态文件
curl https://your-project.vercel.app/assets/index-*.js
```

### 2. 检查后端API
```bash
# 检查API健康
curl https://your-project.vercel.app/api/docs

# 测试API端点
curl https://your-project.vercel.app/api/v1/soups

# 创建游戏测试
curl -X POST https://your-project.vercel.app/api/v1/games/ \
  -H "Content-Type: application/json" \
  -d '{"soup_id": "1"}'
```

### 3. 检查集成
1. 访问前端页面
2. 尝试创建游戏
3. 提交问题
4. 完成游戏
5. 查看统计

## 🛠️ 本地开发与测试

### 一键启动
```bash
# 安装依赖
./scripts/install-deps.sh

# 启动全栈服务
./scripts/start-all.sh
```

### 构建测试
```bash
# 生产环境构建测试
./scripts/build-fullstack.sh --prod

# 清理后重新构建
./scripts/build-fullstack.sh --clean
```

### 本地访问
- 前端: http://localhost:5174
- 后端API: http://localhost:8000
- API文档: http://localhost:8000/docs

## ⚠️ Vercel Functions限制

### 1. 无状态性
- 每次请求都是新的实例
- 内存数据在请求间不共享
- **解决方案**: 使用外部数据库（如Supabase、PlanetScale）

### 2. 执行时间限制
- 免费版: 最大10秒
- Pro版: 最大60秒
- **解决方案**: 优化代码，避免长时间操作

### 3. 冷启动延迟
- 首次请求可能有延迟（1-3秒）
- **解决方案**: 使用`warm`函数或付费计划

### 4. 内存限制
- 免费版: 1024MB
- Pro版: 最多3008MB
- **解决方案**: 优化内存使用

## 🔄 生产环境建议

### 1. 数据库
使用外部数据库替代内存存储：
- **Supabase**: PostgreSQL + 实时功能
- **PlanetScale**: MySQL兼容，无服务器
- **MongoDB Atlas**: 文档数据库
- **Railway PostgreSQL**: 简单易用

### 2. 文件存储
- **Vercel Blob**: 内置对象存储
- **Cloudflare R2**: 兼容S3，便宜
- **Supabase Storage**: 与数据库集成

### 3. 监控和日志
- **Vercel Analytics**: 内置分析
- **Logtail**: 实时日志
- **Sentry**: 错误监控

### 4. CDN和缓存
- **Vercel Edge Network**: 全球CDN
- **Cache-Control头**: 配置静态文件缓存

## 🐛 常见问题解决

### 问题1: 构建失败
**症状**: Vercel构建失败
**解决**:
```bash
# 本地测试构建
./scripts/build-fullstack.sh --prod

# 检查错误日志
cat frontend/build.log
```

### 问题2: API 404错误
**症状**: `/api/*` 返回404
**解决**:
1. 检查 `vercel.json` 路由配置
2. 确认 `api/` 目录存在
3. 检查Python文件语法

### 问题3: CORS错误
**症状**: 前端无法访问API
**解决**:
1. 检查后端CORS配置
2. 确认 `allow_origins` 包含前端域名
3. 检查Vercel的headers配置

### 问题4: 环境变量问题
**症状**: 环境变量未生效
**解决**:
1. 在Vercel控制台重新设置
2. 重启部署
3. 检查变量名大小写

## 📊 部署后检查清单

- [ ] 前端网站可正常访问
- [ ] API文档可访问 (`/api/docs`)
- [ ] 创建游戏功能正常
- [ ] 提交问题功能正常
- [ ] 完成游戏功能正常
- [ ] 统计数据正确显示
- [ ] 没有JavaScript错误
- [ ] 没有CORS错误
- [ ] 移动端适配正常
- [ ] 性能可接受（首次加载<3秒）

## 🔗 相关资源

### 官方文档
- [Vercel Documentation](https://vercel.com/docs)
- [Vite on Vercel](https://vercel.com/guides/deploying-vite-with-vercel)
- [Python on Vercel](https://vercel.com/docs/concepts/functions/serverless-functions/runtimes/python)
- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/)

### 项目文档
- `DEPLOYMENT.md` - 详细部署指南
- `scripts/README.md` - 脚本使用说明
- `AGENTS.md` - 项目开发规范

### 工具和库
- [uv](https://github.com/astral-sh/uv) - 极速Python包管理器
- [pnpm](https://pnpm.io/) - 快速Node.js包管理器
- [Vercel CLI](https://vercel.com/docs/cli) - 命令行工具

## 📞 技术支持

### 问题报告
1. 检查Vercel构建日志
2. 查看浏览器控制台错误
3. 在GitHub Issues中报告

### 社区支持
- [Vercel Community](https://vercel.com/community)
- [FastAPI Discord](https://discord.gg/VQjSZae)
- [Vue.js Forum](https://forum.vuejs.org/)

### 专业支持
- Vercel Enterprise支持
- 第三方咨询公司
- 自由开发者

---

**最后更新**: 2024年1月  
**版本**: 1.0.0  
**状态**: ✅ 生产就绪