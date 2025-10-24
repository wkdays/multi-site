#!/bin/bash

# 中晋数据科技 - 外网域名部署脚本
# 域名: dt.yongli.wang
# 作者: 中晋数据科技
# 版本: 1.0.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 项目信息
PROJECT_NAME="中晋数据科技数据恢复网站"
DOMAIN="dt.yongli.wang"
CONTAINER_NAME="zhongjin-datarecover"
PROXY_CONTAINER="datarecover-proxy"
IMAGE_NAME="zhongjin-datarecover-web"  # 使用更独特的镜像名
PORT="8080"  # 使用8080端口，避免与现有nginx冲突

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 打印标题
print_title() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}================================${NC}"
}

# 检查Docker环境
check_docker() {
    print_message $BLUE "检查Docker环境..."
    
    if ! command -v docker &> /dev/null; then
        print_message $RED "❌ Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_message $RED "❌ Docker Compose未安装，请先安装Docker Compose"
        exit 1
    fi
    
    print_message $GREEN "✅ Docker环境检查通过"
}

# 检查现有镜像（保护现有镜像）
check_existing_images() {
    print_title "检查现有Docker镜像"
    
    print_message $BLUE "检查现有镜像，确保不影响您的其他服务..."
    
    # 列出所有镜像
    EXISTING_IMAGES=$(docker images --format "table {{.Repository}}:{{.Tag}}" | tail -n +2)
    
    if [ -n "$EXISTING_IMAGES" ]; then
        print_message $YELLOW "发现现有镜像:"
        echo "$EXISTING_IMAGES"
        print_message $GREEN "✅ 将使用独立容器名称，不会影响现有镜像"
    else
        print_message $BLUE "未发现现有镜像"
    fi
    
    # 检查端口占用
    if netstat -tulpn 2>/dev/null | grep -q ":80\|:443"; then
        print_message $YELLOW "⚠️  检测到80/443端口被占用（可能是您现有的nginx服务）"
        print_message $YELLOW "✅ 将使用8080端口，不会影响现有服务"
    fi
    
    # 检查现有nginx容器
    if docker ps --format 'table {{.Names}}' | grep -i nginx; then
        print_message $YELLOW "⚠️  发现现有nginx容器正在运行"
        print_message $GREEN "✅ 将使用不同的容器名称，不会影响现有nginx服务"
    fi
}

# 生成SSL证书
setup_ssl() {
    print_title "配置SSL证书"
    
    print_message $BLUE "为域名 $DOMAIN 配置SSL证书..."
    
    # 检查SSL证书是否存在
    if [ -f "./proxy/ssl/cert.pem" ] && [ -f "./proxy/ssl/key.pem" ]; then
        print_message $GREEN "✅ SSL证书已存在"
        return 0
    fi
    
    # 运行SSL设置脚本
    if [ -f "./ssl-setup.sh" ]; then
        print_message $BLUE "运行SSL证书生成脚本..."
        ./ssl-setup.sh self
    else
        print_message $YELLOW "⚠️  SSL设置脚本不存在，将创建自签名证书..."
        
        # 创建SSL目录
        mkdir -p ./proxy/ssl
        
        # 生成自签名证书
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout ./proxy/ssl/key.pem \
            -out ./proxy/ssl/cert.pem \
            -subj "/C=CN/ST=Shanghai/L=Shanghai/O=中晋数据科技/CN=$DOMAIN"
        
        print_message $GREEN "✅ 自签名证书生成完成"
    fi
}

# 构建网站镜像
build_website_image() {
    print_title "构建网站镜像"
    
    print_message $BLUE "构建网站Docker镜像..."
    docker build -t $IMAGE_NAME:latest .
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ 网站镜像构建成功"
    else
        print_message $RED "❌ 网站镜像构建失败"
        exit 1
    fi
}

# 停止旧容器（仅停止本项目容器）
cleanup_old_containers() {
    print_title "清理旧容器"
    
    # 只停止和删除本项目相关的容器
    if docker ps -a --format 'table {{.Names}}' | grep -q $CONTAINER_NAME; then
        print_message $YELLOW "停止旧网站容器..."
        docker stop $CONTAINER_NAME 2>/dev/null || true
        docker rm $CONTAINER_NAME 2>/dev/null || true
    fi
    
    if docker ps -a --format 'table {{.Names}}' | grep -q $PROXY_CONTAINER; then
        print_message $YELLOW "停止旧代理容器..."
        docker stop $PROXY_CONTAINER 2>/dev/null || true
        docker rm $PROXY_CONTAINER 2>/dev/null || true
    fi
    
    print_message $GREEN "✅ 旧容器清理完成"
}

# 启动网站服务
start_website() {
    print_title "启动网站服务"
    
    print_message $BLUE "启动网站容器..."
    docker run -d \
        --name $CONTAINER_NAME \
        --restart unless-stopped \
        -p $PORT:80 \
        $IMAGE_NAME:latest
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ 网站容器启动成功"
    else
        print_message $RED "❌ 网站容器启动失败"
        exit 1
    fi
}

# 启动反向代理
start_proxy() {
    print_title "启动反向代理"
    
    print_message $BLUE "启动Nginx反向代理..."
    docker run -d \
        --name $PROXY_CONTAINER \
        --restart unless-stopped \
        -p 80:80 \
        -p 443:443 \
        -v $(pwd)/proxy/nginx.conf:/etc/nginx/nginx.conf:ro \
        -v $(pwd)/proxy/ssl:/etc/nginx/ssl:ro \
        --link $CONTAINER_NAME:datarecover-web \
        nginx:alpine
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ 反向代理启动成功"
    else
        print_message $RED "❌ 反向代理启动失败"
        exit 1
    fi
}

