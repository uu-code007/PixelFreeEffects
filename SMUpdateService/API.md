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

检查指定应用的许可证健康状态，支持版本检查和配置更新检查。

**请求参数**:
```json
{
  "app_bundle_id": "com.example.myapp",
  "version": "2.4.0",
  "last_update": "2025-01-01T00:00:00Z"
}
```

**请求字段说明**:
- `app_bundle_id` (string, 必需): 应用包名，唯一标识符
- `version` (string, 可选): 客户端当前版本号
- `last_update` (string, 可选): 客户端最后更新时间 (ISO 8601格式)

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
    "message": "版本不匹配，服务端版本: 2.5.0，客户端版本: 2.4.0",
    "features": ["beauty", "filter", "sticker"],
    "version": "2.5.0",
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
- `message`: 状态描述，包含更新原因
- `features`: 功能列表
- `version`: 服务端配置的SDK版本
- `platform`: 平台
- `license_file`: 许可证文件名
- `download_url`: 下载URL（仅在需要更新时提供）

**更新触发条件**:
1. **过期更新**: 许可证剩余天数 ≤ 30天或已过期
2. **版本更新**: 客户端版本与服务端配置版本不匹配
3. **配置更新**: 客户端最后更新时间早于服务端配置更新时间

**更新原因说明**:
- 过期更新: "许可证即将过期或已过期，需要更新"
- 版本更新: "版本不匹配，服务端版本: X.X.X，客户端版本: Y.Y.Y"
- 配置更新: "服务端配置已更新，需要同步最新配置"

**cURL 示例**:
```bash
# 基本检查（向后兼容）
curl -k -X POST https://localhost:2443/api/license/health \
  -H "Content-Type: application/json" \
  -d '{"app_bundle_id": "com.example.myapp"}'

# 带版本和更新时间检查
curl -k -X POST https://localhost:2443/api/license/health \
  -H "Content-Type: application/json" \
  -d '{
    "app_bundle_id": "com.example.myapp",
    "version": "2.4.0",
    "last_update": "2025-01-01T00:00:00Z"
  }'
```

## 3. 许可证更新机制

### 概述

许可证更新机制通过智能检查确保客户端能够及时获取最新的许可证配置。系统支持三种更新触发条件：

1. **过期检查**: 当许可证剩余天数 ≤ 30天或已过期时触发更新
2. **版本检查**: 当客户端版本与服务端配置版本不匹配时触发更新
3. **配置更新检查**: 当服务端配置更新时间晚于客户端最后更新时间时触发更新

### 客户端实现建议

#### 1. 启动时检查
```javascript
// 读取本地存储的版本和更新时间
const localVersion = getLocalVersion(); // 例如: "2.4.0"
const lastUpdate = getLastUpdateTime(); // 例如: "2025-01-01T00:00:00Z"

// 调用健康检查接口
const response = await fetch('/api/license/health', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    app_bundle_id: 'com.example.myapp',
    version: localVersion,
    last_update: lastUpdate
  })
});
```

#### 2. 处理更新响应
```javascript
const result = await response.json();
if (result.success && result.data.needs_update) {
  // 下载新许可证
  const downloadResponse = await fetch(result.data.download_url);
  if (downloadResponse.ok) {
    const licenseData = await downloadResponse.blob();
    // 保存许可证文件
    await saveLicenseFile(licenseData);
    
    // 更新本地版本和更新时间
    updateLocalVersion(result.data.version);
    updateLastUpdateTime(new Date().toISOString());
  }
}
```

#### 3. 向后兼容性
如果客户端不支持新参数，可以只发送 `app_bundle_id`：
```javascript
// 向后兼容的请求
const response = await fetch('/api/license/health', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    app_bundle_id: 'com.example.myapp'
  })
});
```

### 测试场景

#### 场景1: 版本不匹配
- 服务端版本: 2.5.0
- 客户端版本: 2.4.0
- 预期结果: `needs_update: true`, 消息包含版本差异信息

#### 场景2: 配置已更新
- 服务端配置更新时间: 2025-06-26T06:36:56Z
- 客户端最后更新时间: 2025-06-26T06:00:00Z
- 预期结果: `needs_update: true`, 消息提示配置更新

#### 场景3: 正常状态
- 版本匹配且配置未更新
- 预期结果: `needs_update: false`

## 4. 下载许可证文件

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

# 许可证健康检查（基本）
curl -k -X POST https://localhost:2443/api/license/health \
  -H "Content-Type: application/json" \
  -d '{"app_bundle_id": "com.example.myapp"}'

# 许可证健康检查（带版本和更新时间）
curl -k -X POST https://localhost:2443/api/license/health \
  -H "Content-Type: application/json" \
  -d '{
    "app_bundle_id": "com.example.myapp",
    "version": "2.4.0",
    "last_update": "2025-01-01T00:00:00Z"
  }'

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

