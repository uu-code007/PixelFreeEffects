#!/bin/bash

# SMBeautyEngine License Management System 演示脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置
API_BASE_URL="http://localhost:5000"
DEMO_APP_BUNDLE_ID="com.example.demoapp"

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

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

print_demo() {
    echo -e "${CYAN}[DEMO]${NC} $1"
}

# 检查服务状态
check_service() {
    print_info "检查服务状态..."
    if curl -s -f "$API_BASE_URL/health" > /dev/null; then
        print_success "✅ 服务正在运行"
        return 0
    else
        print_error "❌ 服务未运行，请先启动服务"
        print_info "启动命令: go run main.go 或 ./start.sh"
        return 1
    fi
}

# 等待用户确认
wait_for_user() {
    echo
    read -p "按 Enter 键继续..." -r
    echo
}

# 演示1: 服务健康检查
demo_health_check() {
    print_step "1. 服务健康检查演示"
    print_demo "检查API服务是否正常运行"
    
    response=$(curl -s "$API_BASE_URL/health")
    echo "健康检查响应:"
    echo "$response" | jq '.' 2>/dev/null || echo "$response"
    
    wait_for_user
}

# 演示2: 管理员创建许可证配置
demo_create_config() {
    print_step "2. 管理员创建许可证配置演示"
    print_demo "管理员为应用创建许可证配置"
    
    create_data='{
        "app_bundle_id": "'$DEMO_APP_BUNDLE_ID'",
        "status": "active",
        "expires_at": "2025-12-31T23:59:59Z",
        "features": ["beauty", "filter", "sticker"],
        "version": "2.4.9",
        "platform": "android",
        "description": "演示应用许可证配置",
        "created_by": "admin"
    }'
    
    echo "创建配置请求:"
    echo "$create_data" | jq '.'
    
    response=$(curl -s -X POST "$API_BASE_URL/api/admin/license/config" \
        -H "Content-Type: application/json" \
        -d "$create_data")
    
    echo "创建配置响应:"
    echo "$response" | jq '.' 2>/dev/null || echo "$response"
    
    if echo "$response" | grep -q '"success":true'; then
        print_success "✅ 许可证配置创建成功"
    else
        print_error "❌ 许可证配置创建失败"
    fi
    
    wait_for_user
}

# 演示3: 管理员上传许可证文件
demo_upload_file() {
    print_step "3. 管理员上传许可证文件演示"
    print_demo "管理员上传对应的许可证文件"
    
    if [ ! -f "test_license.lic" ]; then
        print_warning "测试许可证文件不存在，创建示例文件..."
        cat > test_license.lic << 'EOF'
{
  "data": {
    "app_bundle_id": "com.example.demoapp",
    "features": ["beauty", "filter", "sticker"],
    "issued_at": "2024-01-15T10:30:00Z",
    "expires_at": "2025-12-31T23:59:59Z",
    "version": "2.4.9",
    "platform": "all"
  },
  "hash": "demo_hash_value",
  "signature": "demo_signature_value"
}
EOF
        print_success "✅ 示例许可证文件已创建"
    fi
    
    echo "上传许可证文件: test_license.lic"
    
    response=$(curl -s -X POST "$API_BASE_URL/api/admin/license/upload/$DEMO_APP_BUNDLE_ID" \
        -F "license_file=@test_license.lic")
    
    echo "上传文件响应:"
    echo "$response" | jq '.' 2>/dev/null || echo "$response"
    
    if echo "$response" | grep -q '"success":true'; then
        print_success "✅ 许可证文件上传成功"
    else
        print_error "❌ 许可证文件上传失败"
    fi
    
    wait_for_user
}

