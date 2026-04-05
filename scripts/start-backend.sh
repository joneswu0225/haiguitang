#!/bin/bash

# ============================================
# AI海龟汤 - 后端启动脚本
# ============================================
# 使用方法:
#   1. 直接运行: ./scripts/start-backend.sh
#   2. 带参数运行: ./scripts/start-backend.sh --port 8000 --host 0.0.0.0
#   3. 开发模式: ./scripts/start-backend.sh --dev
# ============================================

set -e  # 遇到错误时退出

# 默认配置
DEFAULT_PORT=8000
DEFAULT_HOST="0.0.0.0"
DEV_MODE=false
RELOAD=false

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
    echo "AI海龟汤后端启动脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -p, --port PORT     设置端口号 (默认: $DEFAULT_PORT)"
    echo "  -h, --host HOST     设置主机地址 (默认: $DEFAULT_HOST)"
    echo "  -d, --dev           开发模式 (启用热重载)"
    echo "  -r, --reload        启用热重载"
    echo "  --help              显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                    # 使用默认配置启动"
    echo "  $0 --port 8080        # 在8080端口启动"
    echo "  $0 --dev              # 开发模式启动"
    echo "  $0 --host 127.0.0.1   # 在本地主机启动"
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
                RELOAD=true
                shift
                ;;
            -r|--reload)
                RELOAD=true
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

# 检查Python环境
check_python() {
    print_info "检查Python环境..."
    
    if ! command -v python3 &> /dev/null; then
        print_error "未找到Python3，请先安装Python3"
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    print_info "Python版本: $PYTHON_VERSION"
    
    # 检查Python版本是否 >= 3.9
    REQUIRED_VERSION="3.9"
    if [[ $(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1) != "$REQUIRED_VERSION" ]]; then
        print_warning "建议使用Python 3.9或更高版本"
    fi
}

# 检查依赖
check_dependencies() {
    print_info "检查依赖..."
    
    # 检查是否在backend目录
    if [[ ! -f "pyproject.toml" ]]; then
        print_info "切换到backend目录..."
        cd backend 2>/dev/null || {
            print_error "无法找到backend目录"
            exit 1
        }
    fi
    
    # 检查uv
    if command -v uv &> /dev/null; then
        print_info "使用uv安装依赖..."
        uv pip install -e .
    elif command -v poetry &> /dev/null; then
        print_info "使用poetry安装依赖..."
        poetry install --no-root
    else
        print_warning "未找到uv或poetry，尝试使用pip安装依赖..."
        
        # 检查requirements.txt
        if [[ -f "requirements.txt" ]]; then
            print_info "使用requirements.txt安装依赖..."
            pip install -r requirements.txt
        else
            print_error "未找到requirements.txt，请先安装uv、poetry或创建requirements.txt"
            exit 1
        fi
    fi
}

# 检查环境变量
check_env() {
    print_info "检查环境变量..."
    
    # 检查.env文件
    if [[ -f ".env" ]]; then
        print_info "找到.env文件"
        source .env 2>/dev/null || true
    elif [[ -f ".env.example" ]]; then
        print_warning "未找到.env文件，使用.env.example作为参考"
        print_info "请创建.env文件并配置必要的环境变量"
    else
        print_warning "未找到环境变量配置文件"
    fi
    
    # 检查必要的环境变量
    if [[ -z "$DATABASE_URL" ]]; then
        print_warning "DATABASE_URL未设置，使用默认内存存储"
        export DATABASE_URL="sqlite:///./data/app.db"
    fi
}

# 启动后端服务
start_backend() {
    print_info "启动AI海龟汤后端服务..."
    
    # 设置参数
    local start_cmd="uvicorn app.main:app"
    local host="${HOST:-$DEFAULT_HOST}"
    local port="${PORT:-$DEFAULT_PORT}"
    
    # 构建命令
    local full_cmd="$start_cmd --host $host --port $port"
    
    if [[ "$RELOAD" == true ]]; then
        full_cmd="$full_cmd --reload"
        print_info "启用热重载模式"
    fi
    
    if [[ "$DEV_MODE" == true ]]; then
        print_info "开发模式启动"
        export ENVIRONMENT="development"
    else
        print_info "生产模式启动"
        export ENVIRONMENT="production"
    fi
    
    print_info "主机: $host"
    print_info "端口: $port"
    print_info "工作目录: $(pwd)"
    print_info "启动命令: $full_cmd"
    
    echo ""
    print_success "============================================"
    print_success "AI海龟汤后端服务启动中..."
    print_success "API地址: http://$host:$port"
    print_success "文档地址: http://$host:$port/docs"
    print_success "============================================"
    echo ""
    
    # 执行启动命令
    exec $full_cmd
}

# 主函数
main() {
    print_info "============================================"
    print_info "AI海龟汤后端启动脚本"
    print_info "============================================"
    
    # 解析参数
    parse_args "$@"
    
    # 检查环境
    check_python
    
    # 检查并安装依赖
    check_dependencies
    
    # 检查环境变量
    check_env
    
    # 启动服务
    start_backend
}

# 运行主函数
main "$@"