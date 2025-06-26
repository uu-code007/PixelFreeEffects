# SMBeautyEngine License API 接口文档

## 概述

SMBeautyEngine License API 提供许可证健康检查和管理功能，支持基于数据表的配置管理和文件上传下载。

**基础URL**: `https://localhost:2443`  
**API版本**: v1.0  
**内容类型**: `application/json`

## 认证

当前版本API无需认证，生产环境建议添加JWT或API Key认证。

## 通用响应格式

### 成功响应
```json
{
  "success": true,
  "data": {},
  "message": "操作成功"
}
```

### 错误响应
```json
{
  "success": false,
  "error": "错误描述",
  "code": "ERROR_CODE"
}
```

## 错误码说明

| 错误码 | 说明 |
|--------|------|
| `INVALID_PARAMS` | 参数无效 |
| `LICENSE_NOT_FOUND` | 许可证配置不存在 |
| `FILE_NOT_FOUND` | 文件不存在 |
| `UPLOAD_FAILED` | 文件上传失败 |
| `INTERNAL_ERROR` | 内部服务器错误 |
| `LICENSE_EXPIRED` | 许可证已过期 |
| `LICENSE_DISABLED` | 许可证已禁用 |

## 1. 健康检查

### GET /health

检查服务运行状态。

**请求参数**: 无

**响应示例**:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0",
  "uptime": "2h30m15s"
}
```

**响应字段说明**:
- `status`: 服务状态 (healthy/unhealthy)
- `timestamp`: 当前时间戳
- `version`: API版本
- `uptime`: 服务运行时间

**cURL 示例**:
```bash
curl -k https://localhost:2443/health
```

## 2. 许可证健康检查

### POST /api/license/health

检查指定应用的许可证健康状态。

**请求参数**:
```json
{
  "app_bundle_id": "com.example.myapp"
}
```

**请求字段说明**:
- `app_bundle_id` (string, 必需): 应用包名，唯一标识符

**成功响应**:
```json
{
  "success": true,
  "data": {
    "app_bundle_id": "com.example.myapp",
    "needs_update": false,
    "expires_at": "2025-12-31T23:59:59Z",
    "days_until_expiry": 190,
    "status": "active",
    "message": "许可证配置正常",
    "features": ["beauty", "filter", "sticker"],
    "version": "2.4.9",
    "platform": "android",
    "license_file": "pixelfreeAuth.lic"
  }
}
```

**需要更新时的响应**:
```json
{
  "success": true,
  "data": {
    "app_bundle_id": "com.example.myapp",
    "needs_update": true,
    "expires_at": "2024-02-15T10:30:00Z",
    "days_until_expiry": 15,
    "download_url": "https://localhost:2443/api/license/download/com.example.myapp",
    "status": "needs_update",
    "message": "许可证需要更新",
    "features": ["beauty", "filter", "sticker"],
    "version": "2.4.9",
    "platform": "android",
    "license_file": "pixelfreeAuth.lic"
  }
}
```

**错误响应**:
```json
{
  "success": false,
  "error": "许可证配置不存在",
  "code": "LICENSE_NOT_FOUND"
}
```

**响应字段说明**:
- `needs_update`: 是否需要更新
- `expires_at`: 过期时间
- `days_until_expiry`: 距离过期天数
- `status`: 状态 (active/expired/disabled/needs_update)
- `message`: 状态描述
- `features`: 功能列表
- `version`: SDK版本
- `platform`: 平台
- `license_file`: 许可证文件名
- `download_url`: 下载URL（仅在需要更新时提供）

**cURL 示例**:
```bash
curl -k -X POST https://localhost:2443/api/license/health \
  -H "Content-Type: application/json" \
  -d '{"app_bundle_id": "com.example.myapp"}'
