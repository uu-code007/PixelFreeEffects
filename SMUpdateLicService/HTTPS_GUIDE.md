# SMBeautyEngine License API HTTPS 使用指南

## 概述

本指南介绍如何为 SMBeautyEngine License API 启用 HTTPS 支持，包括证书生成、配置和使用方法。

## 功能特性

- ✅ **SSL/TLS 加密** - 支持 HTTPS 安全连接
- ✅ **自动证书生成** - 一键生成自签名证书
- ✅ **HTTP 重定向** - 自动将 HTTP 请求重定向到 HTTPS
- ✅ **双端口支持** - 同时支持 HTTP 和 HTTPS
- ✅ **证书验证** - 自动验证证书文件有效性

## 快速开始

### 1. 生成 SSL 证书

```bash
# 生成自签名证书
./generate_cert.sh
```

这将创建以下文件：
- `certs/cert.pem` - SSL 证书文件
- `certs/key.pem` - SSL 私钥文件
- `.env.https.example` - HTTPS 配置示例

### 2. 启动 HTTPS 服务

```bash
# 使用启动脚本（推荐）
./start_https.sh

# 或手动启动
ENABLE_HTTPS=true SSL_CERT_PATH=certs/cert.pem SSL_KEY_PATH=certs/key.pem HTTP_PORT=1880 HTTPS_PORT=2443 go run main.go
```

### 3. 测试 HTTPS 服务

```bash
# 测试 HTTPS API
curl -k https://localhost:2443/health

# 或使用演示脚本
./demo.sh
```

### 4. 防火墙配置

```bash
# 开放 HTTPS 端口
sudo ufw allow 2443/tcp
sudo ufw allow 1880/tcp  # 用于重定向
```

## 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `ENABLE_HTTPS` | `true` | 是否启用 HTTPS |
| `SSL_CERT_PATH` | `certs/cert.pem` | SSL 证书文件路径 |
| `SSL_KEY_PATH` | `certs/key.pem` | SSL 私钥文件路径 |
| `HTTP_PORT` | `1880` | HTTP 端口（用于重定向） |
| `HTTPS_PORT` | `2443` | HTTPS 端口 |
| `DOWNLOAD_BASE_URL` | `https://localhost:2443` | 下载 URL 基础地址 |

### 配置文件示例

创建 `.env` 文件：

```env
# HTTPS 配置
ENABLE_HTTPS=true
SSL_CERT_PATH=certs/cert.pem
SSL_KEY_PATH=certs/key.pem
HTTP_PORT=1880
HTTPS_PORT=2443
DOWNLOAD_BASE_URL=https://localhost:2443

# 其他配置
LOG_LEVEL=info
LICENSE_VALIDITY_DAYS=365
```

## 使用方法

### 1. 开发环境

```bash
# 生成证书
./generate_cert.sh

# 启动 HTTPS 服务
./start_https.sh

# 测试服务
curl -k https://localhost:2443/health
```

### 2. 生产环境

#### 使用 Let's Encrypt 证书

```bash
# 安装 certbot
sudo apt-get install certbot

# 获取证书
sudo certbot certonly --standalone -d your-domain.com

# 配置证书路径
export SSL_CERT_PATH=/etc/letsencrypt/live/your-domain.com/fullchain.pem
export SSL_KEY_PATH=/etc/letsencrypt/live/your-domain.com/privkey.pem
export ENABLE_HTTPS=true

# 启动服务
go run main.go
```

#### 使用 Nginx 反向代理

```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;

    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;

    location / {
        proxy_pass https://localhost:2443;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

### 3. Docker 环境

```dockerfile
# 在 Dockerfile 中添加证书
COPY certs/ /app/certs/
ENV ENABLE_HTTPS=true
ENV SSL_CERT_PATH=/app/certs/cert.pem
ENV SSL_KEY_PATH=/app/certs/key.pem
```

```yaml
# docker-compose.yml
version: '3.8'
services:
  smbeauty-api:
    build: .
    ports:
      - "1880:1880"
      - "2443:2443"
    environment:
      - ENABLE_HTTPS=true
      - SSL_CERT_PATH=/app/certs/cert.pem
      - SSL_KEY_PATH=/app/certs/key.pem
      - HTTP_PORT=1880
      - HTTPS_PORT=2443
    volumes:
      - ./certs:/app/certs
```

## API 使用示例

### 1. 健康检查

```bash
# HTTPS 健康检查
curl -k https://localhost:2443/health
```

### 2. 许可证健康检查

```bash
# HTTPS 许可证检查
curl -k -X POST https://localhost:2443/api/license/health \
  -H "Content-Type: application/json" \
  -d '{"app_bundle_id": "com.example.myapp"}'
```

### 3. 下载许可证文件

```bash
# HTTPS 下载许可证
curl -k -O https://localhost:2443/api/license/download/com.example.myapp
```

### 4. 管理接口

```bash
# HTTPS 管理接口
curl -k https://localhost:2443/api/admin/license/configs
```

## 客户端代码示例

### Go 客户端

```go
package main

import (
    "crypto/tls"
    "net/http"
    "time"
)

func main() {
    // 创建支持 HTTPS 的客户端
    client := &http.Client{
        Timeout: 30 * time.Second,
        Transport: &http.Transport{
            TLSClientConfig: &tls.Config{
                InsecureSkipVerify: true, // 开发环境跳过证书验证
            },
        },
    }

    // 发送 HTTPS 请求
    resp, err := client.Get("https://localhost:2443/health")
    if err != nil {
        panic(err)
    }
    defer resp.Body.Close()
}
```

### JavaScript 客户端

```javascript
// 使用 fetch API
async function checkHealth() {
    try {
        const response = await fetch('https://localhost:2443/health', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
            },
        });
        
        const data = await response.json();
        console.log('Health check:', data);
    } catch (error) {
        console.error('Error:', error);
    }
}

// 检查许可证健康状态
async function checkLicenseHealth(appBundleId) {
    try {
        const response = await fetch('https://localhost:2443/api/license/health', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ app_bundle_id: appBundleId }),
        });
        
        const data = await response.json();
        console.log('License health:', data);
    } catch (error) {
        console.error('Error:', error);
    }
}
```

#### 端口被占用
```bash
# 错误信息
端口 2443 已被占用

# 解决方案
# 使用其他端口或停止占用端口的服务
export HTTPS_PORT=8443
```

#### 证书验证失败
```bash
# 开发环境跳过证书验证
curl -k https://localhost:2443/health

# 生产环境使用有效证书
# 确保证书域名匹配
```

### 2. 日志查看

```bash
# 查看服务日志
tail -f logs/app.log

# 查看 SSL 连接日志
openssl s_client -connect localhost:2443 -servername localhost
```