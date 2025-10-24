#!/bin/bash

# SSL 证书设置脚本
# 使用方法: ./scripts/ssl-setup.sh [选项]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
DOMAIN="318.yongli.wang"
EMAIL="admin@yongli.wang"
PROJECT_NAME="xinduqiao-travel"

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 检查域名解析
check_dns() {
    print_message $BLUE "检查域名解析..."
    
    local ip=$(dig +short "$DOMAIN" | head -1)
    if [[ -z "$ip" ]]; then
        print_message $RED "❌ 域名 $DOMAIN 无法解析"
        return 1
    fi
    
    print_message $GREEN "✅ 域名解析正常: $DOMAIN -> $ip"
    return 0
}

# 检查端口开放
check_ports() {
    print_message $BLUE "检查端口开放..."
    
    # 检查 80 端口
    if netstat -tuln | grep -q ":80 "; then
        print_message $GREEN "✅ 端口 80 已开放"
    else
        print_message $RED "❌ 端口 80 未开放"
        return 1
    fi
    
    # 检查 443 端口
    if netstat -tuln | grep -q ":443 "; then
        print_message $GREEN "✅ 端口 443 已开放"
    else
        print_message $YELLOW "⚠️  端口 443 未开放（HTTPS 需要）"
    fi
    
    return 0
}

# 使用 Let's Encrypt 申请证书
setup_letsencrypt() {
    print_message $BLUE "设置 Let's Encrypt 证书..."
    
    # 创建证书目录
    mkdir -p traefik/letsencrypt
    
    # 设置权限
    chmod 600 traefik/letsencrypt
    
    # 创建 acme.json 文件
    touch traefik/letsencrypt/acme.json
    chmod 600 traefik/letsencrypt/acme.json
    
    print_message $GREEN "✅ Let's Encrypt 配置完成"
    print_message $YELLOW "📝 请确保："
    print_message $YELLOW "   1. 域名 $DOMAIN 已正确解析到服务器"
    print_message $YELLOW "   2. 端口 80 和 443 已开放"
    print_message $YELLOW "   3. 防火墙允许 HTTP/HTTPS 流量"
}

# 使用 Traefik 自动 HTTPS
setup_traefik_https() {
    print_message $BLUE "设置 Traefik 自动 HTTPS..."
    
    # 检查 Traefik 配置
    if [[ ! -f "traefik/traefik.yml" ]]; then
        print_message $RED "❌ Traefik 配置文件不存在"
        return 1
    fi
    
    # 启动 Traefik 服务
    print_message $BLUE "启动 Traefik 服务..."
    docker-compose -f docker-compose.yml -f docker-compose.traefik.yml up -d traefik
    
    # 等待 Traefik 启动
    sleep 10
    
    # 启动主服务
    print_message $BLUE "启动主服务..."
    docker-compose -f docker-compose.yml -f docker-compose.traefik.yml up -d
    
    print_message $GREEN "✅ Traefik HTTPS 设置完成"
    print_message $YELLOW "🌐 访问地址: https://$DOMAIN"
    print_message $YELLOW "📊 Traefik 仪表板: http://localhost:8080"
}

