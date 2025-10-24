# 新都桥旅行网站 Docker 部署配置总结

## 📁 项目结构

```
318/
├── 📄 Dockerfile                    # 主 Dockerfile
├── 📄 docker-compose.yml           # 基础 Docker Compose 配置
├── 📄 docker-compose.dev.yml       # 开发环境配置
├── 📄 docker-compose.prod.yml      # 生产环境配置
├── 📄 nginx.conf                   # 基础 Nginx 配置
├── 📄 default.conf                 # 基础站点配置
├── 📄 .dockerignore                # Docker 忽略文件
├── 📄 Makefile                     # 便捷管理命令
├── 📄 deploy.sh                    # 部署脚本
├── 📄 env.example                  # 环境变量示例
├── 📄 DOCKER_DEPLOYMENT.md         # 详细部署指南
├── 📄 DOCKER_SUMMARY.md            # 本文件
├── 📁 config/                      # 配置文件目录
│   ├── 📄 nginx.dev.conf           # 开发环境 Nginx 配置
│   ├── 📄 nginx.prod.conf          # 生产环境 Nginx 配置
│   ├── 📄 default.dev.conf         # 开发环境站点配置
│   ├── 📄 default.prod.conf        # 生产环境站点配置
│   ├── 📄 proxy.conf               # 反向代理配置
│   └── 📄 filebeat.yml             # 日志收集配置
└── 📁 logs/                        # 日志目录
    └── 📁 nginx/                   # Nginx 日志目录
```

## 🚀 快速开始

### 1. 基础部署
```bash
# 使用部署脚本
./deploy.sh start

# 或使用 Makefile
make build && make start

# 或使用 Docker Compose
docker-compose up -d
```

### 2. 环境特定部署
```bash
# 开发环境
make dev
# 或
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# 生产环境
make prod
# 或
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## 📋 配置文件说明

### 核心配置文件

| 文件 | 用途 | 说明 |
|------|------|------|
| `Dockerfile` | 容器镜像构建 | 基于 Nginx Alpine，包含安全配置和优化 |
| `docker-compose.yml` | 基础服务配置 | 定义主服务、网络和卷 |
| `nginx.conf` | Nginx 主配置 | 基础性能和安全配置 |
| `default.conf` | 站点配置 | 基础路由和缓存策略 |

### 环境特定配置

| 文件 | 环境 | 特点 |
|------|------|------|
| `docker-compose.dev.yml` | 开发 | 端口3000，热重载，详细日志 |
| `docker-compose.prod.yml` | 生产 | 资源限制，监控，日志收集 |
| `nginx.dev.conf` | 开发 | 单进程，调试日志，短缓存 |
| `nginx.prod.conf` | 生产 | 多进程，性能优化，安全头 |

### 扩展配置

| 文件 | 用途 | 说明 |
|------|------|------|
| `config/proxy.conf` | 反向代理 | 负载均衡配置示例 |
| `config/filebeat.yml` | 日志收集 | ELK 栈集成配置 |
| `Makefile` | 管理命令 | 便捷的部署和管理命令 |
| `deploy.sh` | 部署脚本 | 自动化部署脚本 |

## 🛠️ 管理命令

### 使用 Makefile
```bash
make help          # 显示帮助
make build         # 构建镜像
make start         # 启动服务
make stop          # 停止服务
make restart       # 重启服务
make status        # 查看状态
make logs          # 查看日志
make health        # 健康检查
make test          # 运行测试
make clean         # 清理资源
```

### 使用部署脚本
```bash
./deploy.sh start              # 启动基础服务
./deploy.sh start monitoring   # 启动并启用监控
./deploy.sh logs               # 查看日志
./deploy.sh status             # 查看状态
./deploy.sh health             # 健康检查
```

### 使用 Docker Compose
```bash
# 基础操作
docker-compose up -d           # 启动服务
docker-compose down            # 停止服务
docker-compose restart         # 重启服务
docker-compose ps              # 查看状态
docker-compose logs -f         # 查看日志

# 环境特定
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## 🔧 配置特性

### 安全特性
- ✅ 非 root 用户运行
- ✅ 安全头配置
- ✅ 文件访问限制
- ✅ 请求大小限制
- ✅ 超时配置

### 性能优化
- ✅ Gzip 压缩
- ✅ 静态资源缓存
- ✅ 连接池优化
- ✅ 工作进程优化
- ✅ 缓冲区配置

### 监控和日志
- ✅ 健康检查端点
- ✅ Nginx 状态页面
- ✅ 结构化日志
- ✅ 日志轮转
- ✅ Prometheus 指标

### 开发友好
- ✅ 热重载支持
- ✅ 详细调试日志
- ✅ 开发工具集成
- ✅ 便捷管理命令

## 🌐 访问地址

### 基础服务
- **主网站**: http://localhost
- **健康检查**: http://localhost/health
- **Nginx 状态**: http://localhost/nginx_status

### 开发环境
- **主网站**: http://localhost:3000
- **开发工具**: http://localhost:8080

### 监控服务（如果启用）
- **Prometheus 指标**: http://localhost:9113/metrics

## 📊 服务架构

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   用户请求      │───▶│   Nginx 反向代理 │───▶│   静态网站      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   监控服务      │
                       │ (Prometheus)    │
                       └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   日志收集      │
                       │ (Filebeat)      │
                       └─────────────────┘
```

## 🔍 故障排除

### 常见问题

1. **端口冲突**
   ```bash
   # 检查端口占用
   netstat -tulpn | grep :80
   
   # 修改端口映射
   # 编辑 docker-compose.yml 中的 ports 配置
   ```

2. **权限问题**
   ```bash
   # 修复日志目录权限
   sudo chown -R $USER:$USER logs/
   ```

3. **容器无法启动**
   ```bash
   # 查看详细错误信息
   docker-compose logs xinduqiao-travel
   
   # 检查配置文件语法
   docker run --rm -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf nginx:alpine nginx -t
   ```

### 调试命令

```bash
# 进入容器调试
docker exec -it xinduqiao-travel-website sh

# 查看容器资源使用
docker stats xinduqiao-travel-website

# 查看网络配置
docker network ls
docker network inspect xinduqiao-travel-network
```

## 📈 性能监控

### 基础监控
```bash
# 查看服务状态
make status

# 查看资源使用
docker stats

# 健康检查
make health
```

### 高级监控（需要启用 monitoring profile）
```bash
# 启动监控服务
docker-compose --profile monitoring up -d

# 查看 Prometheus 指标
curl http://localhost:9113/metrics
```

## 🔄 更新和维护

### 更新镜像
```bash
# 使用 Makefile
make update

# 手动更新
docker-compose pull
docker-compose up -d
```

### 备份配置
```bash
# 使用 Makefile
make backup

# 手动备份
cp -r config backups/$(date +%Y%m%d_%H%M%S)/
```

### 清理资源
```bash
# 清理未使用的资源
make clean

# 清理所有资源
make clean-all
```

## 📞 技术支持

如有问题，请参考：
1. `DOCKER_DEPLOYMENT.md` - 详细部署指南
2. `Makefile` - 管理命令说明
3. `deploy.sh --help` - 部署脚本帮助

---

**注意**: 本配置已针对新都桥旅行网站进行了优化，包含完整的生产环境配置、开发环境支持和监控集成。请根据实际需求选择合适的部署方式。
