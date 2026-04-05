#!/bin/bash

# ============================================
# AI海龟汤 - 依赖安装脚本
# ============================================
# 一键安装前后端所有依赖
# 使用方法:
#   1. 直接运行: ./scripts/install-deps.sh
#   2. 仅安装后端: ./scripts/install-deps.sh --backend
#   3. 仅安装前端: ./scripts/install-deps.sh --frontend
#   4. 开发依赖: ./scripts/install-deps.sh --dev
# ============================================

set -e  # 遇到错误时退出

# 默认配置
INSTALL_BACKEND=true
INSTALL_FRONTEND=true
INSTALL_DEV_DEPS=false
FORCE_INSTALL=false
CLEAN_INSTALL=false

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
    echo "AI海龟汤依赖安装脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -b, --backend         仅安装后端依赖"
    echo "  -f, --frontend        仅安装前端依赖"
    echo "  -d, --dev             安装开发依赖"
    echo "  -c, --clean           清理后重新安装"
    echo "  -F, --force           强制重新安装所有依赖"
    echo "  --skip-check          跳过环境检查"
    echo "  --help                显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                     # 安装所有依赖"
    echo "  $0 --backend           # 仅安装后端依赖"
    echo "  $0 --frontend          # 仅安装前端依赖"
    echo "  $0 --dev               # 安装开发依赖"
    echo "  $0 --clean             # 清理后重新安装"
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -b|--backend)
                INSTALL_BACKEND=true
                INSTALL_FRONTEND=false
                shift
                ;;
            -f|--frontend)
                INSTALL_BACKEND=false
                INSTALL_FRONTEND=true
                shift
                ;;
            -d|--dev)
                INSTALL_DEV_DEPS=true
                shift
                ;;
            -c|--clean)
                CLEAN_INSTALL=true
                shift
                ;;
            -F|--force)
                FORCE_INSTALL=true
                shift
                ;;
            --skip-check)
                SKIP_CHECK=true
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
    if [[ "$SKIP_CHECK" == true ]]; then
        return
    fi
    
    print_header "检查环境..."
    
    # 检查Python
    if [[ "$INSTALL_BACKEND" == true ]]; then
        if ! command -v python3 &> /dev/null; then
            print_error "未找到Python3，请先安装Python3 (>= 3.9)"
            exit 1
        fi
        
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        print_info "Python版本: $PYTHON_VERSION"
        
        # 检查Python版本
        REQUIRED_VERSION="3.9"
        if [[ $(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1) != "$REQUIRED_VERSION" ]]; then
            print_warning "建议使用Python 3.9或更高版本"
        fi
    fi
    
    # 检查Node.js
    if [[ "$INSTALL_FRONTEND" == true ]]; then
        if ! command -v node &> /dev/null; then
            print_error "未找到Node.js，请先安装Node.js (>= 16.0.0)"
            exit 1
        fi
        
        NODE_VERSION=$(node --version | cut -d'v' -f2)
        print_info "Node.js版本: v$NODE_VERSION"
        
        # 检查Node.js版本
        REQUIRED_VERSION="16.0.0"
        if [[ $(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1) != "$REQUIRED_VERSION" ]]; then
            print_warning "建议使用Node.js 16.0.0或更高版本"
        fi
    fi
    
    # 检查包管理器
    if [[ "$INSTALL_FRONTEND" == true ]]; then
        if command -v pnpm &> /dev/null; then
            FRONTEND_PM="pnpm"
            print_info "前端包管理器: pnpm"
        elif command -v yarn &> /dev/null; then
            FRONTEND_PM="yarn"
            print_info "前端包管理器: yarn"
        elif command -v npm &> /dev/null; then
            FRONTEND_PM="npm"
            print_info "前端包管理器: npm"
        else
            print_error "未找到前端包管理器 (npm/yarn/pnpm)"
            exit 1
        fi
    fi
    
    # 检查uv
    if [[ "$INSTALL_BACKEND" == true ]]; then
        if command -v uv &> /dev/null; then
            BACKEND_PM="uv"
            print_info "后端包管理器: uv"
        elif command -v poetry &> /dev/null; then
            BACKEND_PM="poetry"
            print_info "后端包管理器: poetry (建议使用uv)"
        else
            print_warning "未找到uv，将使用pip安装后端依赖"
            BACKEND_PM="pip"
        fi
    fi
}

