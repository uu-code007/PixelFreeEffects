# SMBeautyEngine License API 生产环境部署指南

## 概述

本指南介绍如何将 SMBeautyEngine License API 部署到生产环境，包括域名配置、SSL 证书生成、服务器配置等。

## 前置条件

- 一台具有公网 IP 的服务器
- 一个已注册的域名
- 域名已正确解析到服务器 IP
- 服务器已安装 Docker 或 Go 环境

## 1. 域名配置

### 1.1 域名解析

确保你的域名已正确解析到服务器 IP：

```bash
# 检查域名解析
nslookup api.example.com
dig api.example.com

# 应该返回你的服务器 IP
```

### 1.2 防火墙配置

```bash
# 开放必要端口
sudo ufw allow 80/tcp    # HTTP（用于证书验证）
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 22/tcp    # SSH
sudo ufw enable
```

## 2. SSL 证书生成

### 2.1 使用 Let's Encrypt（推荐）

```bash
# 安装 Certbot
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install certbot

# CentOS/RHEL
sudo yum install certbot

# macOS
brew install certbot

# 生成证书
./generate_production_cert.sh --domain api.example.com --email admin@example.com
```

### 2.2 使用商业证书

如果你有商业 SSL 证书：

```bash
# 将证书文件复制到项目目录
cp your_certificate.crt certs/cert.pem
cp your_private_key.key certs/key.pem

# 设置权限
chmod 644 certs/cert.pem
chmod 600 certs/key.pem
```

## 3. 服务器部署

### 3.1 使用 Docker 部署（推荐）

```bash
# 构建镜像
docker build -t smbeauty-license-api .

# 运行容器
docker run -d \
  --name smbeauty-api \
  --restart unless-stopped \
  -p 80:80 \
  -p 443:443 \
  -e ENABLE_HTTPS=true \
  -e SSL_CERT_PATH=/app/certs/cert.pem \
  -e SSL_KEY_PATH=/app/certs/key.pem \
  -e HTTP_PORT=80 \
  -e HTTPS_PORT=443 \
  -e DOWNLOAD_BASE_URL=https://api.example.com \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/licenses:/app/licenses \
  -v $(pwd)/certs:/app/certs \
  smbeauty-license-api
```

### 3.2 使用 Docker Compose 部署

```bash
# 使用生产环境配置
cp .env.production .env

# 启动服务
docker-compose -f docker-compose.prod.yml up -d
```

### 3.3 直接部署

```bash
# 编译应用
go build -ldflags="-s -w" -o smbeauty-license-api main.go

# 复制配置文件
cp .env.production .env

# 启动服务
./smbeauty-license-api
```

## 4. 反向代理配置（可选）

### 4.1 Nginx 配置

```nginx
server {
    listen 80;
    server_name api.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.example.com;

    ssl_certificate /path/to/certs/cert.pem;
    ssl_certificate_key /path/to/certs/key.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    location / {
        proxy_pass https://localhost:2443;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 4.2 Apache 配置

```apache
<VirtualHost *:80>
    ServerName api.example.com
    Redirect permanent / https://api.example.com/
</VirtualHost>

<VirtualHost *:443>
    ServerName api.example.com
    
    SSLEngine on
    SSLCertificateFile /path/to/certs/cert.pem
    SSLCertificateKeyFile /path/to/certs/key.pem
    
    ProxyPreserveHost On
    ProxyPass / https://localhost:2443/
    ProxyPassReverse / https://localhost:2443/
</VirtualHost>
```

## 5. 证书自动续期

### 5.1 设置定时任务

```bash
# 编辑 crontab
crontab -e

# 添加以下行（每天中午12点检查续期）
0 12 * * * /path/to/project/renew_cert.sh
```

### 5.2 手动续期

```bash
# 手动续期证书
./renew_cert.sh

