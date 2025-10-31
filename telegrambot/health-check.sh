#!/bin/bash

# Telegram Bot 健康检查脚本
echo "🏥 Telegram Bot 健康检查..."

# 检查进程是否运行
BOT_PIDS=$(pgrep -f "node.*bot.js" 2>/dev/null)
if [ -z "$BOT_PIDS" ]; then
    echo "❌ 机器人进程未运行"
    exit 1
else
    echo "✅ 机器人进程运行中 (PID: $BOT_PIDS)"
fi

# 检查 HTTP 健康检查端点
HEALTH_URL="http://localhost:3000/health"
if command -v curl &> /dev/null; then
    echo "🔍 检查 HTTP 健康状态..."
    HEALTH_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/health_response.json "$HEALTH_URL" 2>/dev/null)
    
    if [ "$HEALTH_RESPONSE" = "200" ]; then
        echo "✅ HTTP 健康检查通过"
        echo "📊 服务状态:"
        cat /tmp/health_response.json | python3 -m json.tool 2>/dev/null || cat /tmp/health_response.json
    else
        echo "❌ HTTP 健康检查失败 (状态码: $HEALTH_RESPONSE)"
        exit 1
    fi
else
    echo "⚠️  curl 未安装，跳过 HTTP 健康检查"
fi

# 检查端口占用
echo "🔍 检查端口占用..."
if netstat -tuln 2>/dev/null | grep -q ":3000 "; then
    echo "✅ 端口 3000 正在监听"
else
    echo "❌ 端口 3000 未监听"
    exit 1
fi

# 检查环境变量
echo "🔍 检查环境变量..."
if [ -z "$BOT_TOKEN" ]; then
    echo "❌ BOT_TOKEN 环境变量未设置"
    exit 1
else
    echo "✅ BOT_TOKEN 已设置"
fi

if [ -z "$DEEPL_API_KEY" ]; then
    echo "❌ DEEPL_API_KEY 环境变量未设置"
    exit 1
else
    echo "✅ DEEPL_API_KEY 已设置"
fi

# 检查日志文件
echo "🔍 检查最近的日志..."
if [ -f "logs/app.log" ]; then
    echo "📋 最近的错误日志:"
    tail -n 5 logs/app.log | grep -i error || echo "   无错误日志"
else
    echo "⚠️  日志文件不存在"
fi

echo "🎉 健康检查完成！机器人运行正常。"
