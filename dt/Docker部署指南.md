# 🐳 中晋数据科技 - Docker部署指南

## 📋 目录

- [快速开始](#快速开始)
- [部署方式](#部署方式)
- [配置说明](#配置说明)
- [监控与日志](#监控与日志)
- [故障排除](#故障排除)
- [高级配置](#高级配置)

---

## 🚀 快速开始

### 方式一：一键部署脚本

```bash
# 克隆项目
git clone https://github.com/wkdays/datarecover.git
cd datarecover

# 一键部署
./deploy.sh run
```

### 方式二：Docker Compose

```bash
# 启动服务
docker-compose up -d

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 方式三：手动Docker命令

```bash
# 构建镜像
docker build -t datarecover-web .

# 运行容器
docker run -d \
  --name zhongjin-datarecover \
  --restart unless-stopped \
  -p 8080:80 \
  datarecover-web:latest
```

---

## 🎯 部署方式

### 1. 基础部署（推荐）

**适用场景**: 单机部署、开发测试

```bash
./deploy.sh run
```

**访问地址**: http://localhost:8080

### 2. Docker Compose部署

**适用场景**: 生产环境、多服务集成

```bash
# 基础服务
docker-compose up -d

# 包含监控
docker-compose --profile monitoring up -d

# 包含反向代理
docker-compose --profile proxy up -d
```

### 3. 生产环境部署

**适用场景**: 高可用、负载均衡

```bash
# 使用Docker Swarm
docker stack deploy -c docker-compose.yml datarecover

# 或使用Kubernetes
kubectl apply -f k8s/
```

---

## ⚙️ 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `NGINX_HOST` | localhost | Nginx监听主机 |
| `NGINX_PORT` | 80 | Nginx监听端口 |

### 端口映射

| 服务 | 容器端口 | 主机端口 | 说明 |
|------|----------|----------|------|
| 网站 | 80 | 8080 | 主网站服务 |
| 代理 | 80/443 | 80/443 | 反向代理（可选） |
| Prometheus | 9090 | 9090 | 监控（可选） |
| Grafana | 3000 | 3000 | 仪表板（可选） |

### 数据卷

| 卷名 | 挂载点 | 说明 |
|------|--------|------|
| `logs` | `/var/log/nginx` | Nginx日志 |
| `prometheus_data` | `/prometheus` | 监控数据 |
| `grafana_data` | `/var/lib/grafana` | 仪表板数据 |

---

## 📊 监控与日志

### 健康检查

```bash
# 检查容器状态
docker ps

# 检查健康状态
curl http://localhost:8080/health

# 查看容器日志
docker logs zhongjin-datarecover
```

### 监控面板

启用监控服务：

```bash
docker-compose --profile monitoring up -d
```

**访问地址**:
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin123)

### 日志管理

```bash
# 实时查看日志
docker logs -f zhongjin-datarecover

# 查看最近100行日志
docker logs --tail 100 zhongjin-datarecover

# 查看指定时间日志
docker logs --since "2024-01-01T00:00:00" zhongjin-datarecover
```

---

## 🔧 故障排除

### 常见问题

#### 1. 容器启动失败

```bash
# 查看详细错误
docker logs zhongjin-datarecover

# 检查端口占用
netstat -tulpn | grep 8080

# 重新构建镜像
docker build --no-cache -t datarecover-web .
```

#### 2. 网站无法访问

```bash
# 检查容器状态
docker ps

# 检查端口映射
docker port zhongjin-datarecover

# 测试容器内部
docker exec -it zhongjin-datarecover curl localhost
```

#### 3. 性能问题

```bash
# 查看资源使用
docker stats zhongjin-datarecover

# 检查Nginx配置
docker exec -it zhongjin-datarecover nginx -t

# 重启服务
docker restart zhongjin-datarecover
```

### 调试命令

```bash
# 进入容器
docker exec -it zhongjin-datarecover sh

# 检查Nginx状态
docker exec zhongjin-datarecover nginx -s reload

# 查看进程
docker exec zhongjin-datarecover ps aux
```

---

## 🚀 高级配置

### 1. 自定义Nginx配置

编辑 `nginx.conf` 文件，然后重新构建：

```bash
# 修改配置后重新构建
docker build -t datarecover-web .
docker restart zhongjin-datarecover
```

### 2. SSL证书配置

```bash
# 创建SSL目录
mkdir -p proxy/ssl

# 生成自签名证书（测试用）
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout proxy/ssl/key.pem \
  -out proxy/ssl/cert.pem

# 启动HTTPS代理
docker-compose --profile proxy up -d
```

### 3. 负载均衡配置

```yaml
# docker-compose.yml 中添加
services:
  nginx-lb:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./lb/nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - datarecover-web
```

### 4. 数据持久化

```bash
# 创建数据目录
mkdir -p data/{logs,ssl,monitoring}

# 修改docker-compose.yml
volumes:
  - ./data/logs:/var/log/nginx
  - ./data/ssl:/etc/nginx/ssl
  - ./data/monitoring:/prometheus
```

---

## 📝 部署脚本使用

### 脚本命令

```bash
./deploy.sh [选项]
```

| 命令 | 说明 |
|------|------|
| `run` | 构建并运行容器（默认） |
| `build` | 仅构建镜像 |
| `compose` | 使用Docker Compose部署 |
| `stop` | 停止容器 |
| `restart` | 重启容器 |
| `logs` | 查看日志 |
| `status` | 查看状态 |
| `clean` | 清理所有资源 |
| `help` | 显示帮助信息 |

### 使用示例

```bash
# 完整部署
./deploy.sh run

# 仅构建镜像
./deploy.sh build

# 查看运行状态
./deploy.sh status

# 查看实时日志
./deploy.sh logs

# 重启服务
./deploy.sh restart

# 清理资源
./deploy.sh clean
```

---

## 🔒 安全配置

### 1. 网络安全

```bash
# 创建自定义网络
docker network create datarecover-network

# 限制端口访问
docker run -d \
  --name zhongjin-datarecover \
  --network datarecover-network \
  -p 127.0.0.1:8080:80 \
  datarecover-web:latest
```

### 2. 用户权限

```dockerfile
# Dockerfile中已配置非root用户
USER nginx
```

### 3. 安全头配置

```nginx
# nginx.conf中已配置安全头
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
```

---

## 📈 性能优化

### 1. 资源限制

```yaml
# docker-compose.yml
services:
  datarecover-web:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

### 2. 缓存配置

```nginx
# 静态资源缓存
location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 3. Gzip压缩

```nginx
# 已启用Gzip压缩
gzip on;
gzip_comp_level 6;
gzip_types text/plain text/css application/json application/javascript;
```

---

## 🌐 生产环境部署

### 1. 使用Docker Swarm

```bash
# 初始化Swarm
docker swarm init

# 部署服务栈
docker stack deploy -c docker-compose.yml datarecover

# 查看服务
docker service ls
```

### 2. 使用Kubernetes

```bash
# 创建Kubernetes配置
kubectl apply -f k8s/

# 查看Pod状态
kubectl get pods

# 查看服务
kubectl get services
```

### 3. 使用云服务

**阿里云容器服务**:
```bash
# 使用阿里云容器镜像服务
docker tag datarecover-web registry.cn-hangzhou.aliyuncs.com/your-namespace/datarecover
docker push registry.cn-hangzhou.aliyuncs.com/your-namespace/datarecover
```

**腾讯云容器服务**:
```bash
# 使用腾讯云容器镜像服务
docker tag datarecover-web ccr.ccs.tencentyun.com/your-namespace/datarecover
docker push ccr.ccs.tencentyun.com/your-namespace/datarecover
```

---

## 📞 技术支持

### 联系方式

- 📧 邮箱: service@zhongjindata.com
- 📞 热线: 400-668-7788
- 🌐 官网: https://wkdays.github.io/datarecover/

### 问题反馈

1. 查看日志: `./deploy.sh logs`
2. 检查状态: `./deploy.sh status`
3. 重启服务: `./deploy.sh restart`
4. 联系技术支持

---

## 📚 相关文档

- [使用指南.md](./使用指南.md) - 网站使用说明
- [闭环流程说明.md](./闭环流程说明.md) - 技术流程文档
- [导航功能说明.md](./导航功能说明.md) - 导航技术分析
- [项目总结.md](./项目总结.md) - 完整项目总结

---

**🎉 恭喜！您的网站已成功容器化部署！**

**访问地址**: http://localhost:8080  
**管理命令**: `./deploy.sh help`

---

© 2024 中晋数据科技有限公司
