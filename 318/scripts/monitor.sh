#!/bin/bash

# 新都桥旅行网站监控脚本
# 使用方法: ./scripts/monitor.sh [选项]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
PROJECT_NAME="xinduqiao-travel"
SERVICE_NAME="xinduqiao-travel"
DOMAIN="318.yongli.wang"
LOG_FILE="./logs/monitor.log"

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 记录日志
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# 检查 Docker 服务状态
check_docker_status() {
    print_message $BLUE "检查 Docker 服务状态..."
    
    if ! docker info >/dev/null 2>&1; then
        print_message $RED "❌ Docker 服务未运行"
        log_message "ERROR" "Docker service is not running"
        return 1
    fi
    
    print_message $GREEN "✅ Docker 服务正常运行"
    log_message "INFO" "Docker service is running"
    return 0
}

# 检查容器状态
check_container_status() {
    print_message $BLUE "检查容器状态..."
    
    local container_name="${PROJECT_NAME}-website"
    local container_status=$(docker inspect --format='{{.State.Status}}' "$container_name" 2>/dev/null || echo "not_found")
    
    case $container_status in
        "running")
            print_message $GREEN "✅ 容器 $container_name 正在运行"
            log_message "INFO" "Container $container_name is running"
            return 0
            ;;
        "exited")
            print_message $RED "❌ 容器 $container_name 已停止"
            log_message "ERROR" "Container $container_name is stopped"
            return 1
            ;;
        "not_found")
            print_message $RED "❌ 容器 $container_name 不存在"
            log_message "ERROR" "Container $container_name not found"
            return 1
            ;;
        *)
            print_message $YELLOW "⚠️  容器 $container_name 状态异常: $container_status"
            log_message "WARN" "Container $container_name status: $container_status"
            return 1
            ;;
    esac
}

# 检查服务健康状态
check_health() {
    print_message $BLUE "检查服务健康状态..."
    
    # 检查本地健康端点
    if curl -f http://localhost/health >/dev/null 2>&1; then
        print_message $GREEN "✅ 本地健康检查通过"
        log_message "INFO" "Local health check passed"
    else
        print_message $RED "❌ 本地健康检查失败"
        log_message "ERROR" "Local health check failed"
        return 1
    fi
    
    # 检查域名健康端点（如果域名可访问）
    if curl -f "https://$DOMAIN/health" >/dev/null 2>&1; then
        print_message $GREEN "✅ 域名健康检查通过"
        log_message "INFO" "Domain health check passed"
    else
        print_message $YELLOW "⚠️  域名健康检查失败（可能是网络问题）"
        log_message "WARN" "Domain health check failed"
    fi
    
    return 0
}

