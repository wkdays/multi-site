# Docker 安装和部署指南

## 问题分析

您遇到的错误是：
```
error mounting "/home/ubuntu/318/config/nginx.conf" to rootfs at "/etc/nginx/nginx.conf": 
mount /home/ubuntu/318/config/nginx.conf:/etc/nginx/nginx.conf (via /proc/self/fd/6), 
flags: 0x5000: not a directory: unknown: Are you trying to mount a directory onto a file (or vice-versa)?
```

**问题原因：**
1. Docker Compose 试图挂载 `./config/nginx.conf` 文件，但该文件不存在
2. 系统可能没有安装 Docker 或 Docker Compose

## 解决方案

### 1. 安装 Docker 和 Docker Compose

#### Ubuntu/Debian 系统：
```bash
# 更新包列表
sudo apt-get update

# 安装 Docker
sudo apt-get install -y docker.io docker-compose-plugin

# 启动 Docker 服务
sudo systemctl start docker
sudo systemctl enable docker

# 将当前用户添加到 docker 组（避免使用 sudo）
sudo usermod -aG docker $USER

# 重新登录或运行以下命令使组权限生效
newgrp docker
```

#### CentOS/RHEL 系统：
```bash
# 安装 Docker
sudo yum install -y docker docker-compose-plugin

# 启动 Docker 服务
sudo systemctl start docker
sudo systemctl enable docker

# 将当前用户添加到 docker 组
sudo usermod -aG docker $USER
newgrp docker
```

#### macOS 系统：
```bash
# 使用 Homebrew 安装
brew install docker docker-compose

# 或者下载 Docker Desktop for Mac
# https://www.docker.com/products/docker-desktop
```

### 2. 验证安装

```bash
# 检查 Docker 版本
docker --version

# 检查 Docker Compose 版本
docker compose version
# 或者
docker-compose --version
```

### 3. 修复配置文件问题

运行修复脚本：
```bash
# 给脚本执行权限
chmod +x scripts/fix-mount-issue.sh

# 运行修复脚本
./scripts/fix-mount-issue.sh
```

或者手动创建缺失的配置文件：

```bash
# 确保配置文件存在
ls -la nginx.conf default.conf

# 如果文件不存在，脚本会自动创建
```

### 4. 启动服务

```bash
# 使用部署脚本
./deploy.sh start

# 或者直接使用 Docker Compose
docker compose up -d
```

### 5. 验证部署

```bash
# 检查服务状态
docker compose ps

# 检查日志
docker compose logs

# 测试网站
curl http://localhost/health
```

## 常见问题

### Q: 权限被拒绝错误
```bash
# 解决方案：将用户添加到 docker 组
sudo usermod -aG docker $USER
newgrp docker
```

### Q: Docker 服务未启动
```bash
# 启动 Docker 服务
sudo systemctl start docker
```

### Q: 端口被占用
```bash
# 检查端口占用
sudo netstat -tlnp | grep :80

# 停止占用端口的服务
sudo systemctl stop nginx  # 如果 nginx 在运行
```

### Q: 磁盘空间不足
```bash
# 清理 Docker 缓存
docker system prune -a

# 清理未使用的镜像
docker image prune -a
```

## 生产环境部署

### 1. 使用生产配置
```bash
# 使用生产环境配置
docker compose -f docker-compose.prod.yml up -d
```

### 2. 配置域名和 SSL
```bash
# 运行 SSL 设置脚本
./scripts/ssl-setup.sh
```

### 3. 监控和维护
```bash
# 查看服务状态
./deploy.sh status

# 查看日志
./deploy.sh logs

# 重启服务
./deploy.sh restart
```

## 联系支持

如果遇到其他问题，请检查：
1. Docker 和 Docker Compose 是否正确安装
2. 用户是否有 Docker 权限
3. 端口 80 是否被其他服务占用
4. 磁盘空间是否充足

更多帮助请参考项目文档或联系技术支持。
