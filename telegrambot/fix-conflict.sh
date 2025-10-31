#!/bin/bash

# Telegram Bot 冲突修复脚本
echo "🔧 修复 Telegram Bot 冲突问题..."

# 1. 停止所有现有进程
echo "🛑 步骤 1: 停止所有现有机器人进程..."
./stop-bot.sh

# 2. 等待几秒钟
echo "⏳ 步骤 2: 等待 5 秒..."
sleep 5

# 3. 检查环境变量
echo "🔍 步骤 3: 检查环境变量..."
if [ ! -f ".env" ]; then
    echo "❌ .env 文件不存在，正在创建..."
    cp env.example .env
    echo "⚠️  请编辑 .env 文件并设置正确的 BOT_TOKEN 和 DEEPL_API_KEY"
    echo "   然后重新运行此脚本"
    exit 1
fi

# 加载环境变量
source .env

if [ -z "$BOT_TOKEN" ] || [ "$BOT_TOKEN" = "your_bot_token_here" ]; then
    echo "❌ BOT_TOKEN 未正确设置"
    exit 1
fi

if [ -z "$DEEPL_API_KEY" ] || [ "$DEEPL_API_KEY" = "your_deepl_api_key_here" ]; then
    echo "❌ DEEPL_API_KEY 未正确设置"
    exit 1
fi

echo "✅ 环境变量检查通过"

# 4. 测试功能
echo "🧪 步骤 4: 测试机器人功能..."
if node test-bot.js; then
    echo "✅ 功能测试通过"
else
    echo "❌ 功能测试失败"
    exit 1
fi

# 5. 启动机器人
echo "🚀 步骤 5: 启动机器人..."
echo "   使用以下命令启动:"
echo "   npm start"
echo ""
echo "   或使用 Docker:"
echo "   docker-compose up -d"
echo ""
echo "   或使用 systemd:"
echo "   sudo systemctl start telegram-bot"

echo "🎉 修复完成！现在可以安全启动机器人了。"
