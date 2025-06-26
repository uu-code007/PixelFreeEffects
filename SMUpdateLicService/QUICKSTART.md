# SMBeautyEngine License API 快速开始指南

## 🚀 5分钟快速上手

本指南将帮助您在5分钟内完成 SMBeautyEngine License API 的部署和基本使用。

## 前置条件

- Go 1.19+ 或 Docker
- 基本的命令行操作知识
- 一个可用的端口（默认2443）

## 方式一：使用 Go 运行（推荐开发环境）

### 1. 克隆项目

```bash
git clone <repository-url>
cd SMBeautyEngine/SMUpdateCertificate
```

### 2. 安装依赖

```bash
go mod download
```

### 3. 生成 SSL 证书

```bash
# 生成自签名 SSL 证书
./generate_cert.sh
```

### 4. 启动服务

```bash
# 使用启动脚本（推荐）
./start_https.sh

# 或手动启动 HTTPS
ENABLE_HTTPS=true SSL_CERT_PATH=certs/cert.pem SSL_KEY_PATH=certs/key.pem HTTP_PORT=1880 HTTPS_PORT=2443 go run main.go
```

### 5. 验证服务

```bash
curl -k https://localhost:2443/health
```

应该看到类似输出：
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0"
}
```

## 方式二：使用 Docker 运行（推荐生产环境）

### 1. 构建镜像

```bash
docker build -t smbeauty-license-api .
```

### 2. 运行容器

```bash
docker run -d \
  --name smbeauty-api \
  -p 1880:1880 -p 2443:2443 \
  -e ENABLE_HTTPS=true \
  -e SSL_CERT_PATH=/app/certs/cert.pem \
  -e SSL_KEY_PATH=/app/certs/key.pem \
  -e HTTP_PORT=1880 \
  -e HTTPS_PORT=2443 \
  -e DOWNLOAD_BASE_URL=https://localhost:2443 \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/licenses:/app/licenses \
  -v $(pwd)/certs:/app/certs \
  smbeauty-license-api
```

### 3. 验证服务

```bash
curl -k https://localhost:2443/health
```

## 🎯 基本使用流程

### 步骤1：创建许可证配置

```bash
curl -k -X POST https://localhost:2443/api/admin/license/config \
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
```

### 步骤2：上传许可证文件

```bash
curl -k -X POST https://localhost:2443/api/admin/license/upload/com.example.myapp \
  -F "license_file=@licenses/pixelfreeAuth.lic"
```

### 步骤3：检查许可证状态

```bash
curl -k -X POST https://localhost:2443/api/license/health \
  -H "Content-Type: application/json" \
  -d '{"app_bundle_id": "com.example.myapp"}'
```

### 步骤4：下载许可证文件（如果需要）

```bash
curl -k -O https://localhost:2443/api/license/download/com.example.myapp
```

## 📋 完整演示

运行完整演示脚本：

```bash
./demo.sh --url https://localhost:2443
```

这个脚本会自动执行以下操作：
1. 健康检查
2. 创建许可证配置
3. 上传许可证文件
4. 检查许可证状态
5. 下载许可证文件
6. 查看所有配置

## 🔧 常用命令

### 服务管理

```bash
# 启动服务
./start_https.sh

# 停止服务（如果使用Docker）
docker stop smbeauty-api

# 查看日志
docker logs -f smbeauty-api

# 重启服务
docker restart smbeauty-api
```

### API 测试

```bash
# 健康检查
curl -k https://localhost:2443/health

# 许可证健康检查
curl -k -X POST https://localhost:2443/api/license/health \
  -H "Content-Type: application/json" \
  -d '{"app_bundle_id": "com.example.myapp"}'

# 查看所有配置
curl -k https://localhost:2443/api/admin/license/configs

# 查看特定配置
curl -k https://localhost:2443/api/admin/license/config/com.example.myapp
```

### 管理操作

```bash
# 创建配置
curl -k -X POST https://localhost:2443/api/admin/license/config \
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

# 更新配置
curl -k -X PUT https://localhost:2443/api/admin/license/config/com.example.myapp \
  -H "Content-Type: application/json" \
  -d '{
    "status": "active",
    "expires_at": "2026-12-31T23:59:59Z",
    "features": ["beauty", "filter", "sticker", "background"],
    "version": "2.5.0",
    "description": "更新后的许可证配置",
    "updated_by": "admin"
  }'

# 删除配置
curl -X DELETE http://localhost:15000/api/admin/license/config/com.example.myapp

# 上传文件
curl -X POST http://localhost:15000/api/admin/license/upload/com.example.myapp \
  -F "license_file=@pixelfreeAuth.lic"
```

## 📁 目录结构

```
SMUpdateCertificate/
├── main.go              # 主程序
├── client_example.go    # 客户端示例
├── admin_client.go      # 管理客户端示例
├── test_api.sh          # API测试脚本
├── demo.sh              # 完整演示脚本
├── start.sh             # 启动脚本
├── Dockerfile           # Docker配置
├── docker-compose.yml   # Docker Compose配置
├── Makefile             # 构建脚本
├── go.mod               # Go模块文件
├── data/                # 数据目录
│   └── license_configs.json  # 配置数据文件
├── licenses/            # 许可证文件目录
│   └── pixelfreeAuth.lic     # 许可证文件
├── keys/                # RSA密钥目录
│   ├── private_key.pem  # 私钥
│   └── public_key.pem   # 公钥
├── logs/                # 日志目录
├── README.md            # 详细文档
├── API.md               # API接口文档
├── DEPLOYMENT.md        # 部署指南
└── QUICKSTART.md        # 快速开始指南
```

## 🔍 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 查看端口占用
   lsof -i :15000
   
   # 使用其他端口
   PORT=15001 ./start.sh
   ```

2. **权限问题**
   ```bash
   # 设置执行权限
   chmod +x start.sh test_api.sh demo.sh
   
   # 创建必要目录
   mkdir -p data licenses keys logs
   ```

3. **密钥解析失败**
   ```bash
   # 删除旧密钥，重新生成
   rm -rf keys/private_key.pem keys/public_key.pem
   # 重启服务
   ```

4. **文件上传失败**
   ```bash
   # 检查文件是否存在
   ls -la licenses/pixelfreeAuth.lic
   
   # 检查目录权限
   ls -la licenses/
   ```

### 日志查看

```bash
# 查看服务日志
tail -f logs/app.log

# 查看Docker日志
docker logs -f smbeauty-api

# 查看系统日志
journalctl -u smbeauty-api -f
```

## 📚 下一步

- 📖 阅读 [API.md](API.md) 了解详细的API接口
- 🚀 查看 [DEPLOYMENT.md](DEPLOYMENT.md) 了解生产环境部署
- 🔧 参考 [README.md](README.md) 获取完整文档
- 💻 运行 `go run client_example.go` 查看客户端示例
- 🛠️ 运行 `go run admin_client.go` 查看管理客户端示例

## 🆘 获取帮助

- 查看日志文件了解错误信息
- 运行 `./test_api.sh --url http://localhost:15000` 进行API测试
- 参考完整文档了解详细功能
- 提交Issue获取技术支持

---

**恭喜！** 您已经成功部署并使用了 SMBeautyEngine License API。现在可以开始管理您的许可证配置了！ 