# 手动申请证书
manual_cert() {
    print_message $BLUE "手动申请 SSL 证书..."
    
    # 检查 certbot 是否安装
    if ! command -v certbot &> /dev/null; then
        print_message $YELLOW "安装 certbot..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y certbot
        elif command -v yum &> /dev/null; then
            sudo yum install -y certbot
        elif command -v brew &> /dev/null; then
            brew install certbot
        else
            print_message $RED "❌ 无法安装 certbot，请手动安装"
            return 1
        fi
    fi
    
    # 申请证书
    print_message $BLUE "申请证书..."
    sudo certbot certonly --standalone -d "$DOMAIN" --email "$EMAIL" --agree-tos --non-interactive
    
    # 检查证书
    if [[ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]]; then
        print_message $GREEN "✅ 证书申请成功"
        
        # 复制证书到项目目录
        mkdir -p ssl
        sudo cp "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ssl/
        sudo cp "/etc/letsencrypt/live/$DOMAIN/privkey.pem" ssl/
        sudo chown $USER:$USER ssl/*
        
        print_message $GREEN "✅ 证书已复制到 ssl/ 目录"
    else
        print_message $RED "❌ 证书申请失败"
        return 1
    fi
}

# 配置 Nginx SSL
configure_nginx_ssl() {
    print_message $BLUE "配置 Nginx SSL..."
    
    # 创建 SSL 配置
    cat > config/ssl.conf << EOF
# SSL 配置
server {
    listen 443 ssl http2;
    server_name $DOMAIN;
    root /usr/share/nginx/html;
    index index.html index.htm;
    
    # SSL 证书配置
    ssl_certificate /etc/ssl/certs/fullchain.pem;
    ssl_certificate_key /etc/ssl/private/privkey.pem;
    
    # SSL 安全配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # 安全头
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # 基础路由
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    # 静态资源缓存
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # 健康检查
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}

# HTTP 重定向到 HTTPS
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$server_name\$request_uri;
}
EOF
    
    print_message $GREEN "✅ Nginx SSL 配置完成"
}

# 测试 SSL 证书
test_ssl() {
    print_message $BLUE "测试 SSL 证书..."
    
    # 测试 HTTPS 连接
    if curl -f "https://$DOMAIN/health" >/dev/null 2>&1; then
        print_message $GREEN "✅ HTTPS 连接正常"
    else
        print_message $RED "❌ HTTPS 连接失败"
        return 1
    fi
    
    # 检查证书信息
    print_message $BLUE "证书信息:"
    echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null | openssl x509 -noout -dates
    
    return 0
}

# 设置自动续期
setup_auto_renewal() {
    print_message $BLUE "设置证书自动续期..."
    
    # 创建续期脚本
    cat > scripts/renew-ssl.sh << 'EOF'
#!/bin/bash
# SSL 证书自动续期脚本

DOMAIN="318.yongli.wang"
PROJECT_NAME="xinduqiao-travel"

# 续期证书
certbot renew --quiet

# 检查是否需要重启服务
if [[ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]]; then
    # 复制新证书
    cp "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ssl/
    cp "/etc/letsencrypt/live/$DOMAIN/privkey.pem" ssl/
    
    # 重启服务
    docker-compose restart $PROJECT_NAME
    
    echo "$(date): SSL certificate renewed" >> logs/ssl-renewal.log
fi
EOF
    
    chmod +x scripts/renew-ssl.sh
    
    # 添加到 crontab
    (crontab -l 2>/dev/null; echo "0 2 * * * $(pwd)/scripts/renew-ssl.sh") | crontab -
    
    print_message $GREEN "✅ 自动续期设置完成"
    print_message $YELLOW "📝 证书将在每天凌晨 2 点自动检查续期"
}

# 显示帮助信息
show_help() {
    echo "SSL 证书设置脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [选项]"
    echo ""
    echo "选项:"
    echo "  check              检查域名和端口"
    echo "  traefik            使用 Traefik 自动 HTTPS"
    echo "  manual             手动申请证书"
    echo "  nginx              配置 Nginx SSL"
    echo "  test               测试 SSL 证书"
    echo "  renew              设置自动续期"
    echo "  all                执行所有步骤"
    echo "  help               显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 check            # 检查域名解析"
    echo "  $0 traefik          # 使用 Traefik 自动 HTTPS"
    echo "  $0 all              # 执行完整 SSL 设置"
}

# 主函数
main() {
    local action=${1:-help}
    
    print_message $BLUE "SSL 证书设置脚本"
    print_message $BLUE "=================="
    
    case $action in
        "check")
            check_dns
            check_ports
            ;;
        "traefik")
            check_dns
            setup_letsencrypt
            setup_traefik_https
            ;;
        "manual")
            check_dns
            check_ports
            manual_cert
            configure_nginx_ssl
            ;;
        "nginx")
            configure_nginx_ssl
            ;;
        "test")
            test_ssl
            ;;
        "renew")
            setup_auto_renewal
            ;;
        "all")
            check_dns
            check_ports
            setup_letsencrypt
            setup_traefik_https
            test_ssl
            setup_auto_renewal
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_message $RED "错误: 未知选项 '$action'"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
