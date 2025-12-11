# New-API 部署指南

## 🎯 部署概述

本指南详细介绍了如何在现有 Docker 环境中部署 new-api 服务，并通过 nginx 反向代理使用域名 `newapi.yongli.wang` 进行访问。

## 📋 配置清单

### 1. Docker Compose 配置
- **服务名称**: `site-newapi`
- **镜像**: `calciumion/new-api:latest`
- **端口**: 3000 (内部)
- **数据卷**:
  - `./new-api:/data` (主数据目录)
  - `./new-api/database:/app/database` (数据库文件)
  - `./new-api/logs:/app/logs` (日志文件)
- **环境变量**: 通过 `database.env` 文件加载
- **数据库配置**: 支持 SQLite、MySQL、PostgreSQL

### 2. Nginx 反向代理配置
- **域名**: `newapi.yongli.wang`
- **上游服务器**: `site-newapi:3000`
- **负载均衡**: 最多3次失败，30秒超时

### 3. 健康检查
- **检查方式**: HTTP GET `/health`
- **检查间隔**: 30秒
- **超时时间**: 10秒
- **重试次数**: 3次
- **启动等待**: 40秒

## 🚀 部署步骤

### 步骤 1: 验证配置
确保以下文件已正确配置：

1. **docker-compose.yml** - 已添加 `site-newapi` 服务
2. **nginx/nginx.conf** - 已添加 new-api 反向代理配置
3. **new-api/** 目录 - 包含部署脚本和配置文件

### 步骤 2: 启动服务
在项目根目录执行：

```bash
# 启动所有服务（包括 new-api）
docker-compose up -d

# 或者只启动 new-api 服务
docker-compose up -d site-newapi
```

### 步骤 3: 验证部署
```bash
# 检查服务状态
docker-compose ps site-newapi

# 查看日志
docker-compose logs site-newapi

# 测试健康检查
curl -f http://localhost/health
```

### 步骤 4: 使用部署脚本（可选）
在 `new-api/` 目录下执行：

```bash
cd new-api/
./deploy.sh
```

## 🔧 配置说明

### 文件结构
```
new-api/
├── README.md          # 服务说明
├── deploy.sh          # 部署脚本
├── .env.example       # 环境变量示例
└── DEPLOYMENT_GUIDE.md # 本部署指南
```

### 关键配置
1. **无端口映射**: new-api 服务不直接暴露端口，仅通过 nginx 反向代理访问
2. **数据持久化**: `./new-api` 目录挂载到容器的 `/data` 目录
3. **健康检查**: 定期检测服务状态，确保服务可用性
4. **负载均衡**: nginx 配置了故障转移和超时机制

## 🌐 访问方式

部署完成后，可以通过以下方式访问 new-api：

- **域名访问**: http://newapi.yongli.wang
- **内部访问**: 通过 Docker 网络内部访问 `site-newapi:3000`

## 🔍 故障排除

### 常见问题

1. **服务无法启动**
   ```bash
   # 检查日志
   docker-compose logs site-newapi
   
   # 检查端口冲突
   netstat -tlnp | grep 3000
   ```

2. **nginx 反向代理失败**
   ```bash
   # 检查 nginx 配置
   docker-compose logs nginx
   
   # 测试 nginx 配置
   docker-compose exec nginx nginx -t
   ```

3. **域名无法访问**
   - 确保域名 `newapi.yongli.wang` 已正确解析到服务器 IP
   - 检查 DNS 设置
   - 验证 nginx 配置是否包含该域名

### 数据库配置

#### SQLite 配置（默认）
默认使用 SQLite 数据库，数据文件持久化存储在 `./new-api/data/database.sqlite`

```bash
# 数据库文件位置
./new-api/data/database.sqlite

# 备份目录
./new-api/backups/

# 日志目录
./new-api/logs/
```

#### 数据库环境变量
所有数据库配置通过 `database.env` 文件管理，支持：
- **SQLite**: 轻量级，适合开发和小型部署
- **MySQL**: 生产环境推荐
- **PostgreSQL**: 企业级应用推荐

#### 修改数据库类型
1. 复制示例文件：
```bash
cp database.env.example database.env
```

2. 编辑 `database.env`，选择对应的数据库类型

3. 重新部署服务：
```bash
docker-compose up -d site-newapi
```

#### 数据库备份
```bash
# 执行备份
cd new-api/
./backup.sh

# 查看备份文件
ls -la backups/
```

#### 数据库恢复
```bash
# 从备份恢复
cd new-api/
./backup.sh restore ./backups/database_20241211_143022.sqlite.gz
```

### 日志查看
```bash
# 查看 new-api 日志
docker-compose logs -f site-newapi

# 查看 nginx 日志
docker-compose logs -f nginx

# 查看数据库日志
docker-compose logs -f site-newapi | grep -i database
```

## 🔄 更新和维护

### 更新服务
```bash
# 拉取最新镜像
docker-compose pull site-newapi

# 重新启动服务
docker-compose up -d site-newapi
```

### 数据库备份和恢复

#### 手动备份
```bash
# 进入 new-api 目录
cd new-api/

# 执行备份
./backup.sh backup

# 查看备份文件
ls -la backups/
```

#### 自动备份（推荐）
```bash
# 安装定时任务
crontab -e

# 添加以下内容（每天凌晨2点备份）
0 2 * * * cd /path/to/multi-site/new-api && ./backup.sh backup >> ./logs/cron.log 2>&1

# 或者使用提供的示例配置
cp crontab.example /etc/cron.d/new-api-backup
```

#### 数据库恢复
```bash
# 列出可用备份
ls -la backups/

# 恢复指定备份
./backup.sh restore ./backups/database_20241211_143022.sqlite.gz

# 验证恢复
docker-compose restart site-newapi
```

#### 备份策略建议
1. **每日备份**: 基础数据保护
2. **每周完整备份**: 包含配置文件
3. **每月清理**: 删除30天前的旧备份
4. **异地备份**: 建议将备份文件复制到其他服务器

#### 监控备份状态
```bash
# 查看备份日志
tail -f logs/backup_*.log

# 检查 cron 日志
tail -f logs/cron.log

# 验证备份完整性
gunzip -t backups/database_*.sqlite.gz
```

#### 数据库持久化配置
当前配置已确保：
- ✅ SQLite 数据库文件 (`./data/database.sqlite`) 持久化存储
- ✅ 日志文件 (`./logs/`) 持久化存储
- ✅ 备份文件 (`./backups/`) 持久化存储
- ✅ 配置文件 (`database.env`) 持久化存储

#### 容器重启保护
即使容器重启，数据也不会丢失：
- 数据库文件挂载到宿主机 `./new-api/data/`
- 备份文件保存在 `./new-api/backups/`
- 日志文件保存在 `./new-api/logs/`

#### 数据安全警告已解决
之前的 SQLite 警告已通过以下方式解决：
1. **数据卷映射**: `./new-api:/data` 确保数据持久化
2. **WAL 模式**: 启用 SQLite 的 WAL 模式提高性能和可靠性
3. **定期备份**: 自动备份机制防止数据丢失
4. **备份验证**: 备份完整性检查确保可恢复性

## 📞 技术支持

如遇到问题，请检查：
1. Docker 和 Docker Compose 是否正确安装
2. 端口是否被占用
3. 域名解析是否正确
4. 查看相关日志信息

## ⚠️ 注意事项

1. **不影响现有服务**: 新配置不会影响已运行的 318、dt 等其他服务
2. **无需服务器登录**: 所有操作通过 Docker Compose 完成
3. **数据安全**: 定期备份 `new-api/` 目录下的数据
4. **监控建议**: 建议设置监控告警，确保服务稳定运行