#!/bin/bash

# 新都桥旅行网站 Docker 部署脚本
# 使用方法: ./deploy.sh [选项]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
COMPOSE_FILE="$COMPOSE_CMD.yml"
SERVICE_NAME="xinduqiao-travel"
PROJECT_NAME="xinduqiao-travel"

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_message $RED "错误: Docker 未安装，请先安装 Docker"
        print_message $YELLOW "安装命令:"
        print_message $YELLOW "  Ubuntu/Debian: sudo apt-get update && sudo apt-get install docker.io $COMPOSE_CMD-plugin"
        print_message $YELLOW "  CentOS/RHEL: sudo yum install docker $COMPOSE_CMD-plugin"
        print_message $YELLOW "  macOS: brew install docker $COMPOSE_CMD"
        exit 1
    fi
    
    # 检查Docker Compose是否可用
    if docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    elif command -v $COMPOSE_CMD &> /dev/null; then
        COMPOSE_CMD="$COMPOSE_CMD"
    else
        print_message $RED "错误: Docker Compose 未安装"
        print_message $YELLOW "请安装Docker Compose插件或独立版本"
        exit 1
    fi
    
    print_message $GREEN "✓ 使用命令: $COMPOSE_CMD"
}

# 检查必要文件
check_files() {
    local required_files=("Dockerfile" "$COMPOSE_CMD.yml" "nginx.conf" "default.conf")
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_message $RED "错误: 缺少必要文件 $file"
            exit 1
        fi
    done
    
    print_message $GREEN "✓ 所有必要文件存在"
}

# 创建必要目录
create_directories() {
    local directories=("logs/nginx" "config")
    
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            print_message $BLUE "创建目录: $dir"
        fi
    done
    
    print_message $GREEN "✓ 目录结构已准备"
}

# 构建镜像
build_image() {
    print_message $BLUE "开始构建 Docker 镜像..."
    
    # 清理Docker缓存
    print_message $BLUE "清理Docker构建缓存..."
    docker builder prune -f 2>/dev/null || true
    
    # 构建镜像
    if $COMPOSE_CMD -f $COMPOSE_FILE build --no-cache --pull; then
        print_message $GREEN "✓ 镜像构建完成"
    else
        print_message $RED "❌ 镜像构建失败"
        print_message $YELLOW "尝试修复构建问题..."
        
        # 清理相关镜像
        docker rmi $(docker images | grep "xinduqiao-travel" | awk '{print $3}') 2>/dev/null || true
        
        # 重新构建
        if $COMPOSE_CMD -f $COMPOSE_FILE build --no-cache --pull; then
            print_message $GREEN "✓ 修复后镜像构建完成"
        else
            print_message $RED "❌ 镜像构建仍然失败，请检查Dockerfile"
            return 1
        fi
    fi
}

# 启动服务
start_services() {
    local profile=$1
    
    if [[ -n "$profile" ]]; then
        print_message $BLUE "启动服务 (profile: $profile)..."
        $COMPOSE_CMD -f $COMPOSE_FILE --profile $profile up -d
    else
        print_message $BLUE "启动基础服务..."
        $COMPOSE_CMD -f $COMPOSE_FILE up -d
    fi
    
    print_message $GREEN "✓ 服务启动完成"
}

# 停止服务
stop_services() {
    print_message $BLUE "停止服务..."
    $COMPOSE_CMD -f $COMPOSE_FILE down
    print_message $GREEN "✓ 服务已停止"
}

# 重启服务
restart_services() {
    print_message $BLUE "重启服务..."
    $COMPOSE_CMD -f $COMPOSE_FILE restart
    print_message $GREEN "✓ 服务已重启"
}

# 查看服务状态
show_status() {
    print_message $BLUE "服务状态:"
    $COMPOSE_CMD -f $COMPOSE_FILE ps
    
    print_message $BLUE "\n容器资源使用情况:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

# 查看日志
show_logs() {
    local service=${1:-$SERVICE_NAME}
    print_message $BLUE "显示 $service 服务日志 (按 Ctrl+C 退出):"
    $COMPOSE_CMD -f $COMPOSE_FILE logs -f $service
}

# 清理资源
cleanup() {
    print_message $YELLOW "清理未使用的 Docker 资源..."
    docker system prune -f
    print_message $GREEN "✓ 清理完成"
}

# 健康检查
health_check() {
    print_message $BLUE "执行健康检查..."
    
    # 等待服务启动
    sleep 5
    
    # 检查HTTP响应
    if curl -f http://localhost/health &> /dev/null; then
        print_message $GREEN "✓ 健康检查通过"
        print_message $GREEN "网站已成功部署，访问地址: http://localhost"
        print_message $GREEN "生产环境访问地址: https://318.yongli.wang"
    else
        print_message $RED "✗ 健康检查失败"
        print_message $YELLOW "请检查服务日志: ./deploy.sh logs"
    fi
}

# 显示帮助信息
show_help() {
    echo "新都桥旅行网站 Docker 部署脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [选项] [参数]"
    echo ""
    echo "选项:"
    echo "  start [profile]     启动服务 (可选: proxy, monitoring)"
    echo "  stop                停止服务"
    echo "  restart             重启服务"
    echo "  build               构建镜像"
    echo "  status              查看服务状态"
    echo "  logs [service]      查看服务日志"
    echo "  health              健康检查"
    echo "  cleanup             清理未使用的资源"
    echo "  help                显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 start                    # 启动基础服务"
    echo "  $0 start monitoring         # 启动服务并启用监控"
    echo "  $0 logs xinduqiao-travel    # 查看主服务日志"
    echo "  $0 status                   # 查看服务状态"
}

# 主函数
main() {
    local action=${1:-start}
    local param=$2
    
    print_message $BLUE "新都桥旅行网站 Docker 部署脚本"
    print_message $BLUE "=================================="
    
    case $action in
        "start")
            check_docker
            check_files
            create_directories
            build_image
            start_services $param
            health_check
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            restart_services
            health_check
            ;;
        "build")
            check_docker
            check_files
            build_image
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs $param
            ;;
        "health")
            health_check
            ;;
        "cleanup")
            cleanup
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
