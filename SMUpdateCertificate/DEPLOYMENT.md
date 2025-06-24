# SMBeautyEngine License API 部署指南

## 概述

本文档详细说明如何在不同环境中部署 SMBeautyEngine License API 服务。

## 系统要求

### 最低要求
- **操作系统**: Linux/macOS/Windows
- **内存**: 512MB RAM
- **存储**: 1GB 可用空间
- **网络**: 支持 HTTP/HTTPS 访问

### 推荐配置
- **操作系统**: Ubuntu 20.04+ / CentOS 8+ / macOS 10.15+
- **内存**: 2GB+ RAM
- **存储**: 10GB+ 可用空间
- **CPU**: 2核心+
- **网络**: 千兆网络

## 部署方式

### 1. 本地开发部署

#### 前置条件
- Go 1.19+ 已安装
- Git 已安装

#### 部署步骤

```bash
# 1. 克隆项目
git clone <repository-url>
cd SMBeautyEngine/SMUpdateCertificate

# 2. 安装依赖
go mod download

# 3. 创建必要目录
mkdir -p data licenses keys logs

# 4. 设置权限
chmod +x start.sh test_api.sh demo.sh

# 5. 启动服务
./start.sh

# 或指定端口启动
PORT=15000 go run main.go
```

#### 验证部署

```bash
# 健康检查
curl http://localhost:15000/health

# 测试API
./test_api.sh --url http://localhost:15000
```

### 2. Docker 部署

#### 前置条件
- Docker 20.10+ 已安装
- Docker Compose 2.0+ 已安装

#### 快速部署

```bash
# 1. 构建镜像
docker build -t smbeauty-license-api .

# 2. 运行容器
docker run -d \
  --name smbeauty-api \
  -p 15000:15000 \
  -e PORT=15000 \
  -e LICENSE_VALIDITY_DAYS=365 \
  -e DOWNLOAD_BASE_URL=http://localhost:15000 \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/licenses:/app/licenses \
  -v $(pwd)/keys:/app/keys \
  smbeauty-license-api
```

#### Docker Compose 部署

```bash
# 1. 启动服务
docker-compose up -d

# 2. 查看日志
docker-compose logs -f

# 3. 停止服务
docker-compose down
```

#### 自定义 Docker 配置

创建 `docker-compose.override.yml`:

```yaml
version: '3.8'
services:
  smbeauty-api:
    environment:
      - PORT=15000
      - LICENSE_VALIDITY_DAYS=365
      - LOG_LEVEL=info
      - DOWNLOAD_BASE_URL=https://api.example.com
    volumes:
      - ./data:/app/data
      - ./licenses:/app/licenses
      - ./keys:/app/keys
      - ./logs:/app/logs
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:15000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### 3. 生产环境部署

#### 使用 systemd 服务

1. **创建服务文件**

```bash
sudo tee /etc/systemd/system/smbeauty-api.service << EOF
[Unit]
Description=SMBeautyEngine License API
After=network.target

[Service]
Type=simple
User=smbeauty
Group=smbeauty
WorkingDirectory=/opt/smbeauty-api
ExecStart=/opt/smbeauty-api/smbeauty-license-api
Environment=PORT=15000
Environment=LICENSE_VALIDITY_DAYS=365
Environment=LOG_LEVEL=info
Environment=DOWNLOAD_BASE_URL=https://api.example.com
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

2. **创建用户和目录**

```bash
# 创建用户
sudo useradd -r -s /bin/false smbeauty

# 创建目录
sudo mkdir -p /opt/smbeauty-api/{data,licenses,keys,logs}

# 复制文件
sudo cp smbeauty-license-api /opt/smbeauty-api/
sudo cp -r data/* /opt/smbeauty-api/data/
sudo cp -r licenses/* /opt/smbeauty-api/licenses/

# 设置权限
sudo chown -R smbeauty:smbeauty /opt/smbeauty-api
sudo chmod 600 /opt/smbeauty-api/keys/*
```