```

## 3. 下载许可证文件

### GET /api/license/download/{app_bundle_id}

下载指定应用的许可证文件。

**路径参数**:
- `app_bundle_id` (string): 应用包名

**请求参数**: 无

**成功响应**:
- Content-Type: `application/octet-stream`
- 文件内容: `pixelfreeAuth.lic` 文件内容

**错误响应**:
```json
{
  "success": false,
  "error": "许可证文件不存在",
  "code": "FILE_NOT_FOUND"
}
```

**cURL 示例**:
```bash
curl -k -O https://localhost:2443/api/license/download/com.example.myapp
```

## 管理接口

## 4. 创建许可证配置

### POST /api/admin/license/config

创建新的许可证配置。

**请求参数**:
```json
{
  "app_bundle_id": "com.example.myapp",
  "status": "active",
  "expires_at": "2025-12-31T23:59:59Z",
  "features": ["beauty", "filter", "sticker"],
  "version": "2.4.9",
  "platform": "android",
  "description": "Android应用许可证",
  "created_by": "admin"
}
```

**请求字段说明**:
- `app_bundle_id` (string, 必需): 应用包名
- `status` (string, 必需): 状态 (active/expired/disabled)
- `expires_at` (string, 必需): 过期时间 (ISO 8601格式)
- `features` (array, 可选): 功能列表
- `version` (string, 可选): SDK版本
- `platform` (string, 可选): 平台 (android/ios/flutter)
- `description` (string, 可选): 描述信息
- `created_by` (string, 可选): 创建者

**成功响应**:
```json
{
  "success": true,
  "message": "许可证配置创建成功",
  "data": {
    "app_bundle_id": "com.example.myapp",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

**错误响应**:
```json
{
  "success": false,
  "error": "应用包名已存在",
  "code": "DUPLICATE_APP_ID"
}
```

## 5. 更新许可证配置

### PUT /api/admin/license/config/{app_bundle_id}

更新指定应用的许可证配置。

**路径参数**:
- `app_bundle_id` (string): 应用包名

**请求参数**:
```json
{
  "status": "active",
  "expires_at": "2026-12-31T23:59:59Z",
  "features": ["beauty", "filter", "sticker", "background"],
  "version": "2.5.0",
  "platform": "android",
  "description": "更新后的许可证配置",
  "updated_by": "admin"
}
```

**请求字段说明**:
- `status` (string, 可选): 状态
- `expires_at` (string, 可选): 过期时间
- `features` (array, 可选): 功能列表
- `version` (string, 可选): SDK版本
- `platform` (string, 可选): 平台
- `description` (string, 可选): 描述信息
- `updated_by` (string, 可选): 更新者

**成功响应**:
```json
{
  "success": true,
  "message": "许可证配置更新成功",
  "data": {
    "app_bundle_id": "com.example.myapp",
    "updated_at": "2024-01-15T10:35:00Z"
  }
}
```

**错误响应**:
```json
{
  "success": false,
  "error": "许可证配置不存在",
  "code": "LICENSE_NOT_FOUND"
}
```

## 6. 获取许可证配置

### GET /api/admin/license/config/{app_bundle_id}

获取指定应用的许可证配置详情。

**路径参数**:
- `app_bundle_id` (string): 应用包名

**请求参数**: 无

**成功响应**:
```json
{
  "success": true,
  "data": {
    "app_bundle_id": "com.example.myapp",
    "status": "active",
    "expires_at": "2025-12-31T23:59:59Z",
    "features": ["beauty", "filter", "sticker"],
    "version": "2.4.9",
    "platform": "android",
    "description": "Android应用许可证",
    "license_file": "pixelfreeAuth.lic",
    "created_by": "admin",
    "updated_by": "system",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:35:00Z"
  }
}
```

**错误响应**:
```json
{
  "success": false,
  "error": "许可证配置不存在",
  "code": "LICENSE_NOT_FOUND"
}
```

## 7. 列出所有许可证配置

### GET /api/admin/license/configs

获取所有许可证配置列表。

**请求参数**: 无

**成功响应**:
```json
{
  "success": true,
  "data": [
    {
      "app_bundle_id": "com.example.myapp",
      "status": "active",
      "expires_at": "2025-12-31T23:59:59Z",
      "features": ["beauty", "filter", "sticker"],
      "version": "2.4.9",
      "platform": "android",
      "description": "Android应用许可证",
      "license_file": "pixelfreeAuth.lic",
      "created_by": "admin",
      "updated_by": "system",
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T10:35:00Z"
    }
  ],
  "total": 1
}
```

**响应字段说明**:
- `data`: 配置列表
- `total`: 总数量

## 8. 删除许可证配置

### DELETE /api/admin/license/config/{app_bundle_id}

删除指定应用的许可证配置。

**路径参数**:
- `app_bundle_id` (string): 应用包名

**请求参数**: 无

**成功响应**:
```json
{
  "success": true,
  "message": "许可证配置删除成功"
}
```

**错误响应**:
```json
{
  "success": false,
  "error": "许可证配置不存在",
  "code": "LICENSE_NOT_FOUND"
}
```

## 9. 上传许可证文件

### POST /api/admin/license/upload/{app_bundle_id}

上传指定应用的许可证文件。

**路径参数**:
- `app_bundle_id` (string): 应用包名

**请求参数**:
- Content-Type: `multipart/form-data`
- `license_file` (file, 必需): 许可证文件 (.lic格式)

**成功响应**:
```json
{
  "success": true,
  "message": "许可证文件上传成功",
  "data": {
    "filename": "pixelfreeAuth.lic",
    "size": 1024,
    "uploaded_at": "2024-01-15T10:35:00Z"
  }
}
```

**错误响应**:
```json
{
  "success": false,
  "error": "文件上传失败",
  "code": "UPLOAD_FAILED"
}
```

**响应字段说明**:
- `filename`: 保存的文件名
- `size`: 文件大小（字节）
- `uploaded_at`: 上传时间

## 状态码说明

| HTTP状态码 | 说明 |
|------------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

## 使用示例

### cURL 示例

```bash
# 健康检查
curl -k https://localhost:2443/health

# 许可证健康检查
curl -k -X POST https://localhost:2443/api/license/health \
  -H "Content-Type: application/json" \
  -d '{"app_bundle_id": "com.example.myapp"}'

# 创建许可证配置
curl -X POST https://localhost:2443/api/admin/license/config \
  -H "Content-Type: application/json" \
  -d '{
    "app_bundle_id": "com.example.myapp",
    "status": "active",
    "expires_at": "2025-12-31T23:59:59Z",
    "features": ["beauty", "filter", "sticker"],
    "version": "2.4.9",
    "platform": "android",
    "description": "Android应用许可证",
    "created_by": "admin"
  }'

# 上传许可证文件
curl -X POST https://localhost:2443/api/admin/license/upload/com.example.myapp \
  -F "license_file=@pixelfreeAuth.lic"

# 下载许可证文件
curl -k -O https://localhost:2443/api/license/download/com.example.myapp

# 获取所有配置
curl https://localhost:2443/api/admin/license/configs
```

### JavaScript 示例

```