# 检查资源使用情况
check_resources() {
    print_message $BLUE "检查资源使用情况..."
    
    local container_name="${PROJECT_NAME}-website"
    local stats=$(docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" "$container_name" 2>/dev/null || echo "")
    
    if [[ -n "$stats" ]]; then
        print_message $GREEN "✅ 资源使用情况:"
        echo "$stats"
        log_message "INFO" "Resource usage checked"
    else
        print_message $RED "❌ 无法获取资源使用情况"
        log_message "ERROR" "Failed to get resource usage"
        return 1
    fi
    
    return 0
}

# 检查磁盘空间
check_disk_space() {
    print_message $BLUE "检查磁盘空间..."
    
    local disk_usage=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [[ $disk_usage -lt 80 ]]; then
        print_message $GREEN "✅ 磁盘空间充足: ${disk_usage}% 已使用"
        log_message "INFO" "Disk space: ${disk_usage}% used"
    elif [[ $disk_usage -lt 90 ]]; then
        print_message $YELLOW "⚠️  磁盘空间警告: ${disk_usage}% 已使用"
        log_message "WARN" "Disk space warning: ${disk_usage}% used"
    else
        print_message $RED "❌ 磁盘空间不足: ${disk_usage}% 已使用"
        log_message "ERROR" "Disk space critical: ${disk_usage}% used"
        return 1
    fi
    
    return 0
}

# 检查日志错误
check_log_errors() {
    print_message $BLUE "检查日志错误..."
    
    local error_count=0
    
    # 检查 Nginx 错误日志
    if [[ -f "logs/nginx/error.log" ]]; then
        local nginx_errors=$(grep -c "ERROR\|CRITICAL\|FATAL" logs/nginx/error.log 2>/dev/null || echo "0")
        if [[ $nginx_errors -gt 0 ]]; then
            print_message $YELLOW "⚠️  Nginx 错误日志中发现 $nginx_errors 个错误"
            log_message "WARN" "Found $nginx_errors errors in Nginx error log"
            error_count=$((error_count + nginx_errors))
        fi
    fi
    
    # 检查 Docker 容器日志
    local container_name="${PROJECT_NAME}-website"
    local container_errors=$(docker logs "$container_name" 2>&1 | grep -c "ERROR\|CRITICAL\|FATAL" 2>/dev/null || echo "0")
    if [[ $container_errors -gt 0 ]]; then
        print_message $YELLOW "⚠️  容器日志中发现 $container_errors 个错误"
        log_message "WARN" "Found $container_errors errors in container log"
        error_count=$((error_count + container_errors))
    fi
    
    if [[ $error_count -eq 0 ]]; then
        print_message $GREEN "✅ 未发现严重错误"
        log_message "INFO" "No critical errors found"
    fi
    
    return 0
}

# 检查网络连接
check_network() {
    print_message $BLUE "检查网络连接..."
    
    # 检查本地端口
    if netstat -tuln | grep -q ":80 "; then
        print_message $GREEN "✅ 端口 80 正在监听"
        log_message "INFO" "Port 80 is listening"
    else
        print_message $RED "❌ 端口 80 未监听"
        log_message "ERROR" "Port 80 is not listening"
        return 1
    fi
    
    # 检查域名解析
    if nslookup "$DOMAIN" >/dev/null 2>&1; then
        print_message $GREEN "✅ 域名解析正常"
        log_message "INFO" "Domain resolution is working"
    else
        print_message $YELLOW "⚠️  域名解析失败"
        log_message "WARN" "Domain resolution failed"
    fi
    
    return 0
}

# 生成监控报告
generate_report() {
    print_message $BLUE "生成监控报告..."
    
    local report_file="./logs/monitor-report-$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$report_file" << EOF
新都桥旅行网站监控报告
====================
生成时间: $(date)
域名: $DOMAIN
项目: $PROJECT_NAME

=== Docker 服务状态 ===
$(docker info 2>/dev/null | head -10 || echo "Docker 服务未运行")

=== 容器状态 ===
$(docker ps -a --filter "name=$PROJECT_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "容器未找到")

=== 资源使用情况 ===
$(docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" 2>/dev/null || echo "无法获取资源信息")

=== 磁盘空间 ===
$(df -h . | head -2)

=== 网络状态 ===
$(netstat -tuln | grep ":80 " || echo "端口 80 未监听")

=== 最近错误日志 ===
$(tail -20 logs/nginx/error.log 2>/dev/null || echo "错误日志不存在")

=== 监控日志 ===
$(tail -20 "$LOG_FILE" 2>/dev/null || echo "监控日志不存在")

EOF
    
    print_message $GREEN "✅ 监控报告已生成: $report_file"
    log_message "INFO" "Monitor report generated: $report_file"
}

# 自动修复
auto_fix() {
    print_message $BLUE "尝试自动修复..."
    
    # 检查容器状态并重启
    local container_name="${PROJECT_NAME}-website"
    local container_status=$(docker inspect --format='{{.State.Status}}' "$container_name" 2>/dev/null || echo "not_found")
    
    if [[ "$container_status" == "exited" ]]; then
        print_message $YELLOW "尝试重启容器..."
        docker-compose restart "$SERVICE_NAME"
        sleep 10
        
        if check_container_status; then
            print_message $GREEN "✅ 容器重启成功"
            log_message "INFO" "Container restarted successfully"
        else
            print_message $RED "❌ 容器重启失败"
            log_message "ERROR" "Container restart failed"
            return 1
        fi
    fi
    
    return 0
}

# 连续监控
continuous_monitor() {
    local interval=${1:-60}
    print_message $BLUE "开始连续监控，间隔 ${interval} 秒..."
    
    while true; do
        print_message $BLUE "=== 监控检查 $(date) ==="
        
        check_docker_status
        check_container_status
        check_health
        check_resources
        check_disk_space
        check_log_errors
        check_network
        
        print_message $BLUE "等待 ${interval} 秒后进行下次检查..."
        sleep $interval
    done
}

# 显示帮助信息
show_help() {
    echo "新都桥旅行网站监控脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [选项] [参数]"
    echo ""
    echo "选项:"
    echo "  status             检查服务状态"
    echo "  health             健康检查"
    echo "  resources          检查资源使用"
    echo "  logs               检查日志错误"
    echo "  network            检查网络连接"
    echo "  report             生成监控报告"
    echo "  fix                自动修复"
    echo "  monitor [interval] 连续监控（默认60秒）"
    echo "  help               显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 status           # 检查服务状态"
    echo "  $0 monitor 30       # 每30秒监控一次"
    echo "  $0 report           # 生成监控报告"
}

# 主函数
main() {
    local action=${1:-status}
    local param=$2
    
    # 创建日志目录
    mkdir -p "$(dirname "$LOG_FILE")"
    
    print_message $BLUE "新都桥旅行网站监控脚本"
    print_message $BLUE "========================"
    
    case $action in
        "status")
            check_docker_status
            check_container_status
            check_health
            ;;
        "health")
            check_health
            ;;
        "resources")
            check_resources
            check_disk_space
            ;;
        "logs")
            check_log_errors
            ;;
        "network")
            check_network
            ;;
        "report")
            generate_report
            ;;
        "fix")
            auto_fix
            ;;
        "monitor")
            continuous_monitor $param
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