3. **启动服务**

```bash
# 重新加载 systemd
sudo systemctl daemon-reload

# 启用服务
sudo systemctl enable smbeauty-api

# 启动服务
sudo systemctl start smbeauty-api

# 查看状态
sudo systemctl status smbeauty-api

# 查看日志
sudo journalctl -u smbeauty-api -f
```

#### 使用 Supervisor

1. **安装 Supervisor**

```bash
# Ubuntu/Debian
sudo apt-get install supervisor

# CentOS/RHEL
sudo yum install supervisor
```

2. **创建配置文件**

```bash
sudo tee /etc/supervisor/conf.d/smbeauty-api.conf << EOF
[program:smbeauty-api]
command=/opt/smbeauty-api/smbeauty-license-api
directory=/opt/smbeauty-api
user=smbeauty
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/opt/smbeauty-api/logs/supervisor.log
environment=PORT=15000,LICENSE_VALIDITY_DAYS=365,LOG_LEVEL=info
EOF
```

3. **启动服务**

```bash
# 重新加载配置
sudo supervisorctl reread
sudo supervisorctl update

# 启动服务
sudo supervisorctl start smbeauty-api

# 查看状态
sudo supervisorctl status smbeauty-api
```

### 4. 云平台部署

#### AWS EC2 部署

1. **启动 EC2 实例**

```bash
# 使用 AWS CLI
aws ec2 run-instances \
  --image-id ami-0c02fb55956c7d316 \
  --instance-type t3.small \
  --key-name your-key-pair \
  --security-group-ids sg-xxxxxxxxx \
  --subnet-id subnet-xxxxxxxxx \
  --user-data file://user-data.sh
```

2. **用户数据脚本** (`user-data.sh`)

```bash
#!/bin/bash
yum update -y
yum install -y docker git

# 启动 Docker
systemctl start docker
systemctl enable docker

# 克隆项目
git clone <repository-url> /opt/smbeauty-api
cd /opt/smbeauty-api/SMUpdateCertificate

# 构建和运行
docker build -t smbeauty-license-api .
docker run -d \
  --name smbeauty-api \
  -p 15000:15000 \
  -e PORT=15000 \
  -v /opt/smbeauty-api/data:/app/data \
  -v /opt/smbeauty-api/licenses:/app/licenses \
  smbeauty-license-api
```

#### Google Cloud Platform 部署

1. **创建 Compute Engine 实例**

```bash
gcloud compute instances create smbeauty-api \
  --zone=us-central1-a \
  --machine-type=e2-small \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --metadata-from-file startup-script=startup-script.sh
```

2. **启动脚本** (`startup-script.sh`)

```bash
#!/bin/bash
apt-get update
apt-get install -y docker.io git

# 启动 Docker
systemctl start docker
systemctl enable docker

# 部署应用
git clone <repository-url> /opt/smbeauty-api
cd /opt/smbeauty-api/SMUpdateCertificate

docker build -t smbeauty-license-api .
docker run -d \
  --name smbeauty-api \
  -p 15000:15000 \
  -e PORT=15000 \
  -v /opt/smbeauty-api/data:/app/data \
  -v /opt/smbeauty-api/licenses:/app/licenses \
  smbeauty-license-api
```

#### Kubernetes 部署

1. **创建 ConfigMap**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: smbeauty-api-config
data:
  PORT: "15000"
  LICENSE_VALIDITY_DAYS: "365"
  LOG_LEVEL: "info"
  DOWNLOAD_BASE_URL: "https://api.example.com"
