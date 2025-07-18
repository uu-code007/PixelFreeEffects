# API 变更日志

## v1.1.0 (2025-01-XX)

### 新增功能

#### 许可证智能更新机制
- **新增参数**: `/api/license/health` 接口支持 `version` 和 `last_update` 参数
- **版本检查**: 客户端版本与服务端配置版本不匹配时触发更新
- **配置更新检查**: 服务端配置更新时间晚于客户端最后更新时间时触发更新
- **详细反馈**: 响应中的 `message` 字段明确说明更新原因

#### 更新触发条件
1. **过期更新**: 许可证剩余天数 ≤ 30天或已过期
2. **版本更新**: 客户端版本与服务端配置版本不匹配
3. **配置更新**: 客户端最后更新时间早于服务端配置更新时间

### 向后兼容性
- 现有客户端无需修改即可继续使用
- 新参数为可选参数，不发送时按原有逻辑工作

### 示例变更

#### 请求参数扩展
```json
// 原有请求
{
  "app_bundle_id": "com.example.myapp"
}

// 新请求（可选）
{
  "app_bundle_id": "com.example.myapp",
  "version": "2.4.0",
  "last_update": "2025-01-01T00:00:00Z"
}
```

#### 响应消息增强
```json
// 原有响应
{
  "message": "许可证需要更新"
}

// 新响应
{
  "message": "版本不匹配，服务端版本: 2.5.0，客户端版本: 2.4.0"
}
```

## v1.0.0 (2024-01-15)

### 初始版本
- 基础许可证健康检查功能
- 许可证文件上传下载
- 许可证配置管理
- 管理接口支持 