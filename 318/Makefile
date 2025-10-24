# 新都桥旅行网站 Makefile
# 提供便捷的部署和管理命令

.PHONY: help build start stop restart status logs clean dev prod test health

# 默认目标
.DEFAULT_GOAL := help

# 变量定义
COMPOSE_FILE := docker-compose.yml
PROJECT_NAME := xinduqiao-travel
SERVICE_NAME := xinduqiao-travel

# 帮助信息
help: ## 显示帮助信息
	@echo "新都桥旅行网站 Docker 管理命令"
	@echo "=================================="
	@echo ""
	@echo "基础命令:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "环境命令:"
	@echo "  make dev          # 启动开发环境"
	@echo "  make prod         # 启动生产环境"
	@echo "  make test         # 运行测试"
	@echo ""
	@echo "示例:"
	@echo "  make build && make start    # 构建并启动"
	@echo "  make logs                   # 查看日志"
	@echo "  make status                 # 查看状态"

# 基础命令
build: ## 构建 Docker 镜像
	@echo "🔨 构建 Docker 镜像..."
	docker-compose -f $(COMPOSE_FILE) build --no-cache
	@echo "✅ 镜像构建完成"

start: ## 启动服务
	@echo "🚀 启动服务..."
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "✅ 服务启动完成"
	@echo "🌐 访问地址: http://localhost"
	@echo "🌐 生产环境: https://318.yongli.wang"

stop: ## 停止服务
	@echo "🛑 停止服务..."
	docker-compose -f $(COMPOSE_FILE) down
	@echo "✅ 服务已停止"

restart: ## 重启服务
	@echo "🔄 重启服务..."
	docker-compose -f $(COMPOSE_FILE) restart
	@echo "✅ 服务已重启"

status: ## 查看服务状态
	@echo "📊 服务状态:"
	docker-compose -f $(COMPOSE_FILE) ps
	@echo ""
	@echo "📈 资源使用情况:"
	docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

logs: ## 查看服务日志
	@echo "📋 查看服务日志 (按 Ctrl+C 退出):"
	docker-compose -f $(COMPOSE_FILE) logs -f $(SERVICE_NAME)

# 环境命令
dev: ## 启动开发环境
	@echo "🛠️  启动开发环境..."
	docker-compose -f $(COMPOSE_FILE) -f docker-compose.dev.yml up -d
	@echo "✅ 开发环境启动完成"
	@echo "🌐 访问地址: http://localhost:3000"

prod: ## 启动生产环境
	@echo "🏭 启动生产环境..."
	docker-compose -f $(COMPOSE_FILE) -f docker-compose.prod.yml up -d
	@echo "✅ 生产环境启动完成"
	@echo "🌐 访问地址: http://localhost"

# 监控和测试
health: ## 健康检查
	@echo "🏥 执行健康检查..."
	@if curl -f http://localhost/health >/dev/null 2>&1; then \
		echo "✅ 健康检查通过"; \
		echo "🌐 网站正常运行: http://localhost"; \
	else \
		echo "❌ 健康检查失败"; \
		echo "📋 请查看日志: make logs"; \
	fi

test: ## 运行测试
	@echo "🧪 运行测试..."
	@echo "测试 HTTP 响应..."
	@curl -s -o /dev/null -w "HTTP状态码: %{http_code}\n响应时间: %{time_total}s\n" http://localhost/
	@echo "测试静态资源..."
	@curl -s -o /dev/null -w "CSS文件: %{http_code}\n" http://localhost/assets/css/style.css
	@curl -s -o /dev/null -w "JS文件: %{http_code}\n" http://localhost/assets/js/main.js
	@echo "✅ 测试完成"

# 维护命令
clean: ## 清理 Docker 资源
	@echo "🧹 清理 Docker 资源..."
	docker-compose -f $(COMPOSE_FILE) down -v
	docker system prune -f
	@echo "✅ 清理完成"

clean-all: ## 清理所有 Docker 资源
	@echo "🧹 清理所有 Docker 资源..."
	docker-compose -f $(COMPOSE_FILE) down -v --rmi all
	docker system prune -af
	@echo "✅ 全部清理完成"

# 日志管理
logs-nginx: ## 查看 Nginx 日志
	@echo "📋 查看 Nginx 日志:"
	docker-compose -f $(COMPOSE_FILE) logs -f $(SERVICE_NAME)

logs-access: ## 查看访问日志
	@echo "📋 查看访问日志:"
	tail -f logs/nginx/access.log

logs-error: ## 查看错误日志
	@echo "📋 查看错误日志:"
	tail -f logs/nginx/error.log

# 备份和恢复
backup: ## 备份配置和日志
	@echo "💾 备份配置和日志..."
	@mkdir -p backups/$(shell date +%Y%m%d_%H%M%S)
	@cp -r config backups/$(shell date +%Y%m%d_%H%M%S)/
	@cp -r logs backups/$(shell date +%Y%m%d_%H%M%S)/
	@echo "✅ 备份完成: backups/$(shell date +%Y%m%d_%H%M%S)/"

# 更新命令
update: ## 更新镜像并重启
	@echo "🔄 更新镜像..."
	docker-compose -f $(COMPOSE_FILE) pull
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "✅ 更新完成"

# 开发工具
shell: ## 进入容器 shell
	@echo "🐚 进入容器 shell..."
	docker exec -it $(PROJECT_NAME)-website sh

# 性能测试
benchmark: ## 性能测试
	@echo "⚡ 性能测试..."
	@if command -v ab >/dev/null 2>&1; then \
		ab -n 1000 -c 10 http://localhost/; \
	else \
		echo "❌ 需要安装 Apache Bench (ab) 工具"; \
		echo "Ubuntu/Debian: sudo apt-get install apache2-utils"; \
		echo "macOS: brew install httpd"; \
	fi

# 安全扫描
security: ## 安全扫描
	@echo "🔒 安全扫描..."
	@if command -v docker-bench-security >/dev/null 2>&1; then \
		docker-bench-security; \
	else \
		echo "❌ 需要安装 docker-bench-security"; \
		echo "安装命令: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock docker/docker-bench-security"; \
	fi