# 检查服务状态
check_services() {
    print_title "检查服务状态"
    
    sleep 5
    
    print_message $BLUE "检查容器状态..."
    docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep -E "($CONTAINER_NAME|$PROXY_CONTAINER)"
    
    # 检查网站服务
    if curl -f -s http://localhost:$PORT/ > /dev/null; then
        print_message $GREEN "✅ 网站服务正常"
    else
        print_message $RED "❌ 网站服务异常"
        docker logs $CONTAINER_NAME
        exit 1
    fi
    
    # 检查代理服务
    if curl -f -s http://localhost/ > /dev/null; then
        print_message $GREEN "✅ 反向代理正常"
    else
        print_message $YELLOW "⚠️  反向代理可能仍在启动中"
    fi
}

# 显示访问信息
show_access_info() {
    print_title "部署完成"
    
    print_message $GREEN "🎉 $PROJECT_NAME 外网部署成功！"
    echo
    print_message $CYAN "访问地址:"
    print_message $YELLOW "  域名访问: https://$DOMAIN"
    print_message $YELLOW "  本地访问: http://localhost"
    print_message $YELLOW "  直接访问: http://localhost:$PORT"
    echo
    print_message $CYAN "管理命令:"
    print_message $YELLOW "  查看网站日志: docker logs $CONTAINER_NAME"
    print_message $YELLOW "  查看代理日志: docker logs $PROXY_CONTAINER"
    print_message $YELLOW "  停止服务: docker stop $CONTAINER_NAME $PROXY_CONTAINER"
    print_message $YELLOW "  重启服务: docker restart $CONTAINER_NAME $PROXY_CONTAINER"
    print_message $YELLOW "  删除服务: docker rm -f $CONTAINER_NAME $PROXY_CONTAINER"
    echo
    print_message $PURPLE "💡 提示: 确保域名 $DOMAIN 已解析到服务器IP地址"
    print_message $PURPLE "💡 提示: 如需更新SSL证书，请运行 ./ssl-setup.sh letsencrypt"
}

# 使用Docker Compose部署
deploy_with_compose() {
    print_title "使用Docker Compose部署"
    
    print_message $BLUE "启动完整服务栈..."
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ Docker Compose部署成功"
        print_message $CYAN "访问地址: https://$DOMAIN"
    else
        print_message $RED "❌ Docker Compose部署失败"
        exit 1
    fi
}

# 显示帮助信息
show_help() {
    echo -e "${CYAN}中晋数据科技 - 外网域名部署脚本${NC}"
    echo
    echo -e "${YELLOW}用法:${NC}"
    echo "  $0 [选项]"
    echo
    echo -e "${YELLOW}选项:${NC}"
    echo "  manual     手动部署（默认，逐步执行）"
    echo "  compose    使用Docker Compose部署"
    echo "  ssl        仅配置SSL证书"
    echo "  stop       停止所有服务"
    echo "  restart    重启所有服务"
    echo "  logs       查看所有日志"
    echo "  status     查看服务状态"
    echo "  clean      清理所有资源"
    echo "  help       显示帮助信息"
    echo
    echo -e "${YELLOW}示例:${NC}"
    echo "  $0 manual     # 手动部署"
    echo "  $0 compose    # Compose部署"
    echo "  $0 ssl        # 配置SSL"
    echo "  $0 logs       # 查看日志"
}

# 停止所有服务
stop_services() {
    print_title "停止所有服务"
    
    docker stop $CONTAINER_NAME $PROXY_CONTAINER 2>/dev/null || true
    print_message $GREEN "✅ 所有服务已停止"
}

# 重启所有服务
restart_services() {
    print_title "重启所有服务"
    
    docker restart $CONTAINER_NAME $PROXY_CONTAINER
    print_message $GREEN "✅ 所有服务已重启"
}

# 查看日志
show_logs() {
    print_title "服务日志"
    
    print_message $BLUE "网站服务日志:"
    docker logs --tail 50 $CONTAINER_NAME
    echo
    print_message $BLUE "代理服务日志:"
    docker logs --tail 50 $PROXY_CONTAINER
}

# 查看状态
show_status() {
    print_title "服务状态"
    
    docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep -E "($CONTAINER_NAME|$PROXY_CONTAINER)" || echo "服务不存在"
}

# 清理资源
clean_resources() {
    print_title "清理资源"
    
    print_message $YELLOW "停止并删除容器..."
    docker stop $CONTAINER_NAME $PROXY_CONTAINER 2>/dev/null || true
    docker rm $CONTAINER_NAME $PROXY_CONTAINER 2>/dev/null || true
    
    print_message $YELLOW "删除镜像..."
    docker rmi $IMAGE_NAME:latest 2>/dev/null || true
    
    print_message $GREEN "✅ 资源清理完成"
}

# 主函数
main() {
    case "${1:-manual}" in
        "manual")
            check_docker
            check_existing_images
            setup_ssl
            build_website_image
            cleanup_old_containers
            start_website
            start_proxy
            check_services
            show_access_info
            ;;
        "compose")
            check_docker
            check_existing_images
            setup_ssl
            deploy_with_compose
            show_access_info
            ;;
        "ssl")
            setup_ssl
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            restart_services
            ;;
        "logs")
            show_logs
            ;;
        "status")
            show_status
            ;;
        "clean")
            clean_resources
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_message $RED "❌ 未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"


