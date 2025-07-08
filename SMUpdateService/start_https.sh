#!/bin/bash

# SMBeautyEngine License API HTTPS启动脚本

set -e

# 颜色输出
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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查证书文件
check_certificates() {
    if [ ! -f "certs/cert.pem" ] || [ ! -f "certs/key.pem" ]; then
        print_error "SSL证书文件不存在"
        print_info "请先运行 ./generate_cert.sh 生成证书"
        exit 1
    fi
    print_success "SSL证书文件检查通过"
}

# 检查端口是否可用
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        print_warning "端口 $port 已被占用"
        return 1
    fi
    return 0
}

# 查找可用端口
find_available_port() {
    local start_port=$1
    local port=$start_port
    
    while ! check_port $port; do
        port=$((port + 1))
        if [ $port -gt $((start_port + 100)) ]; then
            print_error "无法找到可用端口"
            exit 1
        fi
    done
    
    echo $port
}

# 主函数
main() {
    print_info "启动SMBeautyEngine License API HTTPS服务..."
    
    # 检查证书
    check_certificates
    
    # 查找可用端口
    HTTP_PORT=$(find_available_port 1880)
    HTTPS_PORT=$(find_available_port 2443)
    
    if [ $HTTP_PORT -eq 1880 ] && [ $HTTPS_PORT -eq 2443 ]; then
        print_info "使用标准端口: HTTP=1880, HTTPS=2443"
    else
        print_warning "使用备用端口: HTTP=$HTTP_PORT, HTTPS=$HTTPS_PORT"
    fi
    
    # 设置环境变量
    export ENABLE_HTTPS=true
    export SSL_CERT_PATH=certs/cert.pem
    export SSL_KEY_PATH=certs/key.pem
    export HTTP_PORT=$HTTP_PORT
    export HTTPS_PORT=$HTTPS_PORT
    export DOWNLOAD_BASE_URL=https://localhost:$HTTPS_PORT
    export LOG_LEVEL=info
    
    print_info "启动参数:"
    echo "  HTTP端口: $HTTP_PORT"
    echo "  HTTPS端口: $HTTPS_PORT"
    echo "  证书文件: $SSL_CERT_PATH"
    echo "  私钥文件: $SSL_KEY_PATH"
    echo "  下载URL: $DOWNLOAD_BASE_URL"
    echo ""
    
    # 启动服务
    print_info "启动服务..."
    go run main.go
}

# 运行主函数
main "$@" 