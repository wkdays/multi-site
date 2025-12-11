#!/bin/bash

# New-API 部署脚本

set -e

echo "🚀 开始部署 new-api 服务..."

# 检查 Docker 和 Docker Compose 是否已安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

# 确保目录权限正确
echo "📁 设置目录权限..."
chmod 755 .

# 启动 new-api 服务
echo "🏃‍♂️ 启动 new-api 服务..."
docker-compose up -d site-newapi

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
echo "🔍 检查服务状态..."
if docker-compose ps | grep -q "site-newapi.*Up"; then
    echo "✅ new-api 服务启动成功！"
    echo "🌐 访问地址: http://newapi.yongli.wang"
else
    echo "❌ new-api 服务启动失败，请检查日志："
    docker-compose logs site-newapi
    exit 1
fi

echo "🎉 部署完成！"