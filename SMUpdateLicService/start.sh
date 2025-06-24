#!/bin/bash

# SMBeautyEngine License Health Check API 启动脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
DEFAULT_PORT=15000
DEFAULT_LICENSE_DIR="licenses"
DEFAULT_KEYS_DIR="keys"
DEFAULT_LOG_LEVEL="info"

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

# 检查依赖
check_dependencies() {
    print_info "检查依赖..."
    
    if ! command -v go &> /dev/null; then
        print_error "Go 未安装，请先安装 Go 1.19+"
        exit 1
    fi
    
    go_version=$(go version | awk '{print $3}' | sed 's/go//')
    required_version="1.19"
    
    if [ "$(printf '%s\n' "$required_version" "$go_version" | sort -V | head -n1)" != "$required_version" ]; then
        print_error "Go 版本过低，需要 1.19+，当前版本: $go_version"
        exit 1
    fi
    
    print_success "依赖检查通过"
}

# 初始化目录
init_directories() {
    print_info "初始化目录..."
    
    mkdir -p "$DEFAULT_LICENSE_DIR"
    mkdir -p "$DEFAULT_KEYS_DIR"
    mkdir -p logs
    
    # 启动前删除旧的密钥文件
    # rm -f "$DEFAULT_KEYS_DIR/private_key.pem" "$DEFAULT_KEYS_DIR/public_key.pem"
    
    print_success "目录初始化完成"
}

# 下载依赖
download_dependencies() {
    print_info "下载 Go 依赖..."
    
    if [ -f go.mod ]; then
        go mod download
        go mod tidy
        print_success "依赖下载完成"
    else
        print_warning "go.mod 文件不存在，跳过依赖下载"
    fi
}

# 检查端口是否可用
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_warning "端口 $port 已被占用"
        return 1
    fi
    return 0
}

# 启动服务
start_service() {
    local port=${1:-$DEFAULT_PORT}
    
    print_info "启动许可证健康检查API服务..."
    print_info "端口: $port"
    print_info "许可证目录: $DEFAULT_LICENSE_DIR"
    print_info "密钥目录: $DEFAULT_KEYS_DIR"
    print_info "日志级别: $DEFAULT_LOG_LEVEL"
    
    # 设置环境变量
    export PORT=$port
    export LICENSE_DIR=$DEFAULT_LICENSE_DIR
    export PRIVATE_KEY_PATH="$DEFAULT_KEYS_DIR/private_key.pem"
    export PUBLIC_KEY_PATH="$DEFAULT_KEYS_DIR/public_key.pem"
    export LICENSE_VALIDITY_DAYS=365
    export LOG_LEVEL=$DEFAULT_LOG_LEVEL
    export DOWNLOAD_BASE_URL="http://localhost:$port"
    export DATA_FILE="data/license_configs.json"
    
    # 确保data目录存在
    mkdir -p data
    
    # 启动服务
    if [ -f main.go ]; then
        print_info "使用 go run 启动服务..."
        PORT=$port go run main.go
    elif [ -f smbeauty-license-api ]; then
        print_info "使用编译后的二进制文件启动服务..."
        PORT=$port ./smbeauty-license-api
    else
        print_error "未找到可执行文件，请先构建项目"
        exit 1
    fi
}

# 显示帮助信息
show_help() {
    echo "SMBeautyEngine License Health Check API 启动脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -p, --port PORT      指定端口 (默认: 5000)"
    echo "  -d, --daemon         后台运行"
    echo "  -h, --help           显示此帮助信息"
    echo ""
    echo "环境变量:"
    echo "  PORT                 服务端口"
    echo "  LICENSE_DIR          许可证目录"
    echo "  LOG_LEVEL            日志级别"
    echo ""
    echo "示例:"
    echo "  $0                    # 使用默认配置启动"
    echo "  $0 -p 8080           # 指定端口启动"
    echo "  $0 -d                # 后台运行"
}

# 后台运行
run_daemon() {
    local port=${1:-$DEFAULT_PORT}
    local pid_file="logs/api.pid"
    local log_file="logs/api.log"
    
    print_info "后台启动服务..."
    
    # 创建日志目录
    mkdir -p logs
    
    # 设置环境变量
    export PORT=$port
    export LICENSE_DIR=$DEFAULT_LICENSE_DIR
    export PRIVATE_KEY_PATH="$DEFAULT_KEYS_DIR/private_key.pem"
    export PUBLIC_KEY_PATH="$DEFAULT_KEYS_DIR/public_key.pem"
    export LICENSE_VALIDITY_DAYS=365
    export LOG_LEVEL=$DEFAULT_LOG_LEVEL
    export DOWNLOAD_BASE_URL="http://localhost:$port"
    export DATA_FILE="data/license_configs.json"
    
    # 确保data目录存在
    mkdir -p data
    
    # 启动服务
    nohup PORT=$port go run main.go > "$log_file" 2>&1 &
    echo $! > "$pid_file"
    
    print_success "服务已后台启动，PID: $(cat $pid_file)"
    print_info "日志文件: $log_file"
    print_info "PID文件: $pid_file"
    print_info "访问地址: http://localhost:$port"
}

# 停止服务
stop_service() {
    local pid_file="logs/api.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            print_info "停止服务 (PID: $pid)..."
            kill "$pid"
            rm -f "$pid_file"
            print_success "服务已停止"
        else
            print_warning "服务未运行"
            rm -f "$pid_file"
        fi
    else
        print_warning "PID文件不存在，服务可能未运行"
    fi
}

# 显示状态
show_status() {
    local pid_file="logs/api.pid"
    local port=${1:-$DEFAULT_PORT}
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            print_success "服务正在运行 (PID: $pid)"
            
            # 检查健康状态
            if curl -s -f "http://localhost:$port/health" > /dev/null 2>&1; then
                print_success "API 健康检查通过"
            else
                print_warning "API 健康检查失败"
            fi
        else
            print_warning "服务未运行 (PID文件存在但进程不存在)"
            rm -f "$pid_file"
        fi
    else
        print_warning "服务未运行"
    fi
}

# 主函数
main() {
    local port=$DEFAULT_PORT
    local daemon_mode=false
    local action="start"
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--port)
                port="$2"
                shift 2
                ;;
            -d|--daemon)
                daemon_mode=true
                shift
                ;;
            stop)
                action="stop"
                shift
                ;;
            status)
                action="status"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    case $action in
        start)
            check_dependencies
            init_directories
            download_dependencies
            
            if ! check_port "$port"; then
                print_error "端口 $port 不可用，请选择其他端口"
                exit 1
            fi
            
            if [ "$daemon_mode" = true ]; then
                run_daemon "$port"
            else
                start_service "$port"
            fi
            ;;
        stop)
            stop_service
            ;;
        status)
            show_status "$port"
            ;;
    esac
}

# 捕获中断信号
trap 'print_info "收到中断信号，正在停止服务..."; stop_service; exit 0' INT TERM

# 运行主函数
main "$@" 