# Docker部署问题排查指南

## 🚨 常见问题及解决方案

### 1. Docker权限问题

**错误信息：**
```
permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock
```

**解决方案：**
```bash
# 运行权限修复脚本
chmod +x scripts/fix-docker-permissions.sh
./scripts/fix-docker-permissions.sh

# 或手动修复
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Nginx容器权限问题

**错误信息：**
```
nginx: [alert] could not open error log file: open() "/var/log/nginx/error.log" failed (13: Permission denied)
the "user" directive makes sense only if the master process runs with super-user privileges, ignored
```

**解决方案：**
```bash
# 运行Nginx权限修复脚本
chmod +x scripts/fix-nginx-permissions.sh
./scripts/fix-nginx-permissions.sh

# 或手动重新构建
docker compose down
docker compose build --no-cache
docker compose up -d
```

### 3. 配置文件挂载问题

**错误信息：**
```
error mounting "/home/ubuntu/318/config/nginx.conf" to rootfs at "/etc/nginx/nginx.conf": not a directory
```

**解决方案：**
```bash
# 运行挂载问题修复脚本
chmod +x scripts/fix-mount-issue.sh
./scripts/fix-mount-issue.sh
```

### 4. Docker Compose版本警告

**错误信息：**
```
WARN[0000] /home/ubuntu/318/docker-compose.yml: `version` is obsolete
```

**解决方案：**
- 已自动修复，拉取最新代码即可
- 或手动移除docker-compose.yml中的version字段

## 🔧 完整修复流程

### 步骤1：拉取最新代码
```bash
git pull origin main
```

### 步骤2：运行综合修复脚本
```bash
# 给所有脚本执行权限
chmod +x scripts/*.sh

# 运行Docker权限修复
./scripts/fix-docker-permissions.sh

# 运行挂载问题修复
./scripts/fix-mount-issue.sh

# 运行Nginx权限修复
./scripts/fix-nginx-permissions.sh
```

### 步骤3：验证部署
```bash
# 检查服务状态
docker compose ps

# 测试网站访问
curl http://localhost/health

# 查看日志
docker compose logs
```

## 🚀 快速启动命令

```bash
# 一键启动（推荐）
./deploy.sh start

# 或使用Docker Compose
docker compose up -d
```

## 📋 检查清单

在部署前请确认：

- [ ] Docker已安装并运行
- [ ] 用户已添加到docker组
- [ ] 端口80未被占用
- [ ] 磁盘空间充足
- [ ] 网络连接正常

## 🔍 日志查看

```bash
# 查看所有服务日志
docker compose logs

# 查看特定服务日志
docker compose logs xinduqiao-travel

# 实时查看日志
docker compose logs -f

# 查看最近20行日志
docker compose logs --tail=20
```

## 🛠️ 常用维护命令

```bash
# 停止服务
docker compose down

# 重启服务
docker compose restart

# 重新构建并启动
docker compose up -d --build

# 清理Docker缓存
docker system prune -f

# 查看容器状态
docker compose ps

# 进入容器调试
docker compose exec xinduqiao-travel sh
```

## 📞 获取帮助

如果遇到其他问题：

1. 查看详细日志：`docker compose logs`
2. 检查容器状态：`docker compose ps`
3. 验证配置文件：检查nginx.conf和default.conf
4. 检查网络连接：`curl -I http://localhost`

## 🎯 成功标志

部署成功的标志：
- ✅ 容器状态显示为"Up"
- ✅ 健康检查通过：`curl http://localhost/health`
- ✅ 网站可访问：`curl http://localhost`
- ✅ 无权限错误日志
