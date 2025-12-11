#!/bin/bash

# New-API 数据库备份脚本
# 支持 SQLite、MySQL 和 PostgreSQL 备份

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
BACKUP_DIR="./backups"
DATABASE_DIR="./database"
LOG_DIR="./logs"
RETENTION_DAYS=7
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 创建备份目录
create_backup_dirs() {
    mkdir -p "$BACKUP_DIR" "$LOG_DIR"
    print_message $BLUE "📁 创建备份目录..."
}

# 获取数据库配置
get_db_config() {
    if [ -f "./database.env" ]; then
        source ./database.env
    else
        DB_TYPE="sqlite"
        DB_PATH="/data/database.sqlite"
    fi
}

# SQLite 备份
backup_sqlite() {
    print_message $BLUE "💾 备份 SQLite 数据库..."
    
    local db_file="./data/database.sqlite"
    local backup_file="$BACKUP_DIR/database_$TIMESTAMP.sqlite"
    local log_file="$LOG_DIR/backup_$TIMESTAMP.log"
    
    if [ -f "$db_file" ]; then
        # 使用 SQLite 的备份命令
        sqlite3 "$db_file" ".backup '$backup_file'" 2>>"$log_file"
        
        if [ $? -eq 0 ]; then
            print_message $GREEN "✅ SQLite 备份成功: $backup_file"
            
            # 压缩备份文件
            gzip "$backup_file"
            print_message $GREEN "✅ 备份文件已压缩: ${backup_file}.gz"
        else
            print_message $RED "❌ SQLite 备份失败，查看日志: $log_file"
            return 1
        fi
    else
        print_message $YELLOW "⚠️  未找到 SQLite 数据库文件: $db_file"
        return 1
    fi
}

# MySQL 备份
backup_mysql() {
    print_message $BLUE "💾 备份 MySQL 数据库..."
    
    local backup_file="$BACKUP_DIR/mysql_$TIMESTAMP.sql"
    local log_file="$LOG_DIR/backup_$TIMESTAMP.log"
    
    mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$backup_file" 2>>"$log_file"
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ MySQL 备份成功: $backup_file"
        
        # 压缩备份文件
        gzip "$backup_file"
        print_message $GREEN "✅ 备份文件已压缩: ${backup_file}.gz"
    else
        print_message $RED "❌ MySQL 备份失败，查看日志: $log_file"
        return 1
    fi
}

# PostgreSQL 备份
backup_postgresql() {
    print_message $BLUE "💾 备份 PostgreSQL 数据库..."
    
    local backup_file="$BACKUP_DIR/postgres_$TIMESTAMP.sql"
    local log_file="$LOG_DIR/backup_$TIMESTAMP.log"
    
    PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" > "$backup_file" 2>>"$log_file"
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ PostgreSQL 备份成功: $backup_file"
        
        # 压缩备份文件
        gzip "$backup_file"
        print_message $GREEN "✅ 备份文件已压缩: ${backup_file}.gz"
    else
        print_message $RED "❌ PostgreSQL 备份失败，查看日志: $log_file"
        return 1
    fi
}

# 备份配置文件
backup_config() {
    print_message $BLUE "📄 备份配置文件..."
    
    local config_backup="$BACKUP_DIR/config_$TIMESTAMP.tar.gz"
    
    tar -czf "$config_backup" \
        ./database.env \
        ./.env.example \
        ../nginx/nginx.conf \
        ../docker-compose.yml \
        2>/dev/null
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ 配置文件备份成功: $config_backup"
    else
        print_message $YELLOW "⚠️  配置文件备份部分失败"
    fi
}

# 清理旧备份
cleanup_old_backups() {
    print_message $BLUE "🧹 清理 $RETENTION_DAYS 天前的旧备份..."
    
    find "$BACKUP_DIR" -name "*.gz" -type f -mtime +$RETENTION_DAYS -delete 2>/dev/null
    find "$BACKUP_DIR" -name "*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete 2>/dev/null
    find "$LOG_DIR" -name "backup_*.log" -type f -mtime +$RETENTION_DAYS -delete 2>/dev/null
    
    print_message $GREEN "✅ 旧备份清理完成"
}

