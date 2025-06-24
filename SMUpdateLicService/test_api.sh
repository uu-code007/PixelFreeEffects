#!/bin/bash

# SMBeautyEngine License Health Check API 测试脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
API_BASE_URL="http://localhost:5000"
TEST_APP_BUNDLE_ID="com.example.testapp"

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

# 检查服务是否运行
check_service() {
    print_info "检查服务状态..."
    if curl -s -f "$API_BASE_URL/health" > /dev/null; then
        print_success "服务正在运行"
        return 0
    else
        print_error "服务未运行，请先启动服务"
        return 1
    fi
}

# 健康检查测试
test_health() {
    print_info "测试健康检查接口..."
    response=$(curl -s "$API_BASE_URL/health")
    if echo "$response" | grep -q "healthy"; then
        print_success "健康检查通过"
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
    else
        print_error "健康检查失败"
        echo "$response"
    fi
    echo
}

# 证书健康检查测试
test_license_health() {
    print_info "测试证书健康检查接口..."
    local app_bundle_id="$1"
    
    response=$(curl -s -X POST "$API_BASE_URL/api/license/health" \
        -H "Content-Type: application/json" \
        -d "{\"app_bundle_id\": \"$app_bundle_id\"}")
    
    if echo "$response" | grep -q '"success":true'; then
        print_success "证书健康检查成功"
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        
        # 检查是否需要更新
        if echo "$response" | grep -q '"needs_update":true'; then
            print_warning "证书需要更新"
            
            # 提取下载URL
            download_url=$(echo "$response" | jq -r '.data.download_url' 2>/dev/null || echo "")
            if [ "$download_url" != "null" ] && [ "$download_url" != "" ]; then
                print_info "下载URL: $download_url"
                
                # 测试下载
                test_download_license "$app_bundle_id"
            fi
        else
            print_success "证书状态正常，无需更新"
        fi
    else
        print_error "证书健康检查失败"
        echo "$response"
    fi
    echo
}

# 下载许可证文件测试
test_download_license() {
    print_info "测试下载许可证文件接口..."
    local app_bundle_id="$1"
    local filename="pixelfreeAuth_${app_bundle_id}.lic"
    
    if curl -s -f -o "$filename" "$API_BASE_URL/api/license/download/$app_bundle_id"; then
        print_success "许可证文件下载成功: $filename"
        if [ -f "$filename" ]; then
            file_size=$(stat -c%s "$filename" 2>/dev/null || stat -f%z "$filename" 2>/dev/null || echo "unknown")
            print_info "文件大小: $file_size 字节"
            
            # 检查文件内容是否为JSON格式
            if head -c 1 "$filename" | grep -q '{'; then
                print_success "许可证文件格式正确 (JSON)"
            else
                print_warning "许可证文件格式可能不正确"
            fi
        fi
    else
        print_error "许可证文件下载失败"
    fi
    echo
}

# 管理接口测试
test_admin_apis() {
    print_info "测试管理接口..."
    
    # 1. 创建许可证配置
    print_info "1. 创建许可证配置..."
    create_response=$(curl -s -X POST "$API_BASE_URL/api/admin/license/config" \
        -H "Content-Type: application/json" \
        -d '{
            "app_bundle_id": "com.example.testapp",
            "status": "active",
            "expires_at": "2025-12-31T23:59:59Z",
            "features": ["beauty", "filter", "sticker"],
            "version": "2.4.9",
            "platform": "android",
            "description": "测试应用许可证",
            "created_by": "admin"
        }')
    
    if echo "$create_response" | grep -q '"success":true'; then
        print_success "许可证配置创建成功"
    else
        print_error "许可证配置创建失败"
        echo "$create_response"
    fi
    echo
    
    # 2. 列出所有配置
    print_info "2. 列出所有许可证配置..."
    list_response=$(curl -s "$API_BASE_URL/api/admin/license/configs")
    if echo "$list_response" | grep -q '"success":true'; then
        print_success "列出配置成功"
        config_count=$(echo "$list_response" | jq '.data | length' 2>/dev/null || echo "0")
        print_info "配置数量: $config_count"
    else
        print_error "列出配置失败"
        echo "$list_response"
    fi
    echo
    
    # 3. 获取特定配置
    print_info "3. 获取特定许可证配置..."
    get_response=$(curl -s "$API_BASE_URL/api/admin/license/config/com.example.testapp")
    if echo "$get_response" | grep -q '"success":true'; then
        print_success "获取配置成功"
        status=$(echo "$get_response" | jq -r '.data.status' 2>/dev/null || echo "unknown")
        print_info "配置状态: $status"
    else
        print_error "获取配置失败"
        echo "$get_response"
    fi
    echo
    
    # 4. 更新配置
    print_info "4. 更新许可证配置..."
    update_response=$(curl -s -X PUT "$API_BASE_URL/api/admin/license/config/com.example.testapp" \
        -H "Content-Type: application/json" \
        -d '{
            "status": "active",
            "expires_at": "2026-12-31T23:59:59Z",
            "features": ["beauty", "filter", "sticker", "background"],
            "version": "2.5.0",
            "description": "更新后的测试应用许可证",
            "updated_by": "admin"
        }')
    
    if echo "$update_response" | grep -q '"success":true'; then
        print_success "许可证配置更新成功"
    else
        print_error "许可证配置更新失败"
        echo "$update_response"
    fi
    echo
    
    # 5. 上传许可证文件
    print_info "5. 上传许可证文件..."
    if [ -f "test_license.lic" ]; then
        upload_response=$(curl -s -X POST "$API_BASE_URL/api/admin/license/upload/com.example.testapp" \
            -F "license_file=@test_license.lic")
        
        if echo "$upload_response" | grep -q '"success":true'; then
            print_success "许可证文件上传成功"
        else
            print_error "许可证文件上传失败"
            echo "$upload_response"
        fi
    else
        print_warning "跳过文件上传测试 (test_license.lic 不存在)"
    fi
    echo
}