```javascript
// 许可证健康检查
async function checkLicenseHealth(appBundleId, version, lastUpdate) {
  const response = await fetch('/api/license/health', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      app_bundle_id: appBundleId,
      version: version,
      last_update: lastUpdate
    })
  });
  
  const result = await response.json();
  return result;
}

// 处理许可证更新
async function handleLicenseUpdate(appBundleId) {
  // 读取本地存储的版本和更新时间
  const localVersion = localStorage.getItem('license_version') || '';
  const lastUpdate = localStorage.getItem('license_last_update') || '';
  
  // 检查健康状态
  const healthResult = await checkLicenseHealth(appBundleId, localVersion, lastUpdate);
  
  if (healthResult.success && healthResult.data.needs_update) {
    console.log('需要更新许可证:', healthResult.data.message);
    
    // 下载新许可证
    const downloadResponse = await fetch(healthResult.data.download_url);
    if (downloadResponse.ok) {
      const licenseBlob = await downloadResponse.blob();
      
      // 保存许可证文件（这里简化处理）
      const url = URL.createObjectURL(licenseBlob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'pixelfreeAuth.lic';
      a.click();
      URL.revokeObjectURL(url);
      
      // 更新本地存储
      localStorage.setItem('license_version', healthResult.data.version);
      localStorage.setItem('license_last_update', new Date().toISOString());
      
      console.log('许可证更新成功');
    }
  } else {
    console.log('许可证状态正常');
  }
}

// 使用示例
handleLicenseUpdate('com.example.myapp');
```

## 版本更新说明

### v1.1 新增功能

**许可证智能更新机制**

本次更新引入了智能的许可证更新机制，解决了存量客户端在服务端配置更新后不主动更新的问题。

#### 新增特性

1. **版本检查**: 客户端可以发送当前版本号，服务端会检查版本匹配性
2. **配置更新检查**: 客户端可以发送最后更新时间，服务端会检查配置是否已更新
3. **详细更新原因**: 响应中的 `message` 字段会明确说明更新原因
4. **向后兼容**: 现有客户端无需修改即可继续使用

#### 更新内容

- 扩展了 `/api/license/health` 接口，支持 `version` 和 `last_update` 参数
- 增强了健康检查逻辑，支持三种更新触发条件
- 添加了详细的客户端实现示例
- 提供了完整的测试场景说明

#### 迁移指南

**现有客户端**: 无需修改，系统保持向后兼容
**新客户端**: 建议实现版本和更新时间检查以获得更好的更新体验

#### 测试建议

使用提供的测试脚本 `test_update_mechanism.sh` 验证新功能：
```bash
chmod +x test_update_mechanism.sh
./test_update_mechanism.sh
```

## 贴纸管理接口

## 10. 获取所有贴纸列表

### GET /api/stickers

获取所有可用的贴纸列表，包含贴纸名称、icon下载路径和bundle下载路径。

**请求参数**: 无

**成功响应**:
```json
{
  "success": true,
  "data": [
    {
      "name": "baixiaomao",
      "icon_url": "https://localhost:2443/api/stickers/icon/baixiaomao.png",
      "bundle_url": "https://localhost:2443/api/stickers/bundle/baixiaomao.bundle"
    },
    {
      "name": "bear_headgear",
      "icon_url": "https://localhost:2443/api/stickers/icon/bear_headgear.png",
      "bundle_url": "https://localhost:2443/api/stickers/bundle/bear_headgear.bundle"
    },
    {
      "name": "big_eyes",
      "icon_url": "https://localhost:2443/api/stickers/icon/big_eyes.png",
      "bundle_url": "https://localhost:2443/api/stickers/bundle/big_eyes.bundle"
    }
  ]
}
```

**错误响应**:
```json
{
  "success": false,
  "error": "stickers目录不存在"
}
```

**响应字段说明**:
- `name`: 贴纸名称（去掉.bundle后缀）
- `icon_url`: icon图片的下载URL
- `bundle_url`: bundle文件的下载URL

**cURL 示例**:
```bash
curl -k https://localhost:2443/api/stickers
```

## 11. 获取单个贴纸信息

### GET /api/stickers/{name}

获取指定贴纸的详细信息。

**路径参数**:
- `name` (string): 贴纸名称（不包含.bundle后缀）

**请求参数**: 无

**成功响应**:
```json
{
  "success": true,
  "data": {
    "name": "baixiaomao",
    "icon_url": "https://localhost:2443/api/stickers/icon/baixiaomao.png",
    "bundle_url": "https://localhost:2443/api/stickers/bundle/baixiaomao.bundle"
  }
}
```

**错误响应**:
```json
{
  "success": false,
  "error": "贴纸bundle文件不存在: baixiaomao.bundle"
}
```

**cURL 示例**:
```bash
curl -k https://localhost:2443/api/stickers/baixiaomao
```

## 12. 下载贴纸Icon

### GET /api/stickers/icon/{name}.png

下载指定贴纸的icon图片文件。

**路径参数**:
- `name` (string): 贴纸名称（不包含.png后缀）

