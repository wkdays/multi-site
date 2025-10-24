#!/bin/bash

# Docker构建问题修复脚本
# 使用方法: ./scripts/fix-docker-build.sh

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

print_message $BLUE "Docker构建问题修复脚本"
print_message $BLUE "========================"

# 清理Docker缓存
print_message $BLUE "清理Docker构建缓存..."
docker builder prune -f
docker system prune -f

# 清理可能存在的镜像
print_message $BLUE "清理相关镜像..."
docker rmi $(docker images | grep "xinduqiao-travel" | awk '{print $3}') 2>/dev/null || true

# 重新构建镜像
print_message $BLUE "重新构建Docker镜像..."
docker-compose build --no-cache --pull

# 启动服务
print_message $BLUE "启动服务..."
docker-compose up -d

# 健康检查
print_message $BLUE "执行健康检查..."
sleep 10

if curl -f http://localhost/health >/dev/null 2>&1; then
    print_message $GREEN "✅ 修复成功！服务正常运行"
    print_message $GREEN "🌐 访问地址: http://localhost"
else
    print_message $RED "❌ 修复失败，请检查日志"
    print_message $YELLOW "查看日志: docker-compose logs"
fi
