#!/bin/bash

# 新都桥旅行网站备份脚本
# 使用方法: ./scripts/backup.sh [备份类型]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="xinduqiao-backup-${TIMESTAMP}"
PROJECT_NAME="xinduqiao-travel"

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 创建备份目录
create_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        print_message $BLUE "创建备份目录: $BACKUP_DIR"
    fi
}

# 备份配置文件
backup_config() {
    print_message $BLUE "备份配置文件..."
    
    local config_backup="${BACKUP_DIR}/${BACKUP_NAME}-config"
    mkdir -p "$config_backup"
    
    # 备份 Docker 配置文件
    cp -r config/ "$config_backup/" 2>/dev/null || true
    cp docker-compose*.yml "$config_backup/" 2>/dev/null || true
    cp Dockerfile "$config_backup/" 2>/dev/null || true
    cp nginx.conf "$config_backup/" 2>/dev/null || true
    cp default.conf "$config_backup/" 2>/dev/null || true
    cp .dockerignore "$config_backup/" 2>/dev/null || true
    cp Makefile "$config_backup/" 2>/dev/null || true
    cp deploy.sh "$config_backup/" 2>/dev/null || true
    cp env.example "$config_backup/" 2>/dev/null || true
    
    # 备份 Traefik 配置
    if [[ -d "traefik" ]]; then
        cp -r traefik/ "$config_backup/" 2>/dev/null || true
    fi
    
    print_message $GREEN "✅ 配置文件备份完成: $config_backup"
}

# 备份日志文件
backup_logs() {
    print_message $BLUE "备份日志文件..."
    
    local logs_backup="${BACKUP_DIR}/${BACKUP_NAME}-logs"
    mkdir -p "$logs_backup"
    
    if [[ -d "logs" ]]; then
        cp -r logs/ "$logs_backup/" 2>/dev/null || true
        print_message $GREEN "✅ 日志文件备份完成: $logs_backup"
    else
        print_message $YELLOW "⚠️  日志目录不存在，跳过日志备份"
    fi
}

# 备份网站数据
backup_website() {
    print_message $BLUE "备份网站数据..."
    
    local website_backup="${BACKUP_DIR}/${BACKUP_NAME}-website"
    mkdir -p "$website_backup"
    
    # 备份网站文件
    cp index.html "$website_backup/" 2>/dev/null || true
    cp -r assets/ "$website_backup/" 2>/dev/null || true
    cp robots.txt "$website_backup/" 2>/dev/null || true
    cp sitemap.xml "$website_backup/" 2>/dev/null || true
    cp *.md "$website_backup/" 2>/dev/null || true
    
    print_message $GREEN "✅ 网站数据备份完成: $website_backup"
}

# 备份 Docker 镜像
backup_images() {
    print_message $BLUE "备份 Docker 镜像..."
    
    local images_backup="${BACKUP_DIR}/${BACKUP_NAME}-images"
    mkdir -p "$images_backup"
    
    # 导出镜像
    local image_name="${PROJECT_NAME}_xinduqiao-travel"
    if docker images | grep -q "$image_name"; then
        docker save "$image_name" | gzip > "${images_backup}/${image_name}.tar.gz"
        print_message $GREEN "✅ Docker 镜像备份完成: ${images_backup}/${image_name}.tar.gz"
    else
        print_message $YELLOW "⚠️  Docker 镜像不存在，跳过镜像备份"
    fi
}

# 备份 Docker 卷
backup_volumes() {
    print_message $BLUE "备份 Docker 卷..."
    
    local volumes_backup="${BACKUP_DIR}/${BACKUP_NAME}-volumes"
    mkdir -p "$volumes_backup"
    
    # 备份命名卷
    local volumes=$(docker volume ls -q | grep "$PROJECT_NAME" || true)
    if [[ -n "$volumes" ]]; then
        for volume in $volumes; do
            print_message $BLUE "备份卷: $volume"
            docker run --rm -v "$volume":/data -v "$(pwd)/$volumes_backup":/backup alpine tar czf "/backup/${volume}.tar.gz" -C /data .
        done
        print_message $GREEN "✅ Docker 卷备份完成: $volumes_backup"
    else
        print_message $YELLOW "⚠️  没有找到相关 Docker 卷，跳过卷备份"
    fi
}

