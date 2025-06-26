# SMBeautyEngine License Health Check API Makefile

# 变量定义
BINARY_NAME=smbeauty-license-api
DOCKER_IMAGE=smbeauty-license-api
VERSION=1.0.0

# Go 相关变量
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod

# 默认目标
.DEFAULT_GOAL := help

# 帮助信息
.PHONY: help
help: ## 显示帮助信息
	@echo "SMBeautyEngine License Health Check API"
	@echo ""
	@echo "可用命令:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# 开发相关命令
.PHONY: run
run: ## 运行 HTTPS 开发服务器
	@echo "启动 HTTPS 开发服务器..."
	@chmod +x start_https.sh
	./start_https.sh

.PHONY: run-http
run-http: ## 运行 HTTP 开发服务器（仅开发环境）
	@echo "启动 HTTP 开发服务器..."
	$(GOCMD) run main.go

.PHONY: build
build: ## 构建可执行文件
	@echo "构建可执行文件..."
	$(GOBUILD) -o $(BINARY_NAME) main.go
	@echo "构建完成: $(BINARY_NAME)"

.PHONY: clean
clean: ## 清理构建文件
	@echo "清理构建文件..."
	$(GOCLEAN)
	rm -f $(BINARY_NAME)
	rm -rf licenses/
	rm -rf keys/

.PHONY: test
test: ## 运行测试
	@echo "运行测试..."
	$(GOTEST) -v ./...

.PHONY: test-api
test-api: ## 运行API测试脚本
	@echo "运行API测试..."
	@if [ -f demo.sh ]; then \
		chmod +x demo.sh && ./demo.sh; \
	else \
		echo "演示脚本不存在"; \
	fi

.PHONY: fmt
fmt: ## 格式化代码
	@echo "格式化代码..."
	$(GOCMD) fmt ./...

.PHONY: lint
lint: ## 代码检查
	@echo "代码检查..."
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run; \
	else \
		echo "golangci-lint 未安装，跳过代码检查"; \
	fi

.PHONY: deps
deps: ## 下载依赖
	@echo "下载依赖..."
	$(GOMOD) download
	$(GOMOD) tidy

# Docker 相关命令
.PHONY: docker-build
docker-build: ## 构建Docker镜像
	@echo "构建Docker镜像..."
	docker build -t $(DOCKER_IMAGE):$(VERSION) .
	docker tag $(DOCKER_IMAGE):$(VERSION) $(DOCKER_IMAGE):latest

.PHONY: docker-run
docker-run: ## 运行Docker容器
	@echo "运行Docker容器..."
	docker run -d -p 1880:1880 -p 2443:2443 --name $(BINARY_NAME) \
		-e ENABLE_HTTPS=true \
		-e SSL_CERT_PATH=/app/certs/cert.pem \
		-e SSL_KEY_PATH=/app/certs/key.pem \
		-e HTTP_PORT=1880 \
		-e HTTPS_PORT=2443 \
		-v $(PWD)/certs:/app/certs \
		$(DOCKER_IMAGE):latest

.PHONY: docker-stop
docker-stop: ## 停止Docker容器
	@echo "停止Docker容器..."
	docker stop $(BINARY_NAME) || true
	docker rm $(BINARY_NAME) || true

.PHONY: docker-clean
docker-clean: ## 清理Docker镜像
	@echo "清理Docker镜像..."
	docker rmi $(DOCKER_IMAGE):$(VERSION) || true
	docker rmi $(DOCKER_IMAGE):latest || true

# Docker Compose 命令
.PHONY: compose-up
compose-up: ## 启动Docker Compose服务
	@echo "启动Docker Compose服务..."
	docker-compose up -d

.PHONY: compose-down
compose-down: ## 停止Docker Compose服务
	@echo "停止Docker Compose服务..."
	docker-compose down

.PHONY: compose-logs
compose-logs: ## 查看Docker Compose日志
	@echo "查看Docker Compose日志..."
	docker-compose logs -f

# 部署相关命令
.PHONY: install
install: build ## 安装到系统
	@echo "安装到系统..."
	sudo cp $(BINARY_NAME) /usr/local/bin/
	sudo chmod +x /usr/local/bin/$(BINARY_NAME)
	@echo "安装完成"

.PHONY: uninstall
uninstall: ## 从系统卸载
	@echo "从系统卸载..."
	sudo rm -f /usr/local/bin/$(BINARY_NAME)
	@echo "卸载完成"

# 开发环境设置
.PHONY: setup
setup: ## 设置开发环境
	@echo "设置开发环境..."
	@if [ ! -f go.mod ]; then \
		$(GOCMD) mod init smbeauty-license-api; \
	fi
	$(GOMOD) tidy
	@echo "开发环境设置完成"

.PHONY: init-dirs
init-dirs: ## 初始化目录结构
	@echo "初始化目录结构..."
	mkdir -p licenses keys logs certs
	@echo "目录结构初始化完成"

# 版本管理
.PHONY: version
version: ## 显示版本信息
	@echo "版本: $(VERSION)"
	@echo "Go版本: $(shell $(GOCMD) version)"

# 状态检查
.PHONY: status
status: ## 检查服务状态
	@echo "检查服务状态..."
	@if curl -s -f -k https://localhost:2443/health > /dev/null; then \
		echo "✅ HTTPS 服务正在运行"; \
	else \
		echo "❌ HTTPS 服务未运行"; \
	fi

# 一键启动（开发模式）
.PHONY: dev
dev: setup init-dirs generate-cert ## 一键启动开发环境
	@echo "启动开发环境..."
	$(MAKE) run

# 一键部署
.PHONY: deploy
deploy: build docker-build ## 一键部署
	@echo "部署完成"
	@echo "运行命令启动服务: make docker-run 或 make compose-up"

# 清理所有
.PHONY: clean-all
clean-all: clean docker-clean compose-down ## 清理所有文件
	@echo "清理所有文件完成"

# HTTPS 相关命令
.PHONY: generate-cert
generate-cert: ## 生成 SSL 证书
	@echo "生成 SSL 证书..."
	@chmod +x generate_cert.sh
	./generate_cert.sh

.PHONY: start-https
start-https: ## 运行 HTTPS 服务
	@echo "启动 HTTPS 服务..."
	@chmod +x start_https.sh
	./start_https.sh

.PHONY: test-https
test-https: ## 测试 HTTPS 服务
	@echo "测试 HTTPS 服务..."
	@chmod +x demo.sh
	./demo.sh 