```

2. **创建 Deployment**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: smbeauty-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: smbeauty-api
  template:
    metadata:
      labels:
        app: smbeauty-api
    spec:
      containers:
      - name: smbeauty-api
        image: smbeauty-license-api:latest
        ports:
        - containerPort: 15000
        envFrom:
        - configMapRef:
            name: smbeauty-api-config
        volumeMounts:
        - name: data-volume
          mountPath: /app/data
        - name: licenses-volume
          mountPath: /app/licenses
        - name: keys-volume
          mountPath: /app/keys
      volumes:
      - name: data-volume
        persistentVolumeClaim:
          claimName: smbeauty-data-pvc
      - name: licenses-volume
        persistentVolumeClaim:
          claimName: smbeauty-licenses-pvc
      - name: keys-volume
        secret:
          secretName: smbeauty-keys
```

3. **创建 Service**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: smbeauty-api-service
spec:
  selector:
    app: smbeauty-api
  ports:
  - protocol: TCP
    port: 80
    targetPort: 15000
  type: LoadBalancer
```

## 环境配置

### 环境变量

| 变量名 | 默认值 | 说明 | 生产环境建议 |
|--------|--------|------|-------------|
| `PORT` | `5000` | 服务端口 | `15000` |
| `LICENSE_DIR` | `licenses` | 证书文件目录 | `licenses` |
| `PRIVATE_KEY_PATH` | `keys/private_key.pem` | 私钥路径 | `keys/private_key.pem` |
| `PUBLIC_KEY_PATH` | `keys/public_key.pem` | 公钥路径 | `keys/public_key.pem` |
| `LICENSE_VALIDITY_DAYS` | `365` | 证书有效期 | `365` |
| `LOG_LEVEL` | `info` | 日志级别 | `info` |
| `DOWNLOAD_BASE_URL` | `http://localhost:5000` | 下载URL基础地址 | `https://api.example.com` |
| `DATA_FILE` | `data/license_configs.json` | 配置数据文件 | `data/license_configs.json` |

### 配置文件

创建 `.env` 文件：

```env
# 服务配置
PORT=15000
LOG_LEVEL=info

# 许可证配置
LICENSE_VALIDITY_DAYS=365
DOWNLOAD_BASE_URL=https://api.example.com

# 文件路径
LICENSE_DIR=licenses
DATA_FILE=data/license_configs.json
PRIVATE_KEY_PATH=keys/private_key.pem
PUBLIC_KEY_PATH=keys/public_key.pem
```

## 安全配置

### 1. 防火墙配置

```bash
# Ubuntu/Debian
sudo ufw allow 15000/tcp
sudo ufw enable

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=15000/tcp
sudo firewall-cmd --reload
```

### 2. SSL/TLS 配置

使用 Nginx 作为反向代理：

```nginx
server {
    listen 443 ssl;
    server_name api.example.com;

    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;

    location / {
        proxy_pass http://localhost:15000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. 密钥管理

```bash
# 生成新的RSA密钥对
openssl genrsa -out keys/private_key.pem 2048
openssl rsa -in keys/private_key.pem -pubout -out keys/public_key.pem

# 设置权限
chmod 600 keys/private_key.pem
chmod 644 keys/public_key.pem
```

## 监控和日志

### 1. 日志配置

```bash
# 创建日志目录
mkdir -p logs

# 配置日志轮转
sudo tee /etc/logrotate.d/smbeauty-api << EOF
/opt/smbeauty-api/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 smbeauty smbeauty
    postrotate
        systemctl reload smbeauty-api
    endscript
}
EOF
```

### 2. 监控脚本

创建监控脚本 `monitor.sh`：

```bash
#!/bin/bash

# 检查服务状态
check_service() {
    if curl -f http://localhost:15000/health > /dev/null 2>&1; then
        echo "Service is running"
        return 0
    else
        echo "Service is down"
        return 1
    fi
}

# 检查磁盘空间
check_disk() {
    usage=$(df /opt/smbeauty-api | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ $usage -gt 80 ]; then
        echo "Disk usage is high: ${usage}%"
        return 1
    fi
    return 0
}

