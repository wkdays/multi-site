#!/bin/bash

# Docker权限修复脚本
# 使用方法: ./scripts/fix-docker-permissions.sh

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

print_message $BLUE "Docker权限修复脚本"
print_message $BLUE "===================="

# 检查是否以root身份运行
if [[ $EUID -eq 0 ]]; then
    print_message $RED "❌ 请不要以root身份运行此脚本"
    print_message $YELLOW "请以普通用户身份运行，脚本会自动使用sudo"
    exit 1
fi

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    print_message $RED "❌ Docker未安装"
    print_message $YELLOW "正在安装Docker..."
    
    # 更新包列表
    sudo apt-get update
    
    # 安装Docker
    sudo apt-get install -y docker.io docker-compose-plugin
    
    # 启动Docker服务
    sudo systemctl start docker
    sudo systemctl enable docker
    
    print_message $GREEN "✅ Docker安装完成"
else
    print_message $GREEN "✅ Docker已安装"
fi

# 检查Docker服务状态
if ! sudo systemctl is-active --quiet docker; then
    print_message $YELLOW "启动Docker服务..."
    sudo systemctl start docker
    sudo systemctl enable docker
    print_message $GREEN "✅ Docker服务已启动"
fi

# 检查当前用户是否在docker组中
if ! groups $USER | grep -q '\bdocker\b'; then
    print_message $YELLOW "将用户 $USER 添加到docker组..."
    sudo usermod -aG docker $USER
    print_message $GREEN "✅ 用户已添加到docker组"
    
    print_message $YELLOW "⚠️  需要重新登录或运行 'newgrp docker' 使权限生效"
    print_message $BLUE "请选择以下操作之一："
    print_message $BLUE "1. 重新登录系统"
    print_message $BLUE "2. 运行: newgrp docker"
    print_message $BLUE "3. 重新启动终端"
    
    # 尝试使用newgrp
    print_message $YELLOW "尝试使用newgrp docker..."
    if newgrp docker; then
        print_message $GREEN "✅ 组权限已生效"
    else
        print_message $YELLOW "⚠️  newgrp失败，请重新登录或重启终端"
    fi
else
    print_message $GREEN "✅ 用户已在docker组中"
fi

# 测试Docker权限
print_message $BLUE "测试Docker权限..."
if docker ps &>/dev/null; then
    print_message $GREEN "✅ Docker权限正常"
else
    print_message $RED "❌ Docker权限仍有问题"
    print_message $YELLOW "请尝试以下解决方案："
    print_message $YELLOW "1. 重新登录系统"
    print_message $YELLOW "2. 重启终端"
    print_message $YELLOW "3. 运行: sudo chmod 666 /var/run/docker.sock (临时解决)"
    print_message $YELLOW "4. 检查Docker服务状态: sudo systemctl status docker"
    exit 1
fi

# 修复docker-compose.yml中的version警告
print_message $BLUE "修复docker-compose.yml配置..."

if [[ -f "docker-compose.yml" ]]; then
    # 备份原文件
    cp docker-compose.yml docker-compose.yml.backup
    
    # 移除version字段（Docker Compose V2不需要）
    if grep -q "^version:" docker-compose.yml; then
        sed -i '/^version:/d' docker-compose.yml
        print_message $GREEN "✅ 已移除过时的version字段"
    else
        print_message $GREEN "✅ version字段不存在，无需修复"
    fi
fi

# 测试Docker Compose
print_message $BLUE "测试Docker Compose..."

# 检查Docker Compose命令
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
    print_message $GREEN "✅ 使用Docker Compose V2: $COMPOSE_CMD"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
    print_message $GREEN "✅ 使用Docker Compose V1: $COMPOSE_CMD"
else
    print_message $RED "❌ Docker Compose未安装"
    print_message $YELLOW "安装Docker Compose..."
    sudo apt-get install -y docker-compose-plugin
    COMPOSE_CMD="docker compose"
fi

# 测试Docker Compose权限
if $COMPOSE_CMD ps &>/dev/null; then
    print_message $GREEN "✅ Docker Compose权限正常"
else
    print_message $RED "❌ Docker Compose权限有问题"
    print_message $YELLOW "请重新登录或重启终端后重试"
    exit 1
fi

print_message $GREEN "🎉 Docker权限修复完成！"
print_message $BLUE "现在可以运行以下命令："
print_message $BLUE "  $COMPOSE_CMD up -d    # 启动服务"
print_message $BLUE "  $COMPOSE_CMD logs     # 查看日志"
print_message $BLUE "  $COMPOSE_CMD ps       # 查看状态"
print_message $BLUE "  $COMPOSE_CMD down     # 停止服务"