# 演示4: 客户端检查许可证状态
demo_client_check() {
    print_step "4. 客户端检查许可证状态演示"
    print_demo "客户端应用检查许可证健康状态"
    
    check_data='{"app_bundle_id": "'$DEMO_APP_BUNDLE_ID'"}'
    
    echo "检查许可证请求:"
    echo "$check_data" | jq '.'
    
    response=$(curl -s -X POST "$API_BASE_URL/api/license/health" \
        -H "Content-Type: application/json" \
        -d "$check_data")
    
    echo "检查许可证响应:"
    echo "$response" | jq '.' 2>/dev/null || echo "$response"
    
    if echo "$response" | grep -q '"success":true'; then
        status=$(echo "$response" | jq -r '.data.status' 2>/dev/null || echo "unknown")
        needs_update=$(echo "$response" | jq -r '.data.needs_update' 2>/dev/null || echo "unknown")
        
        print_success "✅ 许可证检查成功"
        print_info "状态: $status"
        print_info "需要更新: $needs_update"
        
        if [ "$needs_update" = "true" ]; then
            print_warning "⚠️  许可证需要更新"
        else
            print_success "✅ 许可证状态正常"
        fi
    else
        print_error "❌ 许可证检查失败"
    fi
    
    wait_for_user
}

# 演示5: 客户端下载许可证文件
demo_download_file() {
    print_step "5. 客户端下载许可证文件演示"
    print_demo "客户端下载许可证文件"
    
    echo "下载许可证文件..."
    
    if curl -s -f -o "downloaded_license.lic" "$API_BASE_URL/api/license/download/$DEMO_APP_BUNDLE_ID"; then
        print_success "✅ 许可证文件下载成功"
        
        if [ -f "downloaded_license.lic" ]; then
            file_size=$(stat -c%s "downloaded_license.lic" 2>/dev/null || stat -f%z "downloaded_license.lic" 2>/dev/null || echo "unknown")
            print_info "文件大小: $file_size 字节"
            
            echo "下载的文件内容预览:"
            head -10 "downloaded_license.lic"
        fi
    else
        print_error "❌ 许可证文件下载失败"
    fi
    
    wait_for_user
}

# 演示6: 管理员更新配置
demo_update_config() {
    print_step "6. 管理员更新许可证配置演示"
    print_demo "管理员更新许可证配置信息"
    
    update_data='{
        "status": "active",
        "expires_at": "2026-06-30T23:59:59Z",
        "features": ["beauty", "filter", "sticker", "background"],
        "version": "2.5.0",
        "description": "更新后的演示应用许可证",
        "updated_by": "admin"
    }'
    
    echo "更新配置请求:"
    echo "$update_data" | jq '.'
    
    response=$(curl -s -X PUT "$API_BASE_URL/api/admin/license/config/$DEMO_APP_BUNDLE_ID" \
        -H "Content-Type: application/json" \
        -d "$update_data")
    
    echo "更新配置响应:"
    echo "$response" | jq '.' 2>/dev/null || echo "$response"
    
    if echo "$response" | grep -q '"success":true'; then
        print_success "✅ 许可证配置更新成功"
    else
        print_error "❌ 许可证配置更新失败"
    fi
    
    wait_for_user
}

# 演示7: 查看配置列表
demo_list_configs() {
    print_step "7. 查看许可证配置列表演示"
    print_demo "管理员查看所有许可证配置"
    
    response=$(curl -s "$API_BASE_URL/api/admin/license/configs")
    
    echo "配置列表响应:"
    echo "$response" | jq '.' 2>/dev/null || echo "$response"
    
    if echo "$response" | grep -q '"success":true'; then
        config_count=$(echo "$response" | jq '.data | length' 2>/dev/null || echo "0")
        print_success "✅ 获取配置列表成功"
        print_info "配置数量: $config_count"
    else
        print_error "❌ 获取配置列表失败"
    fi
    
    wait_for_user
}

# 演示8: 多应用场景
demo_multiple_apps() {
    print_step "8. 多应用场景演示"
    print_demo "演示多个应用的许可证管理"
    
    apps=(
        "com.example.androidapp"
        "com.example.iosapp"
        "com.example.flutterapp"
    )
    
    for app in "${apps[@]}"; do
        print_info "检查应用: $app"
        
        response=$(curl -s -X POST "$API_BASE_URL/api/license/health" \
            -H "Content-Type: application/json" \
            -d "{\"app_bundle_id\": \"$app\"}")
        
        if echo "$response" | grep -q '"success":true'; then
            status=$(echo "$response" | jq -r '.data.status' 2>/dev/null || echo "unknown")
            print_info "  - 状态: $status"
        else
            print_warning "  - 未找到配置"
        fi
    done
    
    wait_for_user
}

