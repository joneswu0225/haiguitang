#!/bin/bash

# ============================================
# AI海龟汤 - 测试脚本
# ============================================
# 运行前后端测试
# 使用方法:
#   1. 直接运行: ./scripts/run-tests.sh
#   2. 仅后端测试: ./scripts/run-tests.sh --backend
#   3. 仅前端测试: ./scripts/run-tests.sh --frontend
#   4. 带覆盖率: ./scripts/run-tests.sh --coverage
# ============================================

set -e  # 遇到错误时退出

# 默认配置
TEST_BACKEND=true
TEST_FRONTEND=true
WITH_COVERAGE=false
VERBOSE=false
UPDATE_SNAPSHOTS=false

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
    echo "AI海龟汤测试脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -b, --backend         仅运行后端测试"
    echo "  -f, --frontend        仅运行前端测试"
    echo "  -c, --coverage        生成测试覆盖率报告"
    echo "  -v, --verbose         详细输出"
    echo "  -u, --update          更新快照"
    echo "  --help                显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                     # 运行所有测试"
    echo "  $0 --backend           # 仅运行后端测试"
    echo "  $0 --frontend          # 仅运行前端测试"
    echo "  $0 --coverage          # 运行测试并生成覆盖率报告"
    echo "  $0 --verbose           # 详细输出模式"
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -b|--backend)
                TEST_BACKEND=true
                TEST_FRONTEND=false
                shift
                ;;
            -f|--frontend)
                TEST_BACKEND=false
                TEST_FRONTEND=true
                shift
                ;;
            -c|--coverage)
                WITH_COVERAGE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -u|--update)
                UPDATE_SNAPSHOTS=true
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
    print_header "检查测试环境..."
    
    # 检查Python（后端测试需要）
    if [[ "$TEST_BACKEND" == true ]]; then
        if ! command -v python3 &> /dev/null; then
            print_error "未找到Python3，无法运行后端测试"
            TEST_BACKEND=false
        else
            print_info "Python版本: $(python3 --version | cut -d' ' -f2)"
        fi
    fi
    
    # 检查Node.js（前端测试需要）
    if [[ "$TEST_FRONTEND" == true ]]; then
        if ! command -v node &> /dev/null; then
            print_error "未找到Node.js，无法运行前端测试"
            TEST_FRONTEND=false
        else
            print_info "Node.js版本: $(node --version)"
        fi
    fi
    
    # 如果没有可运行的测试
    if [[ "$TEST_BACKEND" == false ]] && [[ "$TEST_FRONTEND" == false ]]; then
        print_error "没有可运行的测试环境"
        exit 1
    fi
}

