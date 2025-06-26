#!/bin/bash

# SMBeautyEngine License API SSL证书生成脚本

set -e

# 配置
CERT_DIR="certs"
CERT_FILE="cert.pem"
KEY_FILE="key.pem"
DAYS=365
COUNTRY="CN"
STATE="Beijing"
CITY="Beijing"
ORG="SMBeautyEngine"
ORG_UNIT="License Service"
COMMON_NAME="localhost"
EMAIL="admin@smbeautyengine.com"

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

# 检查OpenSSL是否安装
check_openssl() {
    if ! command -v openssl &> /dev/null; then
        print_error "OpenSSL未安装，请先安装OpenSSL"
        exit 1
    fi
    print_success "OpenSSL已安装"
}

# 创建证书目录
create_cert_dir() {
    if [ ! -d "$CERT_DIR" ]; then
        mkdir -p "$CERT_DIR"
        print_info "创建证书目录: $CERT_DIR"
    else
        print_info "证书目录已存在: $CERT_DIR"
    fi
}

# 生成自签名证书
generate_cert() {
    print_info "生成自签名SSL证书..."
    
    # 生成私钥和证书
    openssl req -x509 -newkey rsa:2048 -keyout "$CERT_DIR/$KEY_FILE" \
        -out "$CERT_DIR/$CERT_FILE" -days $DAYS -nodes \
        -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$ORG_UNIT/CN=$COMMON_NAME/emailAddress=$EMAIL"
    
    if [ $? -eq 0 ]; then
        print_success "SSL证书生成成功"
    else
        print_error "SSL证书生成失败"
        exit 1
    fi
}

# 设置文件权限
set_permissions() {
    chmod 600 "$CERT_DIR/$KEY_FILE"
    chmod 644 "$CERT_DIR/$CERT_FILE"
    print_info "已设置证书文件权限"
}

# 显示证书信息
show_cert_info() {
    print_info "证书信息:"
    echo "证书文件: $CERT_DIR/$CERT_FILE"
    echo "私钥文件: $CERT_DIR/$KEY_FILE"
    echo "有效期: $DAYS 天"
    echo "组织: $ORG"
    echo "通用名称: $COMMON_NAME"
    echo ""
    
    print_info "证书详情:"
    openssl x509 -in "$CERT_DIR/$CERT_FILE" -text -noout | head -20
}

# 生成配置文件示例
generate_config() {
    print_info "生成HTTPS配置示例..."
    
    cat > .env.https.example << EOF
# HTTPS 配置示例
ENABLE_HTTPS=true
SSL_CERT_PATH=certs/cert.pem
SSL_KEY_PATH=certs/key.pem
HTTP_PORT=1880
HTTPS_PORT=2443
DOWNLOAD_BASE_URL=https://localhost:2443

# 其他配置
PORT=15000
LOG_LEVEL=info
LICENSE_VALIDITY_DAYS=365
EOF

    print_success "HTTPS配置示例已生成: .env.https.example"
}

# 主函数
main() {
    print_info "开始生成SSL证书..."
    
    check_openssl
    create_cert_dir
    generate_cert
    set_permissions
    show_cert_info
    generate_config
    
    print_success "SSL证书生成完成！"
    print_info "使用方法:"
    echo "1. 复制 .env.https.example 为 .env"
    echo "2. 修改 .env 中的配置"
    echo "3. 启动服务: ENABLE_HTTPS=true go run main.go"
    echo ""
    print_warning "注意: 这是自签名证书，仅用于开发和测试环境"
    print_warning "生产环境请使用受信任的CA签发的证书"
}

# 运行主函数
main "$@" 