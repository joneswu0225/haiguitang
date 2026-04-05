#!/bin/bash

# ============================================
# AI海龟汤 - 全栈启动脚本
# ============================================
# 同时启动前端和后端服务
# 使用方法:
#   1. 直接运行: ./scripts/start-all.sh
#   2. 开发模式: ./scripts/start-all.sh --dev
#   3. 指定端口: ./scripts/start-all.sh --backend-port 8000 --frontend-port 5174
# ============================================

set -e  # 遇到错误时退出

# 默认配置
DEFAULT_BACKEND_PORT=8000
DEFAULT_FRONTEND_PORT=5174
DEFAULT_HOST="0.0.0.0"
DEV_MODE=true
USE_TMUX=false

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
    echo "AI海龟汤全栈启动脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -bp, --backend-port PORT  后端端口 (默认: $DEFAULT_BACKEND_PORT)"
    echo "  -fp, --frontend-port PORT 前端端口 (默认: $DEFAULT_FRONTEND_PORT)"
    echo "  -h, --host HOST           主机地址 (默认: $DEFAULT_HOST)"
    echo "  -d, --dev                 开发模式 (默认)"
    echo "  -t, --tmux                使用tmux分屏 (如果可用)"
    echo "  --build                   构建生产版本"
    echo "  --help                    显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                         # 开发模式启动前后端"
    echo "  $0 --dev                   # 开发模式启动"
    echo "  $0 --tmux                  # 使用tmux分屏启动"
    echo "  $0 --backend-port 8080     # 后端使用8080端口"
    echo "  $0 --frontend-port 3000    # 前端使用3000端口"
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -bp|--backend-port)
                BACKEND_PORT="$2"
                shift 2
                ;;
            -fp|--frontend-port)
                FRONTEND_PORT="$2"
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
            -t|--tmux)
                USE_TMUX=true
                shift
                ;;
            --build)
                DEV_MODE=false
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

# 检查必要工具
check_tools() {
    print_info "检查必要工具..."
    
    # 检查tmux（可选）
    if [[ "$USE_TMUX" == true ]]; then
        if ! command -v tmux &> /dev/null; then
            print_warning "未找到tmux，将不使用分屏模式"
            USE_TMUX=false
        else
            print_info "找到tmux，将使用分屏模式"
        fi
    fi
    
    # 检查curl（用于健康检查）
    if ! command -v curl &> /dev/null; then
        print_warning "未找到curl，健康检查功能受限"
    fi
}

# 检查端口占用
check_ports() {
    print_info "检查端口占用..."
    
    local backend_port="${BACKEND_PORT:-$DEFAULT_BACKEND_PORT}"
    local frontend_port="${FRONTEND_PORT:-$DEFAULT_FRONTEND_PORT}"
    
    # 检查后端端口
    if lsof -Pi :$backend_port -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_warning "后端端口 $backend_port 已被占用"
        print_info "尝试查找占用进程..."
        lsof -Pi :$backend_port -sTCP:LISTEN
        return 1
    else
        print_info "后端端口 $backend_port 可用"
    fi
    
    # 检查前端端口
    if lsof -Pi :$frontend_port -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_warning "前端端口 $frontend_port 已被占用"
        print_info "尝试查找占用进程..."
        lsof -Pi :$frontend_port -sTCP:LISTEN
        return 1
    else
        print_info "前端端口 $frontend_port 可用"
    fi
    
    return 0
}

# 等待服务启动
wait_for_service() {
    local url=$1
    local timeout=$2
    local interval=$3
    local max_attempts=$((timeout / interval))
    
    print_info "等待服务启动: $url"
    
    for ((i=1; i<=max_attempts; i++)); do
        if curl -s -f "$url" > /dev/null 2>&1; then
            print_success "服务已启动: $url"
            return 0
        fi
        
        if [[ $i -eq 1 ]]; then
            echo -n "等待"
        else
            echo -n "."
        fi
        
        sleep $interval
    done
    
    echo ""
    print_error "服务启动超时: $url"
    return 1
}

