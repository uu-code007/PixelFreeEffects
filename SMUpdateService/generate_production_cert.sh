#!/bin/bash

# SMBeautyEngine License API 生产环境 SSL 证书生成脚本

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

# 显示帮助信息
show_help() {
    echo "SMBeautyEngine License API 生产环境 SSL 证书生成脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --domain DOMAIN          指定域名 (必需)"
    echo "  --email EMAIL            指定邮箱地址 (必需)"
    echo "  --method METHOD          验证方法: standalone/webroot (默认: standalone)"
    echo "  --webroot-path PATH      webroot 验证路径 (当使用 webroot 方法时)"
    echo "  --staging                使用 Let's Encrypt 测试环境"
    echo "  --help                   显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 --domain api.example.com --email admin@example.com"
    echo "  $0 --domain api.example.com --email admin@example.com --method webroot --webroot-path /var/www/html"
    echo "  $0 --domain api.example.com --email admin@example.com --staging"
}

# 检查依赖
check_dependencies() {
    if ! command -v certbot &> /dev/null; then
        print_error "Certbot 未安装，请先安装 Certbot:"
        echo "  macOS: brew install certbot"
        echo "  Ubuntu/Debian: sudo apt-get install certbot"
        echo "  CentOS/RHEL: sudo yum install certbot"
        exit 1
    fi
    
    if ! command -v openssl &> /dev/null; then
        print_error "OpenSSL 未安装"
        exit 1
    fi
    
    print_success "依赖检查通过"
}

# 验证参数
validate_params() {
    if [ -z "$DOMAIN" ]; then
        print_error "请指定域名 (--domain)"
        show_help
        exit 1
    fi
    
    if [ -z "$EMAIL" ]; then
        print_error "请指定邮箱地址 (--email)"
        show_help
        exit 1
    fi
    
    if [ "$METHOD" = "webroot" ] && [ -z "$WEBROOT_PATH" ]; then
        print_error "使用 webroot 方法时，请指定 webroot 路径 (--webroot-path)"
        show_help
        exit 1
    fi
}

# 创建证书目录
create_cert_dir() {
    if [ ! -d "certs" ]; then
        mkdir -p certs
        print_info "创建证书目录: certs"
    fi
}

# 生成 Let's Encrypt 证书
generate_letsencrypt_cert() {
    print_info "开始生成 Let's Encrypt 证书..."
    print_info "域名: $DOMAIN"
    print_info "邮箱: $EMAIL"
    print_info "验证方法: $METHOD"
    
    if [ "$STAGING" = "true" ]; then
        print_warning "使用 Let's Encrypt 测试环境"
        STAGING_FLAG="--staging"
    else
        print_info "使用 Let's Encrypt 生产环境"
        STAGING_FLAG=""
    fi
    
    # 构建 certbot 命令
    CERTBOT_CMD="certbot certonly $STAGING_FLAG --non-interactive --agree-tos --email $EMAIL"
    
    if [ "$METHOD" = "standalone" ]; then
        # 在 macOS 上不使用 systemctl hook
        if [[ "$OSTYPE" == "darwin"* ]]; then
            print_info "检测到 macOS 系统，跳过 systemctl hook"
            CERTBOT_CMD="$CERTBOT_CMD --standalone"
        else
            CERTBOT_CMD="$CERTBOT_CMD --standalone --pre-hook 'systemctl stop nginx' --post-hook 'systemctl start nginx'"
        fi
    elif [ "$METHOD" = "webroot" ]; then
        CERTBOT_CMD="$CERTBOT_CMD --webroot --webroot-path $WEBROOT_PATH"
    fi
    
    CERTBOT_CMD="$CERTBOT_CMD -d $DOMAIN"
    
    print_info "执行命令: $CERTBOT_CMD"
    
    # 执行 certbot
    if eval $CERTBOT_CMD; then
        print_success "Let's Encrypt 证书生成成功"
    else
        print_error "Let's Encrypt 证书生成失败"
        return 1
    fi
}

# 复制证书文件
copy_cert_files() {
    print_info "复制证书文件到项目目录..."
    
    # Let's Encrypt 证书路径
    LETSENCRYPT_CERT="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
    LETSENCRYPT_KEY="/etc/letsencrypt/live/$DOMAIN/privkey.pem"
    
    if [ -f "$LETSENCRYPT_CERT" ] && [ -f "$LETSENCRYPT_KEY" ]; then
        # 复制证书文件
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS 上可能没有 sudo 权限访问 /etc/letsencrypt
            print_info "检测到 macOS 系统，尝试直接复制证书文件"
            cp "$LETSENCRYPT_CERT" "certs/cert.pem" 2>/dev/null || {
                print_warning "无法直接复制证书文件，可能需要手动复制"
                print_info "请手动将以下文件复制到 certs/ 目录："
                echo "  $LETSENCRYPT_CERT -> certs/cert.pem"
                echo "  $LETSENCRYPT_KEY -> certs/key.pem"
                return 1
            }
            cp "$LETSENCRYPT_KEY" "certs/key.pem" 2>/dev/null || {
                print_warning "无法复制私钥文件"
                return 1
            }
        else
            # Linux 系统使用 sudo
            sudo cp "$LETSENCRYPT_CERT" "certs/cert.pem"
            sudo cp "$LETSENCRYPT_KEY" "certs/key.pem"
            sudo chown $(whoami):$(whoami) certs/cert.pem certs/key.pem
        fi
        
        # 设置权限
        chmod 644 certs/cert.pem
        chmod 600 certs/key.pem
        
        print_success "证书文件复制完成"
    else
        print_error "Let's Encrypt 证书文件不存在"
        print_info "证书文件路径:"
        echo "  $LETSENCRYPT_CERT"
        echo "  $LETSENCRYPT_KEY"
        return 1
    fi
}

