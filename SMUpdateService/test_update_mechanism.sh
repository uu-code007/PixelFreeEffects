#!/bin/bash

echo "=== 测试许可证更新机制 ==="

# 设置服务器地址
SERVER_URL="https://localhost:2443"

# 测试场景1: 旧版本客户端
echo "场景1: 旧版本客户端检查"
curl -k -X POST "$SERVER_URL/api/license/health" \
  -H "Content-Type: application/json" \
  -d '{
    "app_bundle_id": "com.example.androidapp",
    "version": "2.4.0",
    "last_update": "2025-01-01T00:00:00Z"
  }' | jq '.'

echo -e "\n"

# 测试场景2: 当前版本客户端
echo "场景2: 当前版本客户端检查"
curl -k -X POST "$SERVER_URL/api/license/health" \
  -H "Content-Type: application/json" \
  -d '{
    "app_bundle_id": "com.example.androidapp",
    "version": "2.5.0",
    "last_update": "2025-06-26T06:00:00Z"
  }' | jq '.'

echo -e "\n"

# 测试场景3: 最新版本客户端
echo "场景3: 最新版本客户端检查"
curl -k -X POST "$SERVER_URL/api/license/health" \
  -H "Content-Type: application/json" \
  -d '{
    "app_bundle_id": "com.example.androidapp",
    "version": "2.5.0",
    "last_update": "2025-06-26T07:00:00Z"
  }' | jq '.'

echo -e "\n"

# 测试场景4: 向后兼容性测试（不发送version和last_update）
echo "场景4: 向后兼容性测试"
curl -k -X POST "$SERVER_URL/api/license/health" \
  -H "Content-Type: application/json" \
  -d '{
    "app_bundle_id": "com.example.androidapp"
  }' | jq '.'

echo -e "\n"

# 测试场景5: 其他应用
echo "场景5: iOS应用检查"
curl -k -X POST "$SERVER_URL/api/license/health" \
  -H "Content-Type: application/json" \
  -d '{
    "app_bundle_id": "com.example.iosapp",
    "version": "2.4.9",
    "last_update": "2025-01-01T00:00:00Z"
  }' | jq '.'

echo -e "\n测试完成！" 