# 使用tmux启动
start_with_tmux() {
    print_info "使用tmux分屏启动..."
    
    local backend_port="${BACKEND_PORT:-$DEFAULT_BACKEND_PORT}"
    local frontend_port="${FRONTEND_PORT:-$DEFAULT_FRONTEND_PORT}"
    local host="${HOST:-$DEFAULT_HOST}"
    
    # 创建tmux会话
    tmux new-session -d -s ai-haiguitang
    
    # 启动后端
    tmux rename-window -t ai-haiguitang:0 "后端 ($backend_port)"
    tmux send-keys -t ai-haiguitang:0 "cd /Users/jones/projects/ai/haiguitang && ./scripts/start-backend.sh --port $backend_port --host $host --dev" C-m
    
    # 分割窗口并启动前端
    tmux split-window -h -t ai-haiguitang:0
    tmux send-keys -t ai-haiguitang:0.1 "cd /Users/jones/projects/ai/haiguitang && ./scripts/start-frontend.sh --port $frontend_port --host $host --dev" C-m
    
    # 调整窗格大小
    tmux select-pane -t ai-haiguitang:0.0
    tmux resize-pane -R 30
    
    # 创建日志窗口
    tmux new-window -t ai-haiguitang:1 -n "日志"
    tmux send-keys -t ai-haiguitang:1 "cd /Users/jones/projects/ai/haiguitang && echo '服务日志将在这里显示...'" C-m
    
    # 附加到tmux会话
    print_success "tmux会话已创建: ai-haiguitang"
    print_info "使用以下命令附加到会话:"
    print_info "  tmux attach -t ai-haiguitang"
    print_info ""
    print_info "tmux快捷键:"
    print_info "  Ctrl-b d         分离会话"
    print_info "  Ctrl-b c         新建窗口"
    print_info "  Ctrl-b n         下一个窗口"
    print_info "  Ctrl-b p         上一个窗口"
    print_info "  Ctrl-b %         垂直分割"
    print_info "  Ctrl-b \"         水平分割"
    print_info "  Ctrl-b 箭头键    切换窗格"
    
    # 等待服务启动
    sleep 2
    
    # 检查服务状态
    check_services_status
}

# 并行启动（不使用tmux）
start_parallel() {
    print_info "并行启动前后端服务..."
    
    local backend_port="${BACKEND_PORT:-$DEFAULT_BACKEND_PORT}"
    local frontend_port="${FRONTEND_PORT:-$DEFAULT_FRONTEND_PORT}"
    local host="${HOST:-$DEFAULT_HOST}"
    
    # 启动后端（后台运行）
    print_info "启动后端服务..."
    cd /Users/jones/projects/ai/haiguitang
    ./scripts/start-backend.sh --port $backend_port --host $host --dev > backend.log 2>&1 &
    BACKEND_PID=$!
    
    # 启动前端（后台运行）
    print_info "启动前端服务..."
    ./scripts/start-frontend.sh --port $frontend_port --host $host --dev > frontend.log 2>&1 &
    FRONTEND_PID=$!
    
    # 保存PID到文件
    echo $BACKEND_PID > .backend.pid
    echo $FRONTEND_PID > .frontend.pid
    
    print_success "服务已启动 (PID: 后端=$BACKEND_PID, 前端=$FRONTEND_PID)"
    print_info "后端日志: backend.log"
    print_info "前端日志: frontend.log"
    
    # 等待服务启动
    sleep 3
    
    # 检查服务状态
    check_services_status
    
    # 显示进程信息
    print_info ""
    print_info "进程状态:"
    ps -p $BACKEND_PID,$FRONTEND_PID -o pid,command
    
    # 设置退出处理
    trap cleanup EXIT
    
    # 等待用户输入
    print_info ""
    print_info "按 Ctrl+C 停止所有服务"
    wait
}

# 检查服务状态
check_services_status() {
    local backend_port="${BACKEND_PORT:-$DEFAULT_BACKEND_PORT}"
    local frontend_port="${FRONTEND_PORT:-$DEFAULT_FRONTEND_PORT}"
    local host="${HOST:-$DEFAULT_HOST}"
    
    print_header "============================================"
    print_header "服务状态"
    print_header "============================================"
    
    # 后端状态
    if curl -s -f "http://$host:$backend_port/docs" > /dev/null 2>&1; then
        print_success "✅ 后端服务运行正常"
        print_info "   API地址: http://$host:$backend_port"
        print_info "   文档地址: http://$host:$backend_port/docs"
    else
        print_warning "⚠️  后端服务可能未启动"
        print_info "   检查日志: tail -f backend.log"
    fi
    
    # 前端状态
    if curl -s -f "http://$host:$frontend_port" > /dev/null 2>&1; then
        print_success "✅ 前端服务运行正常"
        print_info "   访问地址: http://$host:$frontend_port"
        print_info "   本地访问: http://localhost:$frontend_port"
    else
        print_warning "⚠️  前端服务可能未启动"
        print_info "   检查日志: tail -f frontend.log"
    fi
    
    print_header "============================================"
    print_success "🎉 AI海龟汤全栈服务已启动！"
    print_header "============================================"
    print_info ""
    print_info "快速访问:"
    print_info "  前端界面: http://localhost:$frontend_port"
    print_info "  后端API文档: http://localhost:$backend_port/docs"
    print_info ""
    print_info "管理命令:"
    print_info "  查看后端日志: tail -f backend.log"
    print_info "  查看前端日志: tail -f frontend.log"
    print_info "  停止所有服务: ./scripts/stop-all.sh"
    print_info ""
}