# 重启服务
docker restart smbeauty-api
# 或
sudo systemctl restart smbeauty-api
```

## 6. 监控和日志

### 6.1 服务监控

```bash
# 检查服务状态
docker ps | grep smbeauty-api
# 或
systemctl status smbeauty-api

# 查看日志
docker logs -f smbeauty-api
# 或
tail -f logs/app.log
```

### 6.2 健康检查

```bash
# 检查 API 健康状态
curl https://api.example.com/health

# 检查证书状态
openssl x509 -in certs/cert.pem -text -noout | grep -A 2 "Validity"
```

## 7. 安全配置

### 7.1 文件权限

```bash
# 设置证书文件权限
chmod 600 certs/key.pem
chmod 644 certs/cert.pem

# 设置数据目录权限
chmod 755 data/
chmod 644 data/license_configs.json
```

### 7.2 防火墙规则

```bash
# 只允许必要端口
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 7.3 系统安全

```bash
# 更新系统
sudo apt-get update && sudo apt-get upgrade

# 安装安全工具
sudo apt-get install fail2ban

# 配置 fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## 8. 备份策略

### 8.1 数据备份

```bash
# 创建备份脚本
cat > backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backup/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# 备份数据
cp -r data/ $BACKUP_DIR/
cp -r licenses/ $BACKUP_DIR/
cp -r certs/ $BACKUP_DIR/

# 压缩备份
tar -czf $BACKUP_DIR.tar.gz $BACKUP_DIR
rm -rf $BACKUP_DIR

echo "备份完成: $BACKUP_DIR.tar.gz"
EOF

chmod +x backup.sh

# 添加到定时任务
echo "0 2 * * * /path/to/backup.sh" | crontab -
```

### 8.2 恢复数据

```bash
# 恢复备份
tar -xzf backup_20241201.tar.gz
cp -r backup_20241201/* ./
```

## 9. 性能优化

### 9.1 系统优化

```bash
# 增加文件描述符限制
echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf

# 优化内核参数
echo "net.core.somaxconn = 65535" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 65535" >> /etc/sysctl.conf
sysctl -p
```

### 9.2 应用优化

```bash
# 使用生产环境配置
export GOMAXPROCS=$(nproc)
export GOGC=100

# 启动时添加参数
./smbeauty-license-api -cpu-profile=cpu.prof -mem-profile=mem.prof
```

## 10. 故障排除

### 10.1 常见问题

1. **证书续期失败**
   ```bash
   # 检查域名解析
   nslookup api.example.com
   
   # 检查端口是否被占用
   sudo netstat -tlnp | grep :80
   sudo netstat -tlnp | grep :443
   ```

2. **服务无法启动**
   ```bash
   # 检查配置文件
   cat .env
   
   # 检查证书文件
   ls -la certs/
   
   # 查看错误日志
   docker logs smbeauty-api
   ```

3. **API 响应慢**
   ```bash
   # 检查系统资源
   top
   free -h
   df -h
   
   # 检查网络连接
   ping api.example.com
   ```

### 10.2 日志分析

```bash
# 查看实时日志
tail -f logs/app.log

# 搜索错误日志
grep ERROR logs/app.log

# 分析访问日志
awk '{print $1}' logs/access.log | sort | uniq -c | sort -nr
```

## 11. 更新和维护

### 11.1 应用更新

```bash
# 停止服务
docker stop smbeauty-api

# 拉取最新代码
git pull origin main

# 重新构建
docker build -t smbeauty-license-api .

# 启动服务
docker start smbeauty-api
```

### 11.2 系统更新

```bash
# 更新系统包
sudo apt-get update && sudo apt-get upgrade

# 重启服务
sudo systemctl restart smbeauty-api
```

## 12. 联系支持

如果在部署过程中遇到问题，请：

1. 查看日志文件
2. 检查配置文件
3. 验证网络连接
4. 联系技术支持团队

---

**注意**: 生产环境部署前请充分测试，确保所有功能正常工作。 