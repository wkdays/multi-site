#!/bin/bash

# 停止 Telegram Bot 进程脚本
echo "🛑 正在停止所有 Telegram Bot 进程..."

# 查找并停止所有运行中的 bot.js 进程
BOT_PIDS=$(pgrep -f "node.*bot.js" 2>/dev/null)

if [ -z "$BOT_PIDS" ]; then
    echo "✅ 没有发现运行中的 Telegram Bot 进程"
else
    echo "🔍 发现以下 Telegram Bot 进程:"
    ps -p $BOT_PIDS -o pid,ppid,cmd
    
    echo "🛑 正在停止进程..."
    for pid in $BOT_PIDS; do
        echo "   停止进程 $pid..."
        kill -TERM $pid 2>/dev/null
    done
    
    # 等待进程优雅退出
    sleep 3
    
    # 检查是否还有进程在运行
    REMAINING_PIDS=$(pgrep -f "node.*bot.js" 2>/dev/null)
    if [ ! -z "$REMAINING_PIDS" ]; then
        echo "⚠️  部分进程仍在运行，强制终止..."
        for pid in $REMAINING_PIDS; do
            echo "   强制终止进程 $pid..."
            kill -KILL $pid 2>/dev/null
        done
    fi
    
    echo "✅ 所有 Telegram Bot 进程已停止"
fi

# 如果使用 Docker，也停止相关容器
if command -v docker &> /dev/null; then
    echo "🐳 检查 Docker 容器..."
    CONTAINERS=$(docker ps -q --filter "name=telegram" 2>/dev/null)
    if [ ! -z "$CONTAINERS" ]; then
        echo "🛑 停止 Docker 容器..."
        docker stop $CONTAINERS
        echo "✅ Docker 容器已停止"
    fi
fi

echo "🎉 清理完成！现在可以安全启动新的机器人实例。"