# 多应用测试
test_multiple_apps() {
    print_info "多应用证书健康检查测试..."
    
    apps=(
        "com.example.androidapp"
        "com.example.iosapp"
        "com.example.flutterapp"
        "com.example.unityapp"
        "com.example.reactnativeapp"
    )
    
    for app_bundle_id in "${apps[@]}"; do
        print_info "检查应用: $app_bundle_id"
        
        response=$(curl -s -X POST "$API_BASE_URL/api/license/health" \
            -H "Content-Type: application/json" \
            -d "{\"app_bundle_id\": \"$app_bundle_id\"}")
        
        if echo "$response" | grep -q '"success":true'; then
            status=$(echo "$response" | jq -r '.data.status' 2>/dev/null || echo "unknown")
            needs_update=$(echo "$response" | jq -r '.data.needs_update' 2>/dev/null || echo "unknown")
            days_until_expiry=$(echo "$response" | jq -r '.data.days_until_expiry' 2>/dev/null || echo "unknown")
            
            print_info "  - 状态: $status"
            print_info "  - 需要更新: $needs_update"
            print_info "  - 剩余天数: $days_until_expiry"
            
            if [ "$needs_update" = "true" ]; then
                print_warning "  - 需要更新许可证"
            fi
        else
            print_error "  - 检查失败"
        fi
        echo
    done
}

# 性能测试
test_performance() {
    print_info "性能测试..."
    local iterations=10
    local total_time=0
    
    for i in $(seq 1 $iterations); do
        start_time=$(date +%s%N)
        curl -s -f "$API_BASE_URL/health" > /dev/null
        end_time=$(date +%s%N)
        
        duration=$(( (end_time - start_time) / 1000000 ))  # 转换为毫秒
        total_time=$((total_time + duration))
        
        print_info "请求 $i: ${duration}ms"
    done
    
    avg_time=$((total_time / iterations))
    print_success "平均响应时间: ${avg_time}ms"
    echo
}

# 清理测试数据
cleanup_test_data() {
    print_info "清理测试数据..."
    
    # 删除测试下载的文件
    if [ -f "pixelfreeAuth_${TEST_APP_BUNDLE_ID}.lic" ]; then
        rm "pixelfreeAuth_${TEST_APP_BUNDLE_ID}.lic"
        print_info "已删除测试下载文件"
    fi
    
    # 删除测试配置（可选）
    # 注释掉删除操作，避免误删
    # curl -s -X DELETE "$API_BASE_URL/api/admin/license/config/com.example.testapp" > /dev/null
    
    print_info "测试数据清理完成"
    echo
}

# 主测试函数
main() {
    echo "=== SMBeautyEngine License Health Check API 测试 ==="
    echo "测试应用Bundle ID: $TEST_APP_BUNDLE_ID"
    echo "API地址: $API_BASE_URL"
    echo
    
    # 检查服务状态
    if ! check_service; then
        exit 1
    fi
    
    # 运行测试
    test_health
    test_admin_apis
    test_license_health "$TEST_APP_BUNDLE_ID"
    test_multiple_apps
    test_performance
    
    # 清理测试数据
    cleanup_test_data
    
    print_success "所有测试完成！"
}

# 显示帮助信息
show_help() {
    echo "SMBeautyEngine License Health Check API 测试脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --url URL          指定API地址 (默认: http://localhost:5000)"
    echo "  --app-bundle ID    指定测试应用Bundle ID (默认: com.example.testapp)"
    echo "  --admin-only       只测试管理接口"
    echo "  --client-only      只测试客户端接口"
    echo "  --help             显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                                    # 使用默认配置测试"
    echo "  $0 --url http://api.example.com       # 指定API地址"
    echo "  $0 --app-bundle com.myapp.test        # 指定应用Bundle ID"
    echo "  $0 --admin-only                       # 只测试管理接口"
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --url)
            API_BASE_URL="$2"
            shift 2
            ;;
        --app-bundle)
            TEST_APP_BUNDLE_ID="$2"
            shift 2
            ;;
        --admin-only)
            echo "=== 只测试管理接口 ==="
            check_service && test_admin_apis
            exit 0
            ;;
        --client-only)
            echo "=== 只测试客户端接口 ==="
            check_service && test_health && test_license_health "$TEST_APP_BUNDLE_ID" && test_multiple_apps
            exit 0
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

# 运行主测试
main 