# 演示9: 状态管理
demo_status_management() {
    print_step "9. 许可证状态管理演示"
    print_demo "演示禁用和启用许可证"
    
    # 禁用许可证
    print_info "禁用许可证..."
    disable_data='{"status": "disabled", "updated_by": "admin"}'
    
    response=$(curl -s -X PUT "$API_BASE_URL/api/admin/license/config/$DEMO_APP_BUNDLE_ID" \
        -H "Content-Type: application/json" \
        -d "$disable_data")
    
    if echo "$response" | grep -q '"success":true'; then
        print_success "✅ 许可证已禁用"
    else
        print_error "❌ 禁用许可证失败"
    fi
    
    # 检查禁用状态
    print_info "检查禁用状态..."
    check_response=$(curl -s -X POST "$API_BASE_URL/api/license/health" \
        -H "Content-Type: application/json" \
        -d "{\"app_bundle_id\": \"$DEMO_APP_BUNDLE_ID\"}")
    
    status=$(echo "$check_response" | jq -r '.data.status' 2>/dev/null || echo "unknown")
    print_info "当前状态: $status"
    
    # 重新启用
    print_info "重新启用许可证..."
    enable_data='{"status": "active", "updated_by": "admin"}'
    
    response=$(curl -s -X PUT "$API_BASE_URL/api/admin/license/config/$DEMO_APP_BUNDLE_ID" \
        -H "Content-Type: application/json" \
        -d "$enable_data")
    
    if echo "$response" | grep -q '"success":true'; then
        print_success "✅ 许可证已重新启用"
    else
        print_error "❌ 启用许可证失败"
    fi
    
    wait_for_user
}

# 清理演示数据
cleanup_demo() {
    print_step "10. 清理演示数据"
    print_demo "清理演示过程中创建的文件"
    
    # 删除下载的文件
    if [ -f "downloaded_license.lic" ]; then
        rm "downloaded_license.lic"
        print_info "已删除下载的许可证文件"
    fi
    
    # 删除测试文件（可选）
    # if [ -f "test_license.lic" ]; then
    #     rm "test_license.lic"
    #     print_info "已删除测试许可证文件"
    # fi
    
    print_success "✅ 演示数据清理完成"
}

# 主演示函数
main() {
    echo "=== SMBeautyEngine License Management System 演示 ==="
    echo "演示应用Bundle ID: $DEMO_APP_BUNDLE_ID"
    echo "API地址: $API_BASE_URL"
    echo
    
    print_info "本演示将展示完整的许可证管理流程："
    print_info "1. 服务健康检查"
    print_info "2. 管理员创建许可证配置"
    print_info "3. 管理员上传许可证文件"
    print_info "4. 客户端检查许可证状态"
    print_info "5. 客户端下载许可证文件"
    print_info "6. 管理员更新配置"
    print_info "7. 查看配置列表"
    print_info "8. 多应用场景"
    print_info "9. 状态管理"
    print_info "10. 清理演示数据"
    echo
    
    # 检查服务状态
    if ! check_service; then
        exit 1
    fi
    
    # 运行演示
    demo_health_check
    demo_create_config
    demo_upload_file
    demo_client_check
    demo_download_file
    demo_update_config
    demo_list_configs
    demo_multiple_apps
    demo_status_management
    cleanup_demo
    
    echo
    print_success "=== 演示完成 ==="
    print_info "感谢使用 SMBeautyEngine License Management System！"
}

# 显示帮助信息
show_help() {
    echo "SMBeautyEngine License Management System 演示脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --url URL          指定API地址 (默认: http://localhost:5000)"
    echo "  --app-bundle ID    指定演示应用Bundle ID (默认: com.example.demoapp)"
    echo "  --help             显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                                    # 使用默认配置演示"
    echo "  $0 --url http://api.example.com       # 指定API地址"
    echo "  $0 --app-bundle com.myapp.demo        # 指定应用Bundle ID"
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --url)
            API_BASE_URL="$2"
            shift 2
            ;;
        --app-bundle)
            DEMO_APP_BUNDLE_ID="$2"
            shift 2
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

# 检查依赖
if ! command -v curl &> /dev/null; then
    print_error "curl 未安装，请先安装 curl"
    exit 1
fi

# 运行主演示
main 