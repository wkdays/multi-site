#!/bin/bash

# Docker挂载问题修复脚本
# 使用方法: ./scripts/fix-mount-issue.sh

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

print_message $BLUE "Docker挂载问题修复脚本"
print_message $BLUE "========================"

# 检查必要文件是否存在
print_message $BLUE "检查配置文件..."

# 检查nginx.conf
if [[ ! -f "nginx.conf" ]]; then
    print_message $RED "❌ nginx.conf 文件不存在"
    print_message $YELLOW "创建默认nginx.conf文件..."
    cat > nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /var/run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 16M;
    
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
    
    include /etc/nginx/conf.d/*.conf;
}
EOF
    print_message $GREEN "✅ 创建了默认nginx.conf文件"
else
    print_message $GREEN "✅ nginx.conf 文件存在"
fi

# 检查default.conf
if [[ ! -f "default.conf" ]]; then
    print_message $RED "❌ default.conf 文件不存在"
    print_message $YELLOW "创建默认default.conf文件..."
    cat > default.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html index.htm;
    
    server_tokens off;
    
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;
    
    location / {
        try_files $uri $uri/ /index.html;
        
        location ~* \.(html)$ {
            expires 1h;
            add_header Cache-Control "public, no-transform";
        }
    }
    
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary "Accept-Encoding";
        gzip_static on;
    }
    
    location ~* \.(png|jpg|jpeg|gif|webp)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        gzip_static on;
    }
    
    location ~* \.(woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Access-Control-Allow-Origin "*";
    }
    
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
    
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }
    
    location = /sitemap.xml {
        allow all;
        log_not_found off;
        access_log off;
    }
    
    location = /favicon.ico {
        log_not_found off;
        access_log off;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    error_page 404 /index.html;
    error_page 500 502 503 504 /50x.html;
    
    location = /50x.html {
        root /usr/share/nginx/html;
    }
    
    client_max_body_size 1M;
    client_body_timeout 12;
    client_header_timeout 12;
    keepalive_timeout 15;
    send_timeout 10;
}
EOF
    print_message $GREEN "✅ 创建了默认default.conf文件"
else
    print_message $GREEN "✅ default.conf 文件存在"
fi

# 创建日志目录
print_message $BLUE "创建日志目录..."
mkdir -p logs/nginx
print_message $GREEN "✅ 日志目录已创建"

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    print_message $RED "❌ Docker未安装，请先安装Docker"
    print_message $YELLOW "安装命令:"
    print_message $YELLOW "  Ubuntu/Debian: sudo apt-get update && sudo apt-get install docker.io docker-compose-plugin"
    print_message $YELLOW "  CentOS/RHEL: sudo yum install docker docker-compose-plugin"
    print_message $YELLOW "  macOS: brew install docker docker-compose"
    exit 1
fi

# 检查Docker Compose是否可用
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    print_message $RED "❌ Docker Compose未安装"
    print_message $YELLOW "请安装Docker Compose插件或独立版本"
    exit 1
fi

print_message $GREEN "✅ 使用命令: $COMPOSE_CMD"

# 停止现有容器
print_message $BLUE "停止现有容器..."
$COMPOSE_CMD down 2>/dev/null || true

# 清理Docker缓存
print_message $BLUE "清理Docker缓存..."
docker system prune -f 2>/dev/null || true

# 重新构建并启动
print_message $BLUE "重新构建并启动服务..."
$COMPOSE_CMD build --no-cache
$COMPOSE_CMD up -d

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
