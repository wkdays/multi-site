#!/bin/bash

# 中晋数据科技 - Docker部署脚本
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
CONTAINER_NAME="zhongjin-datarecover"
IMAGE_NAME="datarecover-web"
PORT="8080"

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

# 检查Docker是否安装
check_docker() {
    print_message $BLUE "检查Docker环境..."
    
    if ! command -v docker &> /dev/null; then
        print_message $RED "❌ Docker未安装，请先安装Docker"
        print_message $YELLOW "安装指南: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_message $RED "❌ Docker Compose未安装，请先安装Docker Compose"
        print_message $YELLOW "安装指南: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    print_message $GREEN "✅ Docker环境检查通过"
}

# 检查Docker服务状态
check_docker_service() {
    print_message $BLUE "检查Docker服务状态..."
    
    if ! docker info &> /dev/null; then
        print_message $RED "❌ Docker服务未运行，请启动Docker服务"
        print_message $YELLOW "启动命令: sudo systemctl start docker (Linux) 或启动Docker Desktop"
        exit 1
    fi
    
    print_message $GREEN "✅ Docker服务运行正常"
}

# 构建Docker镜像
build_image() {
    print_title "构建Docker镜像"
    
    print_message $BLUE "开始构建镜像: $IMAGE_NAME"
    docker build -t $IMAGE_NAME:latest .
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ 镜像构建成功"
    else
        print_message $RED "❌ 镜像构建失败"
        exit 1
    fi
}

# 停止并删除旧容器
cleanup_old_container() {
    print_title "清理旧容器"
    
    if docker ps -a --format 'table {{.Names}}' | grep -q $CONTAINER_NAME; then
        print_message $YELLOW "发现旧容器，正在停止并删除..."
        docker stop $CONTAINER_NAME 2>/dev/null || true
        docker rm $CONTAINER_NAME 2>/dev/null || true
        print_message $GREEN "✅ 旧容器清理完成"
    else
        print_message $BLUE "未发现旧容器"
    fi
}

# 运行新容器
run_container() {
    print_title "启动新容器"
    
    print_message $BLUE "启动容器: $CONTAINER_NAME"
    print_message $YELLOW "端口映射: $PORT -> 80"
    
    docker run -d \
        --name $CONTAINER_NAME \
        --restart unless-stopped \
        -p $PORT:80 \
        $IMAGE_NAME:latest
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ 容器启动成功"
    else
        print_message $RED "❌ 容器启动失败"
        exit 1
    fi
}

# 检查容器状态
check_container_status() {
    print_title "检查容器状态"
    
    sleep 3
    
    if docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep -q $CONTAINER_NAME; then
        print_message $GREEN "✅ 容器运行正常"
        docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep $CONTAINER_NAME
    else
        print_message $RED "❌ 容器启动失败"
        print_message $YELLOW "查看容器日志:"
        docker logs $CONTAINER_NAME
        exit 1
    fi
}

# 健康检查
health_check() {
    print_title "健康检查"
    
    print_message $BLUE "等待服务启动..."
    sleep 5
    
    # 检查HTTP响应
    if curl -f -s http://localhost:$PORT/health > /dev/null; then
        print_message $GREEN "✅ 健康检查通过"
    else
        print_message $YELLOW "⚠️  健康检查失败，但服务可能仍在启动中"
    fi
    
    # 检查主页
    if curl -f -s http://localhost:$PORT/ > /dev/null; then
        print_message $GREEN "✅ 主页访问正常"
    else
        print_message $RED "❌ 主页访问失败"
        exit 1
    fi
}

# 显示访问信息
show_access_info() {
    print_title "部署完成"
    
    print_message $GREEN "🎉 $PROJECT_NAME 部署成功！"
    echo
    print_message $CYAN "访问地址:"
    print_message $YELLOW "  本地访问: http://localhost:$PORT"
    print_message $YELLOW "  网络访问: http://$(hostname -I | awk '{print $1}'):$PORT"
    echo
    print_message $CYAN "管理命令:"
    print_message $YELLOW "  查看日志: docker logs $CONTAINER_NAME"
    print_message $YELLOW "  进入容器: docker exec -it $CONTAINER_NAME sh"
    print_message $YELLOW "  停止服务: docker stop $CONTAINER_NAME"
    print_message $YELLOW "  重启服务: docker restart $CONTAINER_NAME"
    print_message $YELLOW "  删除容器: docker rm -f $CONTAINER_NAME"
    echo
    print_message $PURPLE "💡 提示: 使用 Ctrl+C 停止服务"
}

# 使用Docker Compose部署
deploy_with_compose() {
    print_title "使用Docker Compose部署"
    
    print_message $BLUE "启动服务栈..."
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ Docker Compose部署成功"
        print_message $CYAN "访问地址: http://localhost:8080"
        print_message $YELLOW "管理命令: docker-compose logs -f"
    else
        print_message $RED "❌ Docker Compose部署失败"
        exit 1
    fi
}

# 显示帮助信息
show_help() {
    echo -e "${CYAN}中晋数据科技 - Docker部署脚本${NC}"
    echo
    echo -e "${YELLOW}用法:${NC}"
    echo "  $0 [选项]"
    echo
    echo -e "${YELLOW}选项:${NC}"
    echo "  build     仅构建镜像"
    echo "  run       构建并运行容器"
    echo "  compose   使用Docker Compose部署"
    echo "  stop      停止容器"
    echo "  restart   重启容器"
    echo "  logs      查看日志"
    echo "  status    查看状态"
    echo "  clean     清理所有资源"
    echo "  help      显示帮助信息"
    echo
    echo -e "${YELLOW}示例:${NC}"
    echo "  $0 run        # 构建并运行"
    echo "  $0 compose    # 使用Compose部署"
    echo "  $0 logs       # 查看日志"
}

# 停止容器
stop_container() {
    print_title "停止容器"
    docker stop $CONTAINER_NAME 2>/dev/null || true
    print_message $GREEN "✅ 容器已停止"
}

# 重启容器
restart_container() {
    print_title "重启容器"
    docker restart $CONTAINER_NAME
    print_message $GREEN "✅ 容器已重启"
}

# 查看日志
show_logs() {
    print_title "容器日志"
    docker logs -f $CONTAINER_NAME
}

# 查看状态
show_status() {
    print_title "容器状态"
    docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep $CONTAINER_NAME || echo "容器不存在"
}

# 清理资源
clean_resources() {
    print_title "清理资源"
    
    print_message $YELLOW "停止并删除容器..."
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
    
    print_message $YELLOW "删除镜像..."
    docker rmi $IMAGE_NAME:latest 2>/dev/null || true
    
    print_message $GREEN "✅ 资源清理完成"
}

# 主函数
main() {
    case "${1:-run}" in
        "build")
            check_docker
            check_docker_service
            build_image
            ;;
        "run")
            check_docker
            check_docker_service
            build_image
            cleanup_old_container
            run_container
            check_container_status
            health_check
            show_access_info
            ;;
        "compose")
            check_docker
            check_docker_service
            deploy_with_compose
            ;;
        "stop")
            stop_container
            ;;
        "restart")
            restart_container
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
