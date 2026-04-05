#!/bin/bash

# ============================================
# AI海龟汤 - 前端启动脚本
# ============================================
# 使用方法:
#   1. 直接运行: ./scripts/start-frontend.sh
#   2. 带参数运行: ./scripts/start-frontend.sh --port 5174 --host 0.0.0.0
#   3. 开发模式: ./scripts/start-frontend.sh --dev
# ============================================

set -e  # 遇到错误时退出

# 默认配置
DEFAULT_PORT=5174
DEFAULT_HOST="0.0.0.0"
DEV_MODE=true
OPEN_BROWSER=false

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# 显示帮助信息
show_help() {
    echo "AI海龟汤前端启动脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -p, --port PORT     设置端口号 (默认: $DEFAULT_PORT)"
    echo "  -h, --host HOST     设置主机地址 (默认: $DEFAULT_HOST)"
    echo "  -d, --dev           开发模式 (默认)"
    echo "  -b, --build         构建生产版本"
    echo "  -o, --open          启动后自动打开浏览器"
    echo "  --preview           预览生产构建"
    echo "  --help              显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                    # 开发模式启动"
    echo "  $0 --port 3000        # 在3000端口启动"
    echo "  $0 --build            # 构建生产版本"
    echo "  $0 --preview          # 预览生产构建"
    echo "  $0 --open             # 启动后自动打开浏览器"
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--port)
                PORT="$2"
                shift 2
                ;;
            -h|--host)
                HOST="$2"
                shift 2
                ;;
            -d|--dev)
                DEV_MODE=true
                shift
                ;;
            -b|--build)
                DEV_MODE=false
                BUILD_MODE=true
                shift
                ;;
            -o|--open)
                OPEN_BROWSER=true
                shift
                ;;
            --preview)
                PREVIEW_MODE=true
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

# 检查Node.js环境
check_node() {
    print_info "检查Node.js环境..."
    
    if ! command -v node &> /dev/null; then
        print_error "未找到Node.js，请先安装Node.js (>= 16.0.0)"
        exit 1
    fi
    
    NODE_VERSION=$(node --version | cut -d'v' -f2)
    print_info "Node.js版本: v$NODE_VERSION"
    
    # 检查Node.js版本是否 >= 16
    REQUIRED_VERSION="16.0.0"
    if [[ $(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1) != "$REQUIRED_VERSION" ]]; then
        print_warning "建议使用Node.js 16.0.0或更高版本"
    fi
    
    # 检查npm/yarn/pnpm
    if command -v pnpm &> /dev/null; then
        PACKAGE_MANAGER="pnpm"
        print_info "使用pnpm作为包管理器"
    elif command -v yarn &> /dev/null; then
        PACKAGE_MANAGER="yarn"
        print_info "使用yarn作为包管理器"
    elif command -v npm &> /dev/null; then
        PACKAGE_MANAGER="npm"
        print_info "使用npm作为包管理器"
    else
        print_error "未找到包管理器 (npm/yarn/pnpm)"
        exit 1
    fi
}

# 检查依赖
check_dependencies() {
    print_info "检查依赖..."
    
    # 检查是否在frontend目录
    if [[ ! -f "package.json" ]]; then
        print_info "切换到frontend目录..."
        cd frontend 2>/dev/null || {
            print_error "无法找到frontend目录"
            exit 1
        }
    fi
    
    # 检查node_modules是否存在
    if [[ ! -d "node_modules" ]]; then
        print_warning "node_modules目录不存在，正在安装依赖..."
        install_dependencies
    else
        print_info "node_modules目录已存在"
    fi
}

# 安装依赖
install_dependencies() {
    print_info "安装依赖..."
    
    case $PACKAGE_MANAGER in
        pnpm)
            pnpm install
            ;;
        yarn)
            yarn install
            ;;
        npm)
            npm install
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        print_success "依赖安装成功"
    else
        print_error "依赖安装失败"
        exit 1
    fi
}

