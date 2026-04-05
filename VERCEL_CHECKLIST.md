# Vercel部署检查清单

## ✅ 部署前检查

### 1. 代码准备
- [ ] 代码已提交到Git仓库（GitHub/GitLab/Bitbucket）
- [ ] 没有未提交的更改
- [ ] `.gitignore` 文件已正确配置
- [ ] 没有敏感信息（API密钥等）在代码中

### 2. 前端检查
- [ ] `frontend/package.json` 存在且配置正确
- [ ] `frontend/vite.config.ts` 存在且配置正确
- [ ] `frontend/.env.production` 或环境变量已准备
- [ ] 前端可以本地构建成功：`cd frontend && npm run build`
- [ ] 构建产物在 `frontend/dist/` 目录

### 3. 后端检查（如果部署到Vercel）
- [ ] 后端API可以本地运行：`cd backend && uvicorn app.main:app`
- [ ] CORS配置正确（允许前端域名）
- [ ] 数据库连接配置正确
- [ ] API密钥等敏感信息使用环境变量

### 4. 项目结构
- [ ] 项目结构清晰，前后端分离
- [ ] 必要的配置文件存在（`vercel.json` 可选）
- [ ] 文档完整（README.md, DEPLOYMENT.md）

## 🔧 Vercel配置

### 项目设置
- [ ] 项目名称：`ai-haiguitang-frontend`
- [ ] 框架预设：`Vite`
- [ ] 根目录：`frontend`（或留空让Vercel自动检测）
- [ ] 构建命令：`npm run build`
- [ ] 输出目录：`dist`
- [ ] 安装命令：`npm install`

### 环境变量
在Vercel控制台设置以下环境变量：

| 变量名 | 值 | 必需 | 说明 |
|--------|-----|------|------|
| `VITE_API_BASE_URL` | `https://your-backend-api.com` | ✅ | 后端API地址 |
| `NODE_ENV` | `production` | ⚠️ | Node.js环境 |
| `NODE_VERSION` | `18` | ⚠️ | Node.js版本 |

### 域名配置（可选）
- [ ] 自定义域名已配置
- [ ] SSL证书有效
- [ ] DNS解析正确

## 🚀 部署步骤

### 第一步：连接仓库
1. [ ] 访问 [Vercel官网](https://vercel.com)
2. [ ] 使用Git提供商账号登录
3. [ ] 点击"New Project"
4. [ ] 导入您的Git仓库

### 第二步：配置项目
1. [ ] 项目名称：`ai-haiguitang-frontend`
2. [ ] 框架预设：选择"Vite"
3. [ ] 根目录：`frontend`
4. [ ] 环境变量：设置 `VITE_API_BASE_URL`
5. [ ] 点击"Deploy"

### 第三步：等待部署
1. [ ] 等待构建完成（约1-3分钟）
2. [ ] 检查构建日志是否有错误
3. [ ] 确认部署成功

### 第四步：验证部署
1. [ ] 访问部署的URL
2. [ ] 检查页面是否正常加载
3. [ ] 测试主要功能
4. [ ] 检查控制台是否有错误

## 🔍 部署后验证

### 前端验证
```bash
# 检查页面可访问
curl -I https://your-project.vercel.app

# 检查静态资源
curl https://your-project.vercel.app/assets/index-*.js

# 检查环境变量
# 在浏览器控制台检查 process.env.VITE_API_BASE_URL
```

### 后端验证（如果分开部署）
```bash
# 检查API健康
curl https://your-backend-api.com/docs

# 测试API端点
curl -X POST https://your-backend-api.com/api/v1/games/ \
  -H "Content-Type: application/json" \
  -d '{"soup_id": "1"}'
```

### 集成测试
1. [ ] 前端能正常加载
2. [ ] 前端能连接到后端API
3. [ ] 游戏功能正常工作
4. [ ] 没有CORS错误
5. [ ] 没有404错误

## 🐛 故障排除

### 构建失败
**症状**: Vercel构建失败
**解决**:
1. 检查构建日志
2. 本地运行 `cd frontend && npm run build` 测试
3. 清理缓存：`rm -rf frontend/node_modules frontend/package-lock.json`
4. 重新安装：`cd frontend && npm install`

### 页面空白
**症状**: 页面加载但显示空白
**解决**:
1. 检查浏览器控制台错误
2. 检查 `VITE_API_BASE_URL` 环境变量
3. 检查路由配置
4. 检查Vite的 `base` 配置

### CORS错误
**症状**: 前端无法访问后端API
**解决**:
1. 检查后端CORS配置
2. 确保前端域名在后端的 `allow_origins` 中
3. 检查Vercel的headers配置

### 环境变量问题
**症状**: 环境变量未生效
**解决**:
1. 在Vercel控制台重新设置环境变量
2. 重启部署
3. 检查变量名是否正确（Vite变量需要 `VITE_` 前缀）

## 📊 监控和维护

### 日常检查
- [ ] 网站可访问
- [ ] API响应正常
- [ ] 没有用户报告问题
- [ ] 日志没有异常错误

### 性能监控
- [ ] 页面加载时间
- [ ] API响应时间
- [ ] 错误率
- [ ] 用户访问量

### 更新部署
1. [ ] 在本地测试更改
2. [ ] 运行测试：`./scripts/run-tests.sh`
3. [ ] 提交代码到Git
4. [ ] Vercel自动部署
5. [ ] 验证新版本

## 🔄 回滚步骤

如果部署出现问题：

1. **使用Vercel回滚**
   - 进入Vercel控制台
   - 选择项目
   - 点击"Deployments"
   - 找到之前的成功部署
   - 点击"..." → "Promote to Production"

2. **Git回滚**
   ```bash
   # 回滚到上一个提交
   git revert HEAD
   git push origin main
   ```

3. **手动修复**
   - 修复问题
   - 提交修复
   - 重新部署

## 📞 支持资源

### Vercel文档
- [Vercel官方文档](https://vercel.com/docs)
- [Vite on Vercel](https://vercel.com/guides/deploying-vite-with-vercel)
- [环境变量配置](https://vercel.com/docs/projects/environment-variables)

### 项目文档
- `DEPLOYMENT.md` - 详细部署指南
- `scripts/README.md` - 脚本使用说明
- `AGENTS.md` - 项目开发规范

### 问题报告
- GitHub Issues: 报告部署问题
- Vercel Support: 平台相关问题
- 项目文档: 常见问题解答

## 🎯 成功标准

部署成功应满足以下条件：

1. ✅ 前端网站可正常访问
2. ✅ 所有页面功能正常
3. ✅ 前端能连接到后端API
4. ✅ 没有JavaScript错误
5. ✅ 没有CORS错误
6. ✅ 性能可接受（首次加载<3秒）
7. ✅ 移动端适配正常
8. ✅ SEO基础配置正确

## 📅 维护计划

### 每日
- [ ] 检查网站状态
- [ ] 查看错误日志

### 每周
- [ ] 检查依赖更新
- [ ] 备份重要数据
- [ ] 性能分析

### 每月
- [ ] 安全更新
- [ ] 性能优化
- [ ] 用户反馈整理

---

**最后更新**: 2024年1月
**版本**: 1.0.0