# 清理函数
cleanup() {
    print_info "正在停止服务..."
    
    # 停止后端
    if [[ -f ".backend.pid" ]]; then
        BACKEND_PID=$(cat .backend.pid)
        if kill -0 $BACKEND_PID 2>/dev/null; then
            print_info "停止后端服务 (PID: $BACKEND_PID)"
            kill $BACKEND_PID 2>/dev/null && sleep 1
            kill -9 $BACKEND_PID 2>/dev/null || true
        fi
        rm -f .backend.pid
    fi
    
    # 停止前端
    if [[ -f ".frontend.pid" ]]; then
        FRONTEND_PID=$(cat .frontend.pid)
        if kill -0 $FRONTEND_PID 2>/dev/null; then
            print_info "停止前端服务 (PID: $FRONTEND_PID)"
            kill $FRONTEND_PID 2>/dev/null && sleep 1
            kill -9 $FRONTEND_PID 2>/dev/null || true
        fi
        rm -f .frontend.pid
    fi
    
    # 停止tmux会话
    if tmux has-session -t ai-haiguitang 2>/dev/null; then
        print_info "停止tmux会话: ai-haiguitang"
        tmux kill-session -t ai-haiguitang
    fi
    
    print_success "服务已停止"
}

# 生成停止脚本
generate_stop_script() {
    cat > /Users/jones/projects/ai/haiguitang/scripts/stop-all.sh << 'EOF'
#!/bin/bash

# AI海龟汤 - 停止所有服务脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 切换到项目根目录
cd "$(dirname "$0")/.."

print_info "停止AI海龟汤所有服务..."

# 停止后端
if [[ -f ".backend.pid" ]]; then
    BACKEND_PID=$(cat .backend.pid)
    if kill -0 $BACKEND_PID 2>/dev/null; then
        print_info "停止后端服务 (PID: $BACKEND_PID)"
        kill $BACKEND_PID 2>/dev/null && sleep 1
        kill -9 $BACKEND_PID 2>/dev/null || true
        print_success "后端服务已停止"
    else
        print_info "后端服务未运行"
    fi
    rm -f .backend.pid
else
    print_info "未找到后端PID文件"
fi

# 停止前端
if [[ -f ".frontend.pid" ]]; then
    FRONTEND_PID=$(cat .frontend.pid)
    if kill -0 $FRONTEND_PID 2>/dev/null; then
        print_info "停止前端服务 (PID: $FRONTEND_PID)"
        kill $FRONTEND_PID 2>/dev/null && sleep 1
        kill -9 $FRONTEND_PID 2>/dev/null || true
        print_success "前端服务已停止"
    else
        print_info "前端服务未运行"
    fi
    rm -f .frontend.pid
else
    print_info "未找到前端PID文件"
fi

# 停止tmux会话
if command -v tmux &> /dev/null; then
    if tmux has-session -t ai-haiguitang 2>/dev/null; then
        print_info "停止tmux会话: ai-haiguitang"
        tmux kill-session -t ai-haiguitang
        print_success "tmux会话已停止"
    fi
fi

print_success "所有服务已停止"
EOF
    
    chmod +x /Users/jones/projects/ai/haiguitang/scripts/stop-all.sh
    print_info "已生成停止脚本: scripts/stop-all.sh"
}

# 主函数
main() {
    print_header "============================================"
    print_header "AI海龟汤全栈启动脚本"
    print_header "============================================"
    
    # 解析参数
    parse_args "$@"
    
    # 检查工具
    check_tools
    
    # 检查端口
    if ! check_ports; then
        print_error "端口被占用，请修改端口或停止占用进程"
        exit 1
    fi
    
    # 生成停止脚本
    generate_stop_script
    
    # 根据模式启动
    if [[ "$USE_TMUX" == true ]]; then
        start_with_tmux
    else
        start_parallel
    fi
}

# 运行主函数
main "$@"