# 检查环境变量
check_env() {
    print_info "检查环境变量..."
    
    # 检查.env文件
    if [[ -f ".env" ]]; then
        print_info "找到.env文件"
    elif [[ -f ".env.example" ]]; then
        print_warning "未找到.env文件，使用.env.example作为参考"
        print_info "请创建.env文件并配置必要的环境变量"
        
        # 复制示例文件
        cp .env.example .env.local 2>/dev/null || true
        print_info "已创建.env.local文件，请根据需要修改"
    else
        print_warning "未找到环境变量配置文件"
    fi
    
    # 设置默认环境变量
    if [[ -z "$VITE_API_BASE_URL" ]]; then
        export VITE_API_BASE_URL="http://localhost:8000"
        print_info "设置VITE_API_BASE_URL=http://localhost:8000"
    fi
}

# 构建生产版本
build_production() {
    print_info "构建生产版本..."
    
    case $PACKAGE_MANAGER in
        pnpm)
            pnpm run build
            ;;
        yarn)
            yarn build
            ;;
        npm)
            npm run build
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        print_success "构建成功"
        print_info "构建文件位于: dist/"
    else
        print_error "构建失败"
        exit 1
    fi
}

# 预览生产构建
preview_build() {
    print_info "预览生产构建..."
    
    case $PACKAGE_MANAGER in
        pnpm)
            pnpm run preview
            ;;
        yarn)
            yarn preview
            ;;
        npm)
            npm run preview
            ;;
    esac
}

# 启动开发服务器
start_dev_server() {
    print_info "启动开发服务器..."
    
    # 设置参数
    local host="${HOST:-$DEFAULT_HOST}"
    local port="${PORT:-$DEFAULT_PORT}"
    
    # 构建命令
    local dev_cmd=""
    case $PACKAGE_MANAGER in
        pnpm)
            dev_cmd="pnpm run dev"
            ;;
        yarn)
            dev_cmd="yarn dev"
            ;;
        npm)
            dev_cmd="npm run dev"
            ;;
    esac
    
    # 添加主机和端口参数
    dev_cmd="$dev_cmd --host $host --port $port"
    
    print_info "主机: $host"
    print_info "端口: $port"
    print_info "工作目录: $(pwd)"
    print_info "启动命令: $dev_cmd"
    
    echo ""
    print_success "============================================"
    print_success "AI海龟汤前端开发服务器启动中..."
    print_success "本地地址: http://localhost:$port"
    print_success "网络地址: http://$host:$port"
    print_success "后端API: $VITE_API_BASE_URL"
    print_success "============================================"
    echo ""
    
    # 如果需要自动打开浏览器
    if [[ "$OPEN_BROWSER" == true ]]; then
        print_info "3秒后自动打开浏览器..."
        sleep 3
        case "$(uname -s)" in
            Darwin)
                open "http://localhost:$port"
                ;;
            Linux)
                xdg-open "http://localhost:$port" 2>/dev/null || \
                sensible-browser "http://localhost:$port" 2>/dev/null || \
                print_warning "无法自动打开浏览器，请手动访问"
                ;;
            CYGWIN*|MINGW32*|MSYS*|MINGW*)
                start "http://localhost:$port"
                ;;
            *)
                print_warning "无法自动打开浏览器，请手动访问 http://localhost:$port"
                ;;
        esac
    fi
    
    # 执行启动命令
    exec $dev_cmd
}

# 主函数
main() {
    print_info "============================================"
    print_info "AI海龟汤前端启动脚本"
    print_info "============================================"
    
    # 解析参数
    parse_args "$@"
    
    # 检查环境
    check_node
    
    # 检查并安装依赖
    check_dependencies
    
    # 检查环境变量
    check_env
    
    # 根据模式执行不同操作
    if [[ "$PREVIEW_MODE" == true ]]; then
        preview_build
    elif [[ "$BUILD_MODE" == true ]]; then
        build_production
    else
        start_dev_server
    fi
}

# 运行主函数
main "$@"