**请求参数**: 无

**成功响应**:
- Content-Type: `image/png`
- 文件内容: PNG格式的icon图片

**错误响应**:
```json
{
  "success": false,
  "error": "贴纸icon文件不存在: baixiaomao.png"
}
```

**cURL 示例**:
```bash
curl -k -O https://localhost:2443/api/stickers/icon/baixiaomao.png
```

## 13. 下载贴纸Bundle

### GET /api/stickers/bundle/{filename}

下载指定贴纸的bundle文件。

**路径参数**:
- `filename` (string): bundle文件名（必须包含.bundle后缀）

**请求参数**: 无

**成功响应**:
- Content-Type: `application/octet-stream`
- 文件内容: bundle文件内容

**错误响应**:
```json
{
  "success": false,
  "error": "文件名必须以.bundle结尾"
}
```

**cURL 示例**:
```bash
curl -k -O https://localhost:2443/api/stickers/bundle/baixiaomao.bundle
```

## 贴纸API使用示例

### JavaScript 示例

```javascript
// 获取所有贴纸列表
async function getStickersList() {
  const response = await fetch('/api/stickers');
  const result = await response.json();
  
  if (result.success) {
    console.log('可用贴纸列表:', result.data);
    return result.data;
  } else {
    console.error('获取贴纸列表失败:', result.error);
    return [];
  }
}

// 获取单个贴纸信息
async function getStickerInfo(name) {
  const response = await fetch(`/api/stickers/${name}`);
  const result = await response.json();
  
  if (result.success) {
    console.log('贴纸信息:', result.data);
    return result.data;
  } else {
    console.error('获取贴纸信息失败:', result.error);
    return null;
  }
}

// 下载贴纸icon
async function downloadStickerIcon(name) {
  const response = await fetch(`/api/stickers/icon/${name}.png`);
  if (response.ok) {
    const blob = await response.blob();
    const url = URL.createObjectURL(blob);
    
    // 创建下载链接
    const a = document.createElement('a');
    a.href = url;
    a.download = `${name}.png`;
    a.click();
    URL.revokeObjectURL(url);
  }
}

// 下载贴纸bundle
async function downloadStickerBundle(filename) {
  const response = await fetch(`/api/stickers/bundle/${filename}`);
  if (response.ok) {
    const blob = await response.blob();
    const url = URL.createObjectURL(blob);
    
    // 创建下载链接
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    a.click();
    URL.revokeObjectURL(url);
  }
}

// 使用示例
async function loadStickers() {
  // 获取所有贴纸
  const stickers = await getStickersList();
  
  // 显示贴纸列表
  stickers.forEach(sticker => {
    console.log(`贴纸: ${sticker.name}`);
    console.log(`  Icon: ${sticker.icon_url}`);
    console.log(`  Bundle: ${sticker.bundle_url}`);
  });
  
  // 获取特定贴纸信息
  const stickerInfo = await getStickerInfo('baixiaomao');
  if (stickerInfo) {
    // 下载icon和bundle
    await downloadStickerIcon('baixiaomao');
    await downloadStickerBundle('baixiaomao.bundle');
  }
}

// 执行
loadStickers();
```

### 贴纸文件结构说明

贴纸文件按照以下结构组织：

```
Stickers/
├── baixiaomao.bundle          # 贴纸bundle文件
├── bear_headgear.bundle
├── big_eyes.bundle
├── ...
└── icon/
    ├── baixiaomao.png         # 对应的icon图片
    ├── bear_headgear.png
    ├── big_eyes.png
    └── ...
```

**注意事项**:
1. 每个贴纸必须同时存在 `.bundle` 文件和对应的 `.png` icon文件
2. icon文件名必须与bundle文件名（去掉.bundle后缀）完全匹配
3. 如果某个贴纸缺少对应的icon文件，该贴纸将不会出现在列表中
4. 所有文件名支持中文和英文，但建议使用英文命名以避免编码问题

### 错误处理

贴纸API可能返回的错误类型：

| 错误信息 | 说明 | 解决方案 |
|----------|------|----------|
| `stickers目录不存在` | Stickers目录未找到 | 检查项目根目录下是否存在Stickers文件夹 |
| `stickers/icon目录不存在` | icon目录未找到 | 检查Stickers目录下是否存在icon子目录 |
| `贴纸bundle文件不存在` | 指定的bundle文件未找到 | 检查贴纸名称是否正确，文件是否存在 |
| `贴纸icon文件不存在` | 指定的icon文件未找到 | 检查对应的png文件是否存在 |
| `文件名必须以.bundle结尾` | bundle下载时文件名格式错误 | 确保文件名包含.bundle后缀 |

### 性能优化建议

1. **缓存策略**: 客户端可以缓存贴纸列表，定期更新
2. **批量下载**: 可以预先下载常用的贴纸文件
3. **CDN加速**: 生产环境建议使用CDN加速文件下载
4. **压缩传输**: 可以考虑对bundle文件进行压缩传输