# 创建完整备份
backup_full() {
    print_message $BLUE "创建完整备份..."
    
    backup_config
    backup_logs
    backup_website
    backup_images
    backup_volumes
    
    # 创建备份清单
    local manifest="${BACKUP_DIR}/${BACKUP_NAME}-manifest.txt"
    cat > "$manifest" << EOF
新都桥旅行网站备份清单
========================
备份时间: $(date)
备份类型: 完整备份
备份名称: $BACKUP_NAME

包含内容:
- 配置文件 (config/)
- 日志文件 (logs/)
- 网站数据 (assets/, index.html 等)
- Docker 镜像
- Docker 卷

备份文件:
$(ls -la "${BACKUP_DIR}/${BACKUP_NAME}"*)

恢复说明:
1. 恢复配置文件: cp -r ${BACKUP_NAME}-config/* ./
2. 恢复日志文件: cp -r ${BACKUP_NAME}-logs/* ./
3. 恢复网站数据: cp -r ${BACKUP_NAME}-website/* ./
4. 恢复 Docker 镜像: docker load < ${BACKUP_NAME}-images/*.tar.gz
5. 恢复 Docker 卷: 参考备份文件中的说明

EOF
    
    print_message $GREEN "✅ 完整备份完成: $BACKUP_NAME"
    print_message $GREEN "📋 备份清单: $manifest"
}

# 清理旧备份
cleanup_old_backups() {
    local days=${1:-7}
    print_message $BLUE "清理 $days 天前的备份..."
    
    find "$BACKUP_DIR" -name "xinduqiao-backup-*" -type d -mtime +$days -exec rm -rf {} \; 2>/dev/null || true
    find "$BACKUP_DIR" -name "xinduqiao-backup-*.tar.gz" -mtime +$days -delete 2>/dev/null || true
    
    print_message $GREEN "✅ 旧备份清理完成"
}

# 显示备份列表
list_backups() {
    print_message $BLUE "备份列表:"
    
    if [[ -d "$BACKUP_DIR" ]]; then
        ls -la "$BACKUP_DIR" | grep "xinduqiao-backup" || print_message $YELLOW "没有找到备份文件"
    else
        print_message $YELLOW "备份目录不存在"
    fi
}

# 显示帮助信息
show_help() {
    echo "新都桥旅行网站备份脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [选项] [参数]"
    echo ""
    echo "选项:"
    echo "  full                完整备份（默认）"
    echo "  config             仅备份配置文件"
    echo "  logs               仅备份日志文件"
    echo "  website            仅备份网站数据"
    echo "  images             仅备份 Docker 镜像"
    echo "  volumes            仅备份 Docker 卷"
    echo "  list               显示备份列表"
    echo "  cleanup [days]     清理旧备份（默认7天）"
    echo "  help               显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                  # 完整备份"
    echo "  $0 config           # 仅备份配置"
    echo "  $0 cleanup 30       # 清理30天前的备份"
    echo "  $0 list             # 显示备份列表"
}

# 主函数
main() {
    local action=${1:-full}
    local param=$2
    
    print_message $BLUE "新都桥旅行网站备份脚本"
    print_message $BLUE "========================"
    
    create_backup_dir
    
    case $action in
        "full")
            backup_full
            ;;
        "config")
            backup_config
            ;;
        "logs")
            backup_logs
            ;;
        "website")
            backup_website
            ;;
        "images")
            backup_images
            ;;
        "volumes")
            backup_volumes
            ;;
        "list")
            list_backups
            ;;
        "cleanup")
            cleanup_old_backups $param
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