# 生成备份报告
generate_backup_report() {
    local report_file="$BACKUP_DIR/backup_report_$TIMESTAMP.txt"
    
    {
        echo "New-API 备份报告"
        echo "================"
        echo "备份时间: $(date)"
        echo "备份类型: $DB_TYPE"
        echo "备份目录: $BACKUP_DIR"
        echo "保留天数: $RETENTION_DAYS"
        echo ""
        echo "备份文件列表:"
        ls -lh "$BACKUP_DIR"/*"$TIMESTAMP"*
        echo ""
        echo "磁盘使用情况:"
        df -h "$BACKUP_DIR"
    } > "$report_file"
    
    print_message $GREEN "📋 备份报告已生成: $report_file"
}

# 主备份函数
main_backup() {
    print_message $BLUE "🚀 开始 new-api 数据库备份..."
    
    create_backup_dirs
    get_db_config
    
    case "$DB_TYPE" in
        "sqlite")
            backup_sqlite
            ;;
        "mysql")
            backup_mysql
            ;;
        "postgresql")
            backup_postgresql
            ;;
        *)
            print_message $RED "❌ 不支持的数据库类型: $DB_TYPE"
            exit 1
            ;;
    esac
    
    backup_config
    cleanup_old_backups
    generate_backup_report
    
    print_message $GREEN "🎉 数据库备份完成！"
}

# 恢复函数
restore_database() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        print_message $RED "❌ 请提供备份文件路径"
        exit 1
    fi
    
    print_message $BLUE "🔄 开始恢复数据库..."
    
    if [ ! -f "$backup_file" ]; then
        print_message $RED "❌ 备份文件不存在: $backup_file"
        exit 1
    fi
    
    get_db_config
    
    case "$DB_TYPE" in
        "sqlite")
            print_message $BLUE "恢复 SQLite 数据库..."
            if [[ "$backup_file" == *.gz ]]; then
                gunzip -c "$backup_file" > ./data/database.sqlite.restored
            else
                cp "$backup_file" ./data/database.sqlite.restored
            fi
            print_message $GREEN "✅ SQLite 数据库恢复完成"
            print_message $YELLOW "⚠️  请手动替换原数据库文件"
            ;;
        "mysql")
            print_message $BLUE "恢复 MySQL 数据库..."
            if [[ "$backup_file" == *.gz ]]; then
                gunzip -c "$backup_file" | mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"
            else
                mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$backup_file"
            fi
            print_message $GREEN "✅ MySQL 数据库恢复完成"
            ;;
        "postgresql")
            print_message $BLUE "恢复 PostgreSQL 数据库..."
            if [[ "$backup_file" == *.gz ]]; then
                gunzip -c "$backup_file" | PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME"
            else
                PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" < "$backup_file"
            fi
            print_message $GREEN "✅ PostgreSQL 数据库恢复完成"
            ;;
    esac
}

# 显示帮助信息
show_help() {
    echo "New-API 数据库备份工具"
    echo ""
    echo "使用方法: $0 [命令] [参数]"
    echo ""
    echo "命令:"
    echo "  backup          执行完整备份"
    echo "  restore <文件>  从备份文件恢复数据库"
    echo "  help            显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 backup"
    echo "  $0 restore ./backups/database_20241211_143022.sqlite.gz"
    echo ""
    echo "备份文件将保存在: $BACKUP_DIR"
    echo "日志文件将保存在: $LOG_DIR"
    echo "保留天数: $RETENTION_DAYS 天"
}

# 处理命令行参数
case "${1:-backup}" in
    "backup")
        main_backup
        ;;
    "restore")
        if [ -z "$2" ]; then
            print_message $RED "错误: 请提供备份文件路径"
            show_help
            exit 1
        fi
        restore_database "$2"
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_message $RED "错误: 未知命令 '$1'"
        show_help
        exit 1
        ;;
esac