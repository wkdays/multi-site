#!/bin/bash

# 检查现有Docker服务脚本
# 确保不影响现有nginx服务

echo "🔍 检查现有Docker服务..."

# 检查所有运行中的容器
echo "📋 当前运行中的容器:"
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'

echo ""
echo "📋 所有容器（包括停止的）:"
docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'

echo ""
echo "📋 检查nginx相关容器:"
docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' | grep -i nginx || echo "未发现nginx容器"

echo ""
echo "📋 检查端口占用:"
netstat -tulpn 2>/dev/null | grep -E ":80|:443|:8080" || echo "未发现相关端口占用"

echo ""
echo "📋 检查Docker镜像:"
docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}' | grep -E "nginx|datarecover" || echo "未发现相关镜像"

echo ""
echo "✅ 检查完成！"
echo "💡 建议：如果发现现有nginx服务，请确保使用不同的端口和容器名称"