# 生成自签名证书（备用方案）
generate_self_signed_cert() {
    print_info "生成自签名证书作为备用方案..."
    
    # 生成私钥和证书
    openssl req -x509 -newkey rsa:2048 -keyout "certs/key.pem" \
        -out "certs/cert.pem" -days 365 -nodes \
        -subj "/C=CN/ST=Beijing/L=Beijing/O=SMBeautyEngine/OU=License Service/CN=$DOMAIN/emailAddress=$EMAIL"
    
    if [ $? -eq 0 ]; then
        print_success "自签名证书生成成功"
    else
        print_error "自签名证书生成失败"
        exit 1
    fi
}

# 显示证书信息
show_cert_info() {
    print_info "证书信息:"
    echo "域名: $DOMAIN"
    echo "证书文件: certs/cert.pem"
    echo "私钥文件: certs/key.pem"
    echo "邮箱: $EMAIL"
    echo ""
    
    if [ -f "certs/cert.pem" ]; then
        print_info "证书详情:"
        openssl x509 -in "certs/cert.pem" -text -noout | head -20
    fi
}

# 生成生产环境配置
generate_production_config() {
    print_info "生成生产环境配置..."
    
    cat > .env.production << EOF
# 生产环境 HTTPS 配置
ENABLE_HTTPS=true
SSL_CERT_PATH=certs/cert.pem
SSL_KEY_PATH=certs/key.pem
HTTP_PORT=80
HTTPS_PORT=443
DOWNLOAD_BASE_URL=https://$DOMAIN

# 其他配置
LOG_LEVEL=info
LICENSE_VALIDITY_DAYS=365
EOF

    print_success "生产环境配置已生成: .env.production"
}

# 生成自动续期脚本
generate_renewal_script() {
    print_info "生成证书自动续期脚本..."
    
    cat > renew_cert.sh << 'EOF'
#!/bin/bash

# 证书自动续期脚本

set -e

DOMAIN="'$DOMAIN'"
EMAIL="'$EMAIL'"

echo "开始续期证书: $DOMAIN"

# 续期证书
certbot renew --non-interactive --agree-tos --email $EMAIL

# 复制新证书
sudo cp "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" "certs/cert.pem"
sudo cp "/etc/letsencrypt/live/$DOMAIN/privkey.pem" "certs/key.pem"

# 设置权限
sudo chown $(whoami):$(whoami) certs/cert.pem certs/key.pem
chmod 644 certs/cert.pem
chmod 600 certs/key.pem

echo "证书续期完成"
EOF

    chmod +x renew_cert.sh
    print_success "自动续期脚本已生成: renew_cert.sh"
}

# 主函数
main() {
    print_info "开始生成生产环境 SSL 证书..."
    
    # 检查依赖
    check_dependencies
    
    # 验证参数
    validate_params
    
    # 创建证书目录
    create_cert_dir
    
    # 尝试生成 Let's Encrypt 证书
    if generate_letsencrypt_cert; then
        # 复制证书文件
        copy_cert_files
    else
        print_warning "Let's Encrypt 证书生成失败，使用自签名证书"
        generate_self_signed_cert
    fi
    
    # 显示证书信息
    show_cert_info
    
    # 生成配置文件
    generate_production_config
    
    # 生成续期脚本
    generate_renewal_script
    
    print_success "生产环境 SSL 证书生成完成！"
    echo ""
    print_info "使用方法:"
    echo "1. 复制 .env.production 为 .env"
    echo "2. 启动服务: ./start_https.sh"
    echo "3. 设置自动续期: crontab -e 添加 '0 12 * * * /path/to/renew_cert.sh'"
    echo ""
    print_warning "注意: 生产环境请确保域名已正确解析到服务器"
}

# 解析命令行参数
DOMAIN=""
EMAIL=""
METHOD="standalone"
WEBROOT_PATH=""
STAGING="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        --domain)
            DOMAIN="$2"
            shift 2
            ;;
        --email)
            EMAIL="$2"
            shift 2
            ;;
        --method)
            METHOD="$2"
            shift 2
            ;;
        --webroot-path)
            WEBROOT_PATH="$2"
            shift 2
            ;;
        --staging)
            STAGING="true"
            shift
            ;;
        --help|-h)
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

# 运行主函数
main "$@" 