# 清理安装
clean_installation() {
    print_header "清理安装..."
    
    if [[ "$INSTALL_BACKEND" == true ]]; then
        print_info "清理后端..."
        if [[ -d "backend" ]]; then
            cd backend
            # 清理Python缓存
            find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
            find . -type f -name "*.pyc" -delete 2>/dev/null || true
            find . -type f -name "*.pyo" -delete 2>/dev/null || true
            find . -type f -name "*.pyd" -delete 2>/dev/null || true
            find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
            cd ..
        fi
    fi
    
    if [[ "$INSTALL_FRONTEND" == true ]]; then
        print_info "清理前端..."
        if [[ -d "frontend" ]]; then
            cd frontend
            # 清理node_modules
            if [[ "$FORCE_INSTALL" == true ]] || [[ "$CLEAN_INSTALL" == true ]]; then
                print_info "删除node_modules..."
                rm -rf node_modules 2>/dev/null || true
            fi
            # 清理构建缓存
            rm -rf dist 2>/dev/null || true
            rm -rf .vite 2>/dev/null || true
            rm -rf .cache 2>/dev/null || true
            cd ..
        fi
    fi
    
    print_success "清理完成"
}

# 安装后端依赖
install_backend_deps() {
    print_header "安装后端依赖..."
    
    if [[ ! -d "backend" ]]; then
        print_error "backend目录不存在"
        return 1
    fi
    
    cd backend
    
    # 检查pyproject.toml
    if [[ ! -f "pyproject.toml" ]]; then
        print_error "未找到pyproject.toml文件"
        cd ..
        return 1
    fi
    
    # 根据包管理器安装依赖
    case $BACKEND_PM in
        uv)
            print_info "使用uv安装依赖..."
            
            if [[ "$INSTALL_DEV_DEPS" == true ]]; then
                print_info "安装所有依赖（包括开发依赖）..."
                uv pip install -e .
            else
                print_info "安装生产依赖..."
                uv pip install --no-dev -e .
            fi
            
            if [[ $? -eq 0 ]]; then
                print_success "uv依赖安装成功"
            else
                print_error "uv依赖安装失败"
                cd ..
                return 1
            fi
            ;;
        poetry)
            print_info "使用poetry安装依赖..."
            
            if [[ "$INSTALL_DEV_DEPS" == true ]]; then
                print_info "安装所有依赖（包括开发依赖）..."
                poetry install --no-root
            else
                print_info "安装生产依赖..."
                poetry install --no-root --only main
            fi
            
            if [[ $? -eq 0 ]]; then
                print_success "poetry依赖安装成功"
            else
                print_error "poetry依赖安装失败"
                cd ..
                return 1
            fi
            ;;
        pip)
            print_info "使用pip安装依赖..."
            
            # 生成requirements.txt（如果不存在）
            if [[ ! -f "requirements.txt" ]]; then
                print_warning "未找到requirements.txt，从pyproject.toml提取依赖..."
                
                # 简单的依赖提取（实际项目可能需要更复杂的解析）
                cat > requirements.txt << 'EOF'
fastapi>=0.104.0
uvicorn>=0.24.0
sqlalchemy>=2.0.0
pydantic>=2.0.0
pydantic-settings>=2.0.0
python-dotenv>=1.0.0
httpx>=0.25.0
openai>=1.0.0
python-multipart>=0.0.6
EOF
                
                if [[ "$INSTALL_DEV_DEPS" == true ]]; then
                    cat >> requirements.txt << 'EOF'
pytest>=7.4.0
pytest-asyncio>=0.21.0
EOF
                fi
            fi
            
            # 安装依赖
            pip install -r requirements.txt
            
            if [[ $? -eq 0 ]]; then
                print_success "pip依赖安装成功"
            else
                print_error "pip依赖安装失败"
                cd ..
                return 1
            fi
            ;;
    esac
    
    # 创建.env.example（如果不存在）
    if [[ ! -f ".env.example" ]] && [[ -f ".env.example" ]]; then
        print_info "创建环境变量示例文件..."
        cp .env.example .env.example 2>/dev/null || true
    fi
    
    cd ..
    print_success "后端依赖安装完成"
}

# 安装前端依赖
install_frontend_deps() {
    print_header "安装前端依赖..."
    
    if [[ ! -d "frontend" ]]; then
        print_error "frontend目录不存在"
        return 1
    fi
    
    cd frontend
    
    # 检查package.json
    if [[ ! -f "package.json" ]]; then
        print_error "未找到package.json文件"
        cd ..
        return 1
    fi
    
    # 根据包管理器安装依赖
    case $FRONTEND_PM in
        pnpm)
            print_info "使用pnpm安装依赖..."
            
            if [[ "$FORCE_INSTALL" == true ]] || [[ "$CLEAN_INSTALL" == true ]]; then
                pnpm store prune 2>/dev/null || true
            fi
            
            pnpm install
            
            if [[ $? -eq 0 ]]; then
                print_success "pnpm依赖安装成功"
            else
                print_error "pnpm依赖安装失败"
                cd ..
                return 1
            fi
            ;;
        yarn)
            print_info "使用yarn安装依赖..."
            
            if [[ "$FORCE_INSTALL" == true ]] || [[ "$CLEAN_INSTALL" == true ]]; then
                yarn cache clean 2>/dev/null || true
            fi
            
            yarn install
            
            if [[ $? -eq 0 ]]; then
                print_success "yarn依赖安装成功"
            else
                print_error "yarn依赖安装失败"
                cd ..
                return 1
            fi
            ;;
        npm)
            print_info "使用npm安装依赖..."
            
            if [[ "$FORCE_INSTALL" == true ]] || [[ "$CLEAN_INSTALL" == true ]]; then
                npm cache clean --force 2>/dev/null || true
            fi
            
            npm install
            
            if [[ $? -eq 0 ]]; then
                print_success "npm依赖安装成功"
            else
                print_error "npm依赖安装失败"
                cd ..
                return 1
            fi
            ;;
    esac
    
    # 创建.env.example（如果不存在）
    if [[ ! -f ".env.example" ]] && [[ -f ".env.example" ]]; then
        print_info "创建环境变量示例文件..."
        cp .env.example .env.example 2>/dev/null || true
    fi
    
    cd ..
    print_success "前端依赖安装完成"
}

