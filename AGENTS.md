# AGENTS.md — AI 海龟汤 仓库协作规范

面向在本仓库中使用 AI 编码代理时的约定。**目标**：玩法与数据模型符合 [PRD.md](./PRD.md) 与 [TECH_DESIGN.md](./TECH_DESIGN.md)，统计与局后评分可测、可维护。

## 1. 项目概述

使用 **Vue 3 + TypeScript + Vite + Tailwind CSS** 开发的 AI 海龟汤游戏网站。前端通过 HTTP 调用后端 API，不持有 LLM Key。

## 2. 开发规范

### 2.1 数据管理
- **单一数据源**：游戏列表与对局状态须经由 **统一封装层** 读写（例如前端 `src/lib/storage.ts` 或 `api/games.ts`，或后端 Repository + 单一 service），**禁止**散落直接访问 `localStorage`、fetch 或 ORM。
- **状态与耗时**：创建局时写 `started_at`；仅在 `completed` 或 `abandoned` 且用户结束流程时写 `ended_at`；统计只认 `completed`。
- **接近度**：仅在对局进入终局流程后写入 `proximity_score` / `proximity_rationale`；对局中 UI 不得展示分数。
- **题库变更**：若修改 `key_facts` 语义， bump `soup_version` 或 `soup_id`，避免与旧局评分混用逻辑不清。

### 2.2 前端开发
- 使用 **Vue 3** 组合式 API（Composition API）
- 使用 **TypeScript**，确保类型安全
- 使用 **函数式组件 + Hooks**（Vue 3 的 `setup()` 或 `<script setup>`）
- 使用 **Tailwind CSS** 编写样式
- 组件要可复用，代码要有注释
- 副作用集中在明确的事件处理或 `watch`/`onMounted` 等，避免与存储/API 不同步

### 2.3 前后端联调的接口契约
- 接口前缀统一为 /api/v1
- 响应格式固定为 {code: number, message: string, data: any}
- 包含用户登录（POST）、获取用户信息（GET）两个接口
- 定义必填参数、数据类型、异常码（200=成功，400=参数错，500=服务端错）
- 输出格式：OpenAPI 3.0 文档 + Postman 可导入的 JSON

Vue3 + Vite 项目生成 mockjs 配置，要求：
- 拦截 /api/v1/user/* 接口
- 返回符合契约的模拟数据
- 包含异常场景（如参数缺失返回 400）
- 给出完整的安装和使用步骤

FastAPI 项目生成联调专用配置：
- 开启全量 CORS 跨域（联调阶段）
- 打印详细的请求日志（参数、请求头、响应）
- 给所有接口加参数校验（基于 Pydantic）
- 输出完整的代码和接入步骤

## 3. 代码风格

### 3.1 命名约定
- **组件名**：使用 PascalCase（如 `GamePlayView.vue`）
- **函数名**：使用 camelCase（如 `computeStats`）
- **常量**：使用 UPPER_SNAKE_CASE（如 `MAX_TURNS = 3`）
- **类型定义**：以 `T` 开头（如 `TStory`、`TGame`、`TTurn`）
- **数据模型**：`Game`, `Turn`, `Soup`, `JudgeAnswer` 与 TECH_DESIGN 一致；`Game.user_id` 必填；每条 `Turn` 含 `id`（回合 ID）、`game_id`（所属局 ID）

### 3.2 类型与结构
- TypeScript 严格模式
- 公共类型集中在 `types.ts`（或与 OpenAPI 生成类型对齐）
- API 往返 JSON 使用 **snake_case**（推荐 API 使用 snake_case + 前端类型映射）

## 4. 设计要求

### 4.1 视觉风格
- **整体风格**：神秘悬疑，深蓝色调（`bg-slate-900`）
- **强调色**：金色（`text-amber-400`）
- **圆角**：`rounded-lg`
- **阴影**：`shadow-lg`
- **移动端适配**：确保各种屏幕尺寸正常显示

### 4.2 界面设计原则
- 保持代码简洁，避免过度设计
- 优先实现核心功能
- 响应式设计，确保移动端体验良好

## 5. 测试要求

### 5.1 功能测试
- **统计**：对 `computeStats`（或等价函数）编写 Vitest 用例：空列表；仅 active；多局 completed；**仅同一 `user_id`** 的局参与聚合；平均用时与计数正确。
- **接近度（启发式）**：fixture `Soup` + 固定 `question`，断言 `heuristicProximityScore` 落在预期 **区间**（允许微调实现，但不得无断言）。
- **存储**：可选：序列化再反序列化后 `Game` 形状不变（或 API 契约测试）。

### 5.2 集成测试
- **API**：pytest + TestClient | 创建局（含 `user_id`）→ 回合含 `id`/`game_id` → complete → `turns` 含 `answer`；越权用户 404；abandon 不写入接近度
- **启发式裁判**：pytest | 固定输入 → `yes`/`no`/`irrelevant` 符合预期（可少量表驱动）

### 5.3 测试流程
- 每个功能完成后手动测试
- 确保各种屏幕尺寸正常显示
- 测试 AI 回答是否准确（在开发环境中）

## 6. 注意事项（评分与 LLM）

### 6.1 安全与密钥管理
- **AI API Key 安全**：密钥仅存服务端；前端构建产物中不得出现 `DEEPSEEK_API_KEY`
- **环境变量**：使用环境变量管理敏感信息，不在程序代码中硬编码 API Key
- **无密钥 CI**：默认测试不得依赖真实 LLM；LLM 路径用 mock 或跳过（`describe.skipIf`）

### 6.2 LLM 集成
- **重试机制**：批量评分失败时最多重试 2 次；最终失败保留 `null` 分数，不阻塞 `completed` 状态
- **无剧透**：LLM 生成的 `rationale` 若需上线，应经过保守提示词约束；代理修改 prompt 时保持与 PRD「理由不泄露汤底」一致
- **提供商**：可为 **DeepSeek** 或其他兼容 Chat Completions 的 API（见 TECH_DESIGN）

## 7. 环境变量配置

### 7.1 后端环境变量
- `DATABASE_URL` - 数据库连接字符串，如 `sqlite:///./data/app.db`
- `DEEPSEEK_API_KEY` - DeepSeek API 密钥（可选，缺省时使用启发式方法）
- `DEEPSEEK_BASE_URL` - DeepSeek API 基础 URL，默认 `https://api.deepseek.com`
- `DEEPSEEK_MODEL` - DeepSeek 模型名称，如 `deepseek-chat`

### 7.2 前端环境变量
- `VITE_API_BASE_URL` - 后端 API 地址，如 `http://127.0.0.1:8000`

**安全要求**：所有敏感密钥仅存在于后端环境变量；仓库与 CI 使用占位或空值 + mock。

## 8. 提交前检查

- 运行 `npm run test` 与 `npm run build`（路径以前端工程为准；若有后端则加上对应测试命令）
- 不在提交中纳入真实 API Key
- 确保代码符合本规范的所有要求

---

*版本：1.0.0 — 整合开发指令，明确 Vue 3 技术栈，增强设计规范与测试要求。*