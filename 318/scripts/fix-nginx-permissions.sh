#!/bin/bash

# Nginx权限问题修复脚本
# 使用方法: ./scripts/fix-nginx-permissions.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_message $BLUE "Nginx权限问题修复脚本"
print_message $BLUE "======================="

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    print_message $RED "❌ Docker未安装"
    exit 1
fi

# 检查Docker Compose是否可用
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    print_message $RED "❌ Docker Compose未安装"
    exit 1
fi

print_message $GREEN "✅ 使用命令: $COMPOSE_CMD"

# 停止现有容器
print_message $BLUE "停止现有容器..."
$COMPOSE_CMD down 2>/dev/null || true

# 清理Docker缓存和镜像
print_message $BLUE "清理Docker缓存..."
docker system prune -f 2>/dev/null || true

# 删除相关镜像
print_message $BLUE "删除相关镜像..."
docker rmi $(docker images | grep "xinduqiao-travel" | awk '{print $3}') 2>/dev/null || true

# 重新构建镜像
print_message $BLUE "重新构建镜像..."
if $COMPOSE_CMD build --no-cache --pull; then
    print_message $GREEN "✅ 镜像构建完成"
else
    print_message $RED "❌ 镜像构建失败"
    exit 1
fi

# 启动服务
print_message $BLUE "启动服务..."
if $COMPOSE_CMD up -d; then
    print_message $GREEN "✅ 服务启动成功"
else
    print_message $RED "❌ 服务启动失败"
    exit 1
fi

# 等待服务启动
print_message $BLUE "等待服务启动..."
sleep 10

# 检查容器状态
print_message $BLUE "检查容器状态..."
if $COMPOSE_CMD ps | grep -q "Up"; then
    print_message $GREEN "✅ 容器运行正常"
else
    print_message $RED "❌ 容器启动失败"
    print_message $YELLOW "查看日志:"
    $COMPOSE_CMD logs
    exit 1
fi

# 测试健康检查
print_message $BLUE "测试健康检查..."
if curl -f http://localhost/health >/dev/null 2>&1; then
    print_message $GREEN "✅ 健康检查通过"
else
    print_message $YELLOW "⚠️  健康检查失败，但服务可能仍在运行"
fi

# 测试网站访问
print_message $BLUE "测试网站访问..."
if curl -f http://localhost >/dev/null 2>&1; then
    print_message $GREEN "✅ 网站访问正常"
    print_message $GREEN "🌐 访问地址: http://localhost"
else
    print_message $YELLOW "⚠️  网站访问可能有问题"
fi

# 显示容器日志
print_message $BLUE "显示最近的日志:"
$COMPOSE_CMD logs --tail=20

print_message $GREEN "🎉 Nginx权限问题修复完成！"
print_message $BLUE "如果仍有问题，请检查日志: $COMPOSE_CMD logs"
