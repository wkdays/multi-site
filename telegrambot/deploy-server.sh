#!/bin/bash

# 云服务器 Docker 部署脚本
# 使用方法: ./deploy-server.sh [server_ip] [bot_token]

set -e

SERVER_IP=${1:-"43.156.45.230"}
BOT_TOKEN=${2:-""}
PROJECT_DIR="/opt/telegram-bot"

echo "🚀 开始部署到云服务器: $SERVER_IP"

# 检查参数
if [ -z "$BOT_TOKEN" ]; then
    echo "❌ 错误: 请提供 Bot Token"
    echo "使用方法: ./deploy-server.sh [server_ip] [bot_token]"
    echo "示例: ./deploy-server.sh 43.156.45.230 your_bot_token_here"
    exit 1
fi

echo "📦 步骤 1: 上传代码到服务器..."
# 创建项目目录
ssh root@$SERVER_IP "mkdir -p $PROJECT_DIR"

# 上传代码（排除 node_modules 和 .git）
rsync -av --exclude 'node_modules' --exclude '.git' --exclude '.env' \
    /Users/yongli/Documents/git/telegrambot/ root@$SERVER_IP:$PROJECT_DIR/

echo "🔧 步骤 2: 在服务器上安装 Docker..."
ssh root@$SERVER_IP << 'EOF'
    # 更新系统
    apt update && apt upgrade -y
    
    # 安装 Docker（如果未安装）
    if ! command -v docker &> /dev/null; then
        echo "安装 Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        systemctl start docker
        systemctl enable docker
    fi
    
    # 安装 Docker Compose（如果未安装）
    if ! command -v docker-compose &> /dev/null; then
        echo "安装 Docker Compose..."
        apt install docker-compose -y
    fi
    
    echo "Docker 版本: $(docker --version)"
    echo "Docker Compose 版本: $(docker-compose --version)"
EOF

echo "⚙️ 步骤 3: 配置环境变量..."
ssh root@$SERVER_IP << EOF
    cd $PROJECT_DIR
    
    # 创建环境变量文件
    cat > .env << 'ENVEOF'
# Telegram Bot Token
BOT_TOKEN=$BOT_TOKEN

# DeepL API Key
DEEPL_API_KEY=6ceb6e86-9ae9-432e-b27f-9aeef851fb63:fx

# 其他环境变量
NODE_ENV=production
PORT=3000
ENVEOF
    
    echo "✅ 环境变量配置完成"
EOF

echo "🐳 步骤 4: 构建和启动 Docker 服务..."
ssh root@$SERVER_IP << EOF
    cd $PROJECT_DIR
    
    # 停止现有容器
    docker-compose down 2>/dev/null || true
    
    # 构建镜像
    echo "构建 Docker 镜像..."
    docker-compose build
    
    # 启动服务
    echo "启动服务..."
    docker-compose up -d
    
    # 等待服务启动
    sleep 10
    
    # 检查服务状态
    echo "服务状态:"
    docker-compose ps
    
    # 检查日志
    echo "最近的日志:"
    docker-compose logs --tail=20
EOF

echo "🔥 步骤 5: 配置防火墙..."
ssh root@$SERVER_IP << 'EOF'
    # 开放端口 3000
    ufw allow 3000 2>/dev/null || iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
    
    echo "✅ 防火墙配置完成"
EOF

echo "🧪 步骤 6: 验证部署..."
ssh root@$SERVER_IP << EOF
    cd $PROJECT_DIR
    
    # 检查容器状态
    echo "容器状态:"
    docker ps | grep telegram
    
    # 检查健康状态
    echo "健康检查:"
    sleep 5
    curl -s http://localhost:3000/health || echo "健康检查失败"
EOF

echo "🎉 部署完成！"
echo ""
echo "📋 部署信息:"
echo "   服务器: $SERVER_IP"
echo "   项目目录: $PROJECT_DIR"
echo "   服务端口: 3000"
echo "   健康检查: http://$SERVER_IP:3000/health"
echo ""
echo "🔧 管理命令:"
echo "   查看日志: ssh root@$SERVER_IP 'cd $PROJECT_DIR && docker-compose logs -f'"
echo "   重启服务: ssh root@$SERVER_IP 'cd $PROJECT_DIR && docker-compose restart'"
echo "   停止服务: ssh root@$SERVER_IP 'cd $PROJECT_DIR && docker-compose down'"
echo "   查看状态: ssh root@$SERVER_IP 'cd $PROJECT_DIR && docker-compose ps'"
echo ""
echo "✅ 机器人已部署并运行！"