# 运行后端测试
run_backend_tests() {
    print_header "运行后端测试..."
    
    if [[ ! -d "backend" ]]; then
        print_error "backend目录不存在"
        return 1
    fi
    
    cd backend
    
    # 检查测试配置
    if [[ ! -f "pyproject.toml" ]]; then
        print_error "未找到pyproject.toml文件"
        cd ..
        return 1
    fi
    
    # 检查pytest
    if ! python3 -c "import pytest" 2>/dev/null; then
        print_warning "pytest未安装，尝试安装..."
        
        # 尝试使用uv安装
        if command -v uv &> /dev/null; then
            uv pip install pytest pytest-asyncio 2>/dev/null || {
                print_error "无法使用uv安装pytest"
                cd ..
                return 1
            }
        else
            pip install pytest pytest-asyncio 2>/dev/null || {
                print_error "无法安装pytest"
                cd ..
                return 1
            }
        fi
    fi
    
    # 构建测试命令
    local test_cmd="pytest"
    
    if [[ "$VERBOSE" == true ]]; then
        test_cmd="$test_cmd -v"
    fi
    
    if [[ "$WITH_COVERAGE" == true ]]; then
        # 检查coverage
        if ! python3 -c "import coverage" 2>/dev/null; then
            print_warning "coverage未安装，尝试安装..."
            pip install coverage 2>/dev/null || {
                print_error "无法安装coverage"
                cd ..
                return 1
            }
        fi
        test_cmd="coverage run -m pytest"
    fi
    
    # 添加测试目录
    local test_dirs=()
    if [[ -d "tests" ]]; then
        test_dirs+=("tests")
    fi
    
    if [[ ${#test_dirs[@]} -eq 0 ]]; then
        # 如果没有tests目录，检查是否有测试文件
        if find . -name "*test*.py" -type f | grep -q .; then
            test_cmd="$test_cmd ."
        else
            print_warning "未找到后端测试文件"
            cd ..
            return 0
        fi
    else
        test_cmd="$test_cmd ${test_dirs[@]}"
    fi
    
    print_info "测试命令: $test_cmd"
    echo ""
    
    # 运行测试
    if eval $test_cmd; then
        print_success "后端测试通过"
        
        # 生成覆盖率报告
        if [[ "$WITH_COVERAGE" == true ]]; then
            echo ""
            print_info "生成覆盖率报告..."
            coverage report -m
            coverage html -d coverage_report
            print_info "HTML报告: backend/coverage_report/index.html"
        fi
    else
        print_error "后端测试失败"
        cd ..
        return 1
    fi
    
    cd ..
    return 0
}

# 运行前端测试
run_frontend_tests() {
    print_header "运行前端测试..."
    
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
    
    # 检查node_modules
    if [[ ! -d "node_modules" ]]; then
        print_warning "node_modules目录不存在，尝试安装依赖..."
        npm install 2>/dev/null || {
            print_error "无法安装依赖"
            cd ..
            return 1
        }
    fi
    
    # 检查vitest
    if [[ ! -f "node_modules/.bin/vitest" ]]; then
        print_warning "vitest未安装，尝试安装..."
        npm install --save-dev vitest @vitest/ui 2>/dev/null || {
            print_error "无法安装vitest"
            cd ..
            return 1
        }
    fi
    
    # 构建测试命令
    local test_cmd="npx vitest"
    
    if [[ "$WITH_COVERAGE" == true ]]; then
        test_cmd="$test_cmd --coverage"
    fi
    
    if [[ "$VERBOSE" == true ]]; then
        test_cmd="$test_cmd --reporter=verbose"
    fi
    
    if [[ "$UPDATE_SNAPSHOTS" == true ]]; then
        test_cmd="$test_cmd --update"
    fi
    
    # 检查测试目录
    local test_dirs=()
    if [[ -d "src/__tests__" ]]; then
        test_dirs+=("src/__tests__")
    fi
    
    if [[ -d "tests" ]]; then
        test_dirs+=("tests")
    fi
    
    if [[ ${#test_dirs[@]} -eq 0 ]]; then
        # 如果没有测试目录，检查是否有测试文件
        if find . -name "*.test.*" -o -name "*.spec.*" | grep -q .; then
            test_cmd="$test_cmd run"
        else
            print_warning "未找到前端测试文件"
            cd ..
            return 0
        fi
    else
        test_cmd="$test_cmd run ${test_dirs[@]}"
    fi
    
    print_info "测试命令: $test_cmd"
    echo ""
    
    # 运行测试
    if eval $test_cmd; then
        print_success "前端测试通过"
        
        # 如果启用了覆盖率，vitest会自动生成报告
        if [[ "$WITH_COVERAGE" == true ]] && [[ -d "coverage" ]]; then
            print_info "覆盖率报告: frontend/coverage/index.html"
        fi
    else
        print_error "前端测试失败"
        cd ..
        return 1
    fi
    
    cd ..
    return 0
}

# 运行集成测试
run_integration_tests() {
    print_header "运行集成测试..."
    
    # 检查是否安装了httpx
    if ! python3 -c "import httpx" 2>/dev/null; then
        print_warning "httpx未安装，跳过集成测试"
        return 0
    fi
    
    # 创建临时集成测试脚本
    local test_script=$(mktemp)
    cat > "$test_script" << 'EOF'
#!/usr/bin/env python3
"""
AI海龟汤集成测试
"""

import httpx
import time
import sys

def test_api_health():
    """测试API健康检查"""
    print("测试API健康检查...")
    try:
        response = httpx.get("http://localhost:8000/docs", timeout=5.0)
        if response.status_code == 200:
            print("✅ API文档可访问")
            return True
        else:
            print(f"❌ API文档返回状态码: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ 无法访问API: {e}")
        return False

def test_game_flow():
    """测试游戏流程"""
    print("\n测试游戏流程...")
    
    user_id = f"test-user-{int(time.time())}"
    headers = {"X-User-ID": user_id}
    
    try:
        # 1. 创建游戏
        print("  1. 创建游戏...")
        response = httpx.post(
            "http://localhost:8000/api/v1/games/",
            json={"soup_id": "1"},
            headers=headers,
            timeout=5.0
        )
        
        if response.status_code != 200:
            print(f"  ❌ 创建游戏失败: {response.status_code}")
            return False
        
        game_id = response.json().get("data", {}).get("game", {}).get("id")
        if not game_id:
            print("  ❌ 未获取到游戏ID")
            return False
        
        print(f"  ✅ 游戏创建成功: {game_id}")
        
        # 2. 提交问题
        print("  2. 提交问题...")
        response = httpx.post(
            "http://localhost:8000/api/v1/judge/",
            json={
                "game_id": game_id,
                "question": "这个人是不是还活着？"
            },
            headers=headers,
            timeout=5.0
        )
        
        if response.status_code != 200:
            print(f"  ❌ 提交问题失败: {response.status_code}")
            return False
        
        print("  ✅ 问题提交成功")
        
        # 3. 获取游戏详情
        print("  3. 获取游戏详情...")
        response = httpx.get(
            f"http://localhost:8000/api/v1/games/{game_id}",
            headers=headers,
            timeout=5.0
        )
        
        if response.status_code != 200:
            print(f"  ❌ 获取游戏详情失败: {response.status_code}")
            return False
        
        game = response.json().get("data", {}).get("game", {})
        if game.get("status") != "active":
            print(f"  ❌ 游戏状态不正确: {game.get('status')}")
            return False
        
        print(f"  ✅ 游戏详情获取成功，状态: {game.get('status')}")
        
        return True
        
    except Exception as e:
        print(f"  ❌ 游戏流程测试异常: {e}")
        return False

def main():
    """主函数"""
    print("🔧 AI海龟汤集成测试")
    print("=" * 50)
    
    # 等待服务启动
    print("等待服务启动...")
    for i in range(10):
        try:
            response = httpx.get("http://localhost:8000/docs", timeout=2.0)
            if response.status_code == 200:
                print("✅ 服务已启动")
                break
        except:
            if i == 9:
                print("❌ 服务启动超时")
                return 1
            time.sleep(1)
    
    # 运行测试
    tests_passed = 0
    tests_total = 0
    
    # API健康检查
    tests_total += 1
    if test_api_health():
        tests_passed += 1
    
    # 游戏流程测试
    tests_total += 1
    if test_game_flow():
        tests_passed += 1
    
    # 输出结果
    print(f"\n{'='*50}")
    print(f"测试结果: {tests_passed}/{tests_total} 通过")
    
    if tests_passed == tests_total:
        print("✅ 所有集成测试通过")
        return 0
    else:
        print("❌ 部分集成测试失败")
        return 1

if __name__ == "__main__":
    sys.exit(main())
EOF
    
    # 运行集成测试
    chmod +x "$test_script"
    python3 "$test_script"
    local result=$?
    
    # 清理临时文件
    rm -f "$test_script"
    
    if [[ $result -eq 0 ]]; then
        print_success "集成测试通过"
        return 0
    else
        print_error "集成测试失败"
        return 1
    fi
}

# 显示测试总结
show_test_summary() {
    print_header "============================================"
    print_header "测试总结"
    print_header "============================================"
    
    print_info "测试配置:"
    if [[ "$TEST_BACKEND" == true ]]; then
        print_info "  后端测试: ✅ 已运行"
    else
        print_info "  后端测试: ⏭️  已跳过"
    fi
    
    if [[ "$TEST_FRONTEND" == true ]]; then
        print_info "  前端测试: ✅ 已运行"
    else
        print_info "  前端测试: ⏭️  已跳过"
    fi
    
    if [[ "$WITH_COVERAGE" == true ]]; then
        print_info "  覆盖率报告: ✅ 已生成"
    fi
    
    print_info ""
    print_info "测试报告位置:"
    if [[ "$TEST_BACKEND" == true ]] && [[ "$WITH_COVERAGE" == true ]]; then
        print_info "  后端覆盖率: backend/coverage_report/index.html"
    fi
    
    if [[ "$TEST_FRONTEND" == true ]] && [[ "$WITH_COVERAGE" == true ]]; then
        print_info "  前端覆盖率: frontend/coverage/index.html"
    fi
    
    print_info ""
    print_info "下一步:"
    print_info "  重新运行测试: ./scripts/run-tests.sh"
    print_info "  仅后端测试: ./scripts/run-tests.sh --backend"
    print_info "  仅前端测试: ./scripts/run-tests.sh --frontend"
    print_info "  开发模式启动: ./scripts/start-all.sh --dev"
    
    print_header "============================================"
}

# 主函数
main() {
    print_header "============================================"
    print_header "AI海龟汤测试脚本"
    print_header "============================================"
    
    # 解析参数
    parse_args "$@"
    
    # 检查环境
    check_environment
    
    local backend_result=0
    local frontend_result=0
    
    # 运行后端测试
    if [[ "$TEST_BACKEND" == true ]]; then
        if ! run_backend_tests; then
            backend_result=1
        fi
    fi
    
    # 运行前端测试
    if [[ "$TEST_FRONTEND" == true ]]; then
        if ! run_frontend_tests; then
            frontend_result=1
        fi
    fi
    
    # 如果所有测试都通过，运行集成测试
    if [[ $backend_result -eq 0 ]] && [[ $frontend_result -eq 0 ]]; then
        print_info ""
        print_info "所有单元测试通过，运行集成测试..."
        if ! run_integration_tests; then
            print_warning "集成测试失败，但单元测试通过"
        fi
    fi
    
    # 显示总结
    show_test_summary
    
    # 返回测试结果
    if [[ $backend_result -eq 0 ]] && [[ $frontend_result -eq 0 ]]; then
        print_success "所有测试通过！"
        return 0
    else
        print_error "测试失败"
        return 1
    fi
}

# 运行主函数
main "$@"