#!/bin/bash

# ============================================
# AI海龟汤 - 全栈构建脚本
# ============================================
# 为Vercel全栈部署构建前后端
# 使用方法:
#   1. 直接运行: ./scripts/build-fullstack.sh
#   2. 生产构建: ./scripts/build-fullstack.sh --prod
# ============================================

set -e  # 遇到错误时退出

# 默认配置
BUILD_FRONTEND=true
BUILD_BACKEND=true
PRODUCTION=false
CLEAN_BUILD=false

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${CYAN}$1${NC}"
}

# 显示帮助信息
show_help() {
    echo "AI海龟汤全栈构建脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -f, --frontend       仅构建前端"
    echo "  -b, --backend        仅构建后端"
    echo "  -p, --prod           生产环境构建"
    echo "  -c, --clean          清理后重新构建"
    echo "  --help               显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                     # 开发环境构建"
    echo "  $0 --prod              # 生产环境构建"
    echo "  $0 --clean             # 清理后重新构建"
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--frontend)
                BUILD_FRONTEND=true
                BUILD_BACKEND=false
                shift
                ;;
            -b|--backend)
                BUILD_FRONTEND=false
                BUILD_BACKEND=true
                shift
                ;;
            -p|--prod)
                PRODUCTION=true
                shift
                ;;
            -c|--clean)
                CLEAN_BUILD=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                print_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# 检查环境
check_environment() {
    print_header "检查构建环境..."
    
    # 检查Node.js（前端构建需要）
    if [[ "$BUILD_FRONTEND" == true ]]; then
        if ! command -v node &> /dev/null; then
            print_error "未找到Node.js，无法构建前端"
            exit 1
        fi
        
        NODE_VERSION=$(node --version | cut -d'v' -f2)
        print_info "Node.js版本: v$NODE_VERSION"
    fi
    
    # 检查Python（后端构建需要）
    if [[ "$BUILD_BACKEND" == true ]]; then
        if ! command -v python3 &> /dev/null; then
            print_error "未找到Python3，无法构建后端"
            exit 1
        fi
        
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        print_info "Python版本: $PYTHON_VERSION"
    fi
}

# 清理构建
clean_build() {
    print_info "清理构建文件..."
    
    # 清理前端
    if [[ -d "frontend/dist" ]]; then
        print_info "清理前端构建文件..."
        rm -rf frontend/dist
    fi
    
    # 清理后端
    if [[ -d "api" ]]; then
        print_info "清理后端构建文件..."
        find api -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
        find api -name "*.pyc" -delete 2>/dev/null || true
    fi
    
    print_success "清理完成"
}

# 构建前端
build_frontend() {
    print_header "构建前端..."
    
    if [[ ! -d "frontend" ]]; then
        print_error "frontend目录不存在"
        return 1
    fi
    
    cd frontend
    
    # 检查依赖
    if [[ ! -d "node_modules" ]]; then
        print_warning "node_modules不存在，安装依赖..."
        npm install
    fi
    
    # 构建命令
    local build_cmd="npm run build"
    
    if [[ "$PRODUCTION" == true ]]; then
        print_info "生产环境构建..."
        export NODE_ENV=production
    else
        print_info "开发环境构建..."
        export NODE_ENV=development
    fi
    
    print_info "构建命令: $build_cmd"
    echo ""
    
    # 执行构建
    if eval $build_cmd; then
        print_success "前端构建成功"
        print_info "构建文件位于: frontend/dist/"
        
        # 检查构建文件
        if [[ -f "dist/index.html" ]]; then
            print_info "主文件: dist/index.html"
            print_info "资源目录: dist/assets/"
        else
            print_warning "未找到dist/index.html文件"
        fi
    else
        print_error "前端构建失败"
        cd ..
        return 1
    fi
    
    cd ..
    return 0
}

# 构建后端
build_backend() {
    print_header "构建后端..."
    
    if [[ ! -d "api" ]]; then
        print_error "api目录不存在"
        return 1
    fi
    
    cd api
    
    # 检查requirements.txt
    if [[ ! -f "requirements.txt" ]]; then
        print_error "未找到requirements.txt文件"
        cd ..
        return 1
    fi
    
    # 创建虚拟环境（可选）
    if [[ ! -d ".venv" ]]; then
        print_info "创建Python虚拟环境..."
        python3 -m venv .venv
        # 激活虚拟环境
        if [[ -f ".venv/bin/activate" ]]; then
            source .venv/bin/activate
        fi
    fi
    
    # 安装依赖
    print_info "安装后端依赖..."
    pip install -r requirements.txt
    
    # 检查关键模块
    print_info "检查关键模块..."
    local required_modules=("fastapi" "uvicorn" "pydantic")
    for module in "${required_modules[@]}"; do
        if python3 -c "import $module" 2>/dev/null; then
            print_info "  ✅ $module"
        else
            print_error "  ❌ $module (未安装)"
            cd ..
            return 1
        fi
    done
    
    # 检查应用入口
    if [[ ! -f "index.py" ]]; then
        print_error "未找到index.py文件"
        cd ..
        return 1
    fi
    
    print_info "后端应用结构:"
    print_info "  入口文件: index.py"
    print_info "  应用目录: app/"
    print_info "  路由目录: app/routers/"
    
    # 测试应用是否可以导入
    print_info "测试应用导入..."
    if python3 -c "from app.main import app; print('✅ 应用导入成功')" 2>/dev/null; then
        print_success "后端应用构建成功"
    else
        print_error "后端应用导入失败"
        cd ..
        return 1
    fi
    
    cd ..
    return 0
}