# 主检查
main() {
    check_service
    service_status=$?
    
    check_disk
    disk_status=$?
    
    if [ $service_status -eq 0 ] && [ $disk_status -eq 0 ]; then
        echo "All checks passed"
        exit 0
    else
        echo "Some checks failed"
        exit 1
    fi
}

main
```

### 3. 告警配置

使用 Prometheus + Grafana：

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'smbeauty-api'
    static_configs:
      - targets: ['localhost:15000']
    metrics_path: '/metrics'
    scrape_interval: 30s
```

## 备份和恢复

### 1. 数据备份

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/backup/smbeauty-api"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份数据文件
tar -czf $BACKUP_DIR/data_$DATE.tar.gz data/

# 备份许可证文件
tar -czf $BACKUP_DIR/licenses_$DATE.tar.gz licenses/

# 备份密钥文件
tar -czf $BACKUP_DIR/keys_$DATE.tar.gz keys/

# 清理旧备份（保留30天）
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
```

### 2. 数据恢复

```bash
#!/bin/bash
# restore.sh

BACKUP_FILE=$1
RESTORE_DIR="/opt/smbeauty-api"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

# 停止服务
systemctl stop smbeauty-api

# 恢复数据
tar -xzf $BACKUP_FILE -C $RESTORE_DIR

# 设置权限
chown -R smbeauty:smbeauty $RESTORE_DIR
chmod 600 $RESTORE_DIR/keys/*

# 启动服务
systemctl start smbeauty-api
```

## 故障排除

### 常见问题

1. **服务无法启动**
   ```bash
   # 检查端口占用
   lsof -i :15000
   
   # 检查日志
   journalctl -u smbeauty-api -f
   
   # 检查权限
   ls -la /opt/smbeauty-api/
   ```

2. **文件上传失败**
   ```bash
   # 检查磁盘空间
   df -h
   
   # 检查目录权限
   ls -la licenses/
   
   # 检查文件大小限制
   ulimit -a
   ```

3. **配置加载失败**
   ```bash
   # 检查JSON格式
   cat data/license_configs.json | jq .
   
   # 检查文件权限
   ls -la data/
   ```

4. **密钥解析失败**
   ```bash
   # 重新生成密钥
   rm -rf keys/private_key.pem keys/public_key.pem
   # 重启服务，会自动生成新密钥
   ```

### 性能优化

1. **增加并发连接数**
   ```bash
   # 修改系统限制
   echo "* soft nofile 65536" >> /etc/security/limits.conf
   echo "* hard nofile 65536" >> /etc/security/limits.conf
   ```

2. **启用压缩**
   ```nginx
   # Nginx配置
   gzip on;
   gzip_types application/json;
   ```

3. **缓存配置**
   ```nginx
   # 缓存静态文件
   location ~* \.(lic)$ {
       expires 1d;
       add_header Cache-Control "public, immutable";
   }
   ```

## 更新和升级

### 1. 滚动更新

```bash
# 备份当前版本
cp smbeauty-license-api smbeauty-license-api.backup

# 下载新版本
wget https://github.com/example/smbeauty-api/releases/latest/download/smbeauty-license-api

# 重启服务
systemctl restart smbeauty-api

# 验证更新
curl http://localhost:15000/health
```

### 2. Docker 更新

```bash
# 拉取新镜像
docker pull smbeauty-license-api:latest

# 停止旧容器
docker stop smbeauty-api

# 启动新容器
docker run -d \
  --name smbeauty-api-new \
  -p 15000:15000 \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/licenses:/app/licenses \
  smbeauty-license-api:latest

# 验证新容器
curl http://localhost:15000/health

# 删除旧容器
docker rm smbeauty-api
docker tag smbeauty-api-new smbeauty-api
```

## 支持

如需技术支持，请联系：
- 邮箱: support@example.com
- 文档: https://docs.example.com
- 问题反馈: https://github.com/example/smbeauty-api/issues 