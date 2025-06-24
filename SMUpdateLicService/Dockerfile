# 多阶段构建 Dockerfile
FROM golang:1.21-alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装必要的系统依赖
RUN apk add --no-cache git ca-certificates tzdata

# 复制 go mod 文件
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制源代码
COPY . .

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o license-api main.go

# 运行阶段
FROM alpine:latest

# 安装 ca-certificates 用于 HTTPS 请求
RUN apk --no-cache add ca-certificates tzdata

# 创建非 root 用户
RUN addgroup -g 1001 -S license-api && \
    adduser -u 1001 -S license-api -G license-api

# 设置工作目录
WORKDIR /app

# 从构建阶段复制二进制文件
COPY --from=builder /app/license-api .

# 创建必要的目录
RUN mkdir -p /app/licenses /app/keys && \
    chown -R license-api:license-api /app

# 切换到非 root 用户
USER license-api

# 暴露端口
EXPOSE 5000

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:5000/health || exit 1

# 设置环境变量
ENV PORT=5000 \
    LICENSE_DIR=/app/licenses \
    PRIVATE_KEY_PATH=/app/keys/private_key.pem \
    PUBLIC_KEY_PATH=/app/keys/public_key.pem \
    LICENSE_VALIDITY_DAYS=365 \
    LOG_LEVEL=info

# 启动应用
CMD ["./license-api"] 