# 验证安装
verify_installation() {
    print_header "验证安装..."
    
    local all_ok=true
    
    if [[ "$INSTALL_BACKEND" == true ]]; then
        print_info "验证后端依赖..."
        cd backend
        
        # 检查Python包
        local required_packages=("fastapi" "uvicorn" "pydantic")
        for pkg in "${required_packages[@]}"; do
            if python3 -c "import $pkg" 2>/dev/null; then
                print_info "  ✅ $pkg"
            else
                print_warning "  ❌ $pkg (未安装)"
                all_ok=false
            fi
        done
        
        cd ..
    fi
    
    if [[ "$INSTALL_FRONTEND" == true ]]; then
        print_info "验证前端依赖..."
        cd frontend
        
        # 检查node_modules是否存在
        if [[ -d "node_modules" ]]; then
            print_info "  ✅ node_modules目录存在"
            
            # 检查关键包
            if [[ -d "node_modules/vue" ]]; then
                print_info "  ✅ vue"
            else
                print_warning "  ❌ vue (未安装)"
                all_ok=false
            fi
            
            if [[ -d "node_modules/vite" ]]; then
                print_info "  ✅ vite"
            else
                print_warning "  ❌ vite (未安装)"
                all_ok=false
            fi
        else
            print_warning "  ❌ node_modules目录不存在"
            all_ok=false
        fi
        
        cd ..
    fi
    
    if [[ "$all_ok" == true ]]; then
        print_success "所有依赖验证通过"
    else
        print_warning "部分依赖验证未通过，可能需要重新安装"
    fi
}

# 显示安装总结
show_summary() {
    print_header "============================================"
    print_header "安装总结"
    print_header "============================================"
    
    if [[ "$INSTALL_BACKEND" == true ]]; then
        print_info "后端:"
        print_info "  包管理器: $BACKEND_PM"
        print_info "  目录: backend/"
        print_info "  配置文件: backend/pyproject.toml"
    fi
    
    if [[ "$INSTALL_FRONTEND" == true ]]; then
        print_info "前端:"
        print_info "  包管理器: $FRONTEND_PM"
        print_info "  目录: frontend/"
        print_info "  配置文件: frontend/package.json"
    fi
    
    print_info ""
    print_info "下一步:"
    
    if [[ "$INSTALL_BACKEND" == true ]] && [[ "$INSTALL_FRONTEND" == true ]]; then
        print_info "  启动所有服务: ./scripts/start-all.sh"
    elif [[ "$INSTALL_BACKEND" == true ]]; then
        print_info "  启动后端服务: ./scripts/start-backend.sh"
    elif [[ "$INSTALL_FRONTEND" == true ]]; then
        print_info "  启动前端服务: ./scripts/start-frontend.sh"
    fi
    
    print_info ""
    print_info "其他脚本:"
    print_info "  停止服务: ./scripts/stop-all.sh"
    print_info "  开发模式: ./scripts/start-all.sh --dev"
    print_info "  构建生产: ./scripts/start-frontend.sh --build"
    
    print_header "============================================"
    print_success "依赖安装完成！"
    print_header "============================================"
}

# 主函数
main() {
    print_header "============================================"
    print_header "AI海龟汤依赖安装脚本"
    print_header "============================================"
    
    # 解析参数
    parse_args "$@"
    
    # 检查环境
    check_environment
    
    # 清理安装（如果需要）
    if [[ "$CLEAN_INSTALL" == true ]] || [[ "$FORCE_INSTALL" == true ]]; then
        clean_installation
    fi
    
    # 安装后端依赖
    if [[ "$INSTALL_BACKEND" == true ]]; then
        install_backend_deps
    fi
    
    # 安装前端依赖
    if [[ "$INSTALL_FRONTEND" == true ]]; then
        install_frontend_deps
    fi
    
    # 验证安装
    verify_installation
    
    # 显示总结
    show_summary
}

# 运行主函数
main "$@"