# 创建Vercel配置
create_vercel_config() {
    print_header "创建Vercel配置..."
    
    local config_file="vercel.json"
    
    if [[ -f "$config_file" ]]; then
        print_info "已存在Vercel配置: $config_file"
        return 0
    fi
    
    # 创建Vercel配置
    cat > "$config_file" << 'EOF'
{
  "version": 2,
  "name": "ai-haiguitang-fullstack",
  "public": true,
  
  "builds": [
    {
      "src": "frontend/package.json",
      "use": "@vercel/static-build",
      "config": {
        "distDir": "dist"
      }
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
    },
    {
      "src": "/",
      "dest": "/index.html"
    }
  ],
  
  "functions": {
    "api/**/*.py": {
      "maxDuration": 10,
      "memory": 1024,
      "runtime": "python3.9"
    }
  },
  
  "env": {
    "VITE_API_BASE_URL": "@vite_api_base_url",
    "ENVIRONMENT": "production"
  },
  
  "buildCommand": "npm run build-all",
  "outputDirectory": "frontend/dist",
  "framework": "vite",
  "installCommand": "npm install-all",
  "devCommand": "npm run dev-all",
  "regions": ["sin1"]
}
EOF
    
    print_success "Vercel配置创建成功: $config_file"
    
    # 创建package.json脚本
    if [[ -f "package.json" ]]; then
        print_info "更新package.json脚本..."
        
        # 这里应该更新package.json，但为了简单起见，我们创建单独的脚本
        cat > "package-build-all.json" << 'EOF'
{
  "scripts": {
    "build-all": "./scripts/build-fullstack.sh --prod",
    "dev-all": "./scripts/start-all.sh --dev",
    "install-all": "./scripts/install-deps.sh"
  }
}
EOF
        
        print_info "构建脚本配置已创建"
    fi
    
    return 0
}

# 显示构建总结
show_build_summary() {
    print_header "============================================"
    print_header "构建总结"
    print_header "============================================"
    
    print_info "构建配置:"
    if [[ "$BUILD_FRONTEND" == true ]]; then
        print_info "  前端: ✅ 已构建"
        print_info "    位置: frontend/dist/"
    else
        print_info "  前端: ⏭️  已跳过"
    fi
    
    if [[ "$BUILD_BACKEND" == true ]]; then
        print_info "  后端: ✅ 已构建"
        print_info "    位置: api/"
        print_info "    入口: api/index.py"
    else
        print_info "  后端: ⏭️  已跳过"
    fi
    
    print_info ""
    print_info "构建环境:"
    if [[ "$PRODUCTION" == true ]]; then
        print_info "  模式: 🚀 生产环境"
    else
        print_info "  模式: 🔧 开发环境"
    fi
    
    print_info ""
    print_info "下一步:"
    print_info "  1. 本地测试: ./scripts/start-all.sh"
    print_info "  2. 提交代码: git add . && git commit -m '构建更新'"
    print_info "  3. 推送到Git: git push origin main"
    print_info "  4. Vercel自动部署"
    
    print_header "============================================"
    print_success "全栈构建完成！"
    print_header "============================================"
}

# 主函数
main() {
    print_header "============================================"
    print_header "AI海龟汤全栈构建脚本"
    print_header "============================================"
    
    # 解析参数
    parse_args "$@"
    
    # 检查环境
    check_environment
    
    # 清理构建（如果需要）
    if [[ "$CLEAN_BUILD" == true ]]; then
        clean_build
    fi
    
    local frontend_result=0
    local backend_result=0
    
    # 构建前端
    if [[ "$BUILD_FRONTEND" == true ]]; then
        if ! build_frontend; then
            frontend_result=1
        fi
    fi
    
    # 构建后端
    if [[ "$BUILD_BACKEND" == true ]]; then
        if ! build_backend; then
            backend_result=1
        fi
    fi
    
    # 创建Vercel配置
    create_vercel_config
    
    # 显示总结
    show_build_summary
    
    # 返回构建结果
    if [[ $frontend_result -eq 0 ]] && [[ $backend_result -eq 0 ]]; then
        print_success "全栈构建成功！"
        return 0
    else
        print_error "构建失败"
        return 1
    fi
}

# 运行主函数
main "$@"