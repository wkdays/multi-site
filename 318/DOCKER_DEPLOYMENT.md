# 新都桥旅行网站 Docker 部署指南

## 项目简介

新都桥旅行网站是一个展示川藏线最美风景、藏式美食、精品民宿与交通攻略的静态网站。本项目已配置完整的Docker部署环境，支持快速部署和扩展。

## 系统要求

- Docker 20.10+
- Docker Compose 2.0+
- 至少 512MB 可用内存
- 至少 1GB 可用磁盘空间

## 快速开始

### 1. 克隆项目

```bash
git clone <repository-url>
cd 318
```

### 2. 构建并启动服务

```bash
# 构建并启动主服务
docker-compose up -d xinduqiao-travel

# 或者构建并启动所有服务（包括代理和监控）
docker-compose --profile proxy --profile monitoring up -d
```

### 3. 访问网站

- 主网站: http://localhost
- 生产环境: https://318.yongli.wang
- 代理服务: http://localhost:8080 (如果启用了proxy profile)
- 监控指标: http://localhost:9113/metrics (如果启用了monitoring profile)

## 详细配置

### 服务说明

#### 主服务 (xinduqiao-travel)
- **端口**: 80
- **功能**: 提供静态网站服务
- **技术栈**: Nginx + Alpine Linux
- **健康检查**: 每30秒检查一次

#### 代理服务 (nginx-proxy)
- **端口**: 8080
- **功能**: 反向代理，支持负载均衡
- **启动方式**: `docker-compose --profile proxy up -d`

#### 监控服务 (nginx-exporter)
- **端口**: 9113
- **功能**: 提供Prometheus监控指标
- **启动方式**: `docker-compose --profile monitoring up -d`

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| TZ | Asia/Shanghai | 时区设置 |
| NGINX_ENVSUBST_TEMPLATE_DIR | /etc/nginx/templates | Nginx模板目录 |
| NGINX_ENVSUBST_OUTPUT_DIR | /etc/nginx/conf.d | Nginx配置输出目录 |

### 数据卷

- `./logs/nginx:/var/log/nginx` - Nginx日志持久化
- `./config/nginx.conf:/etc/nginx/nginx.conf` - 自定义Nginx主配置
- `./config/default.conf:/etc/nginx/conf.d/default.conf` - 自定义站点配置

## 部署选项

### 开发环境

```bash
# 启动基础服务
docker-compose up -d

# 查看日志
docker-compose logs -f xinduqiao-travel
```

### 生产环境

```bash
# 启动所有服务（包括监控）
docker-compose --profile monitoring up -d

# 设置重启策略
docker-compose up -d --restart unless-stopped
```

### 使用Traefik（推荐）

如果使用Traefik作为反向代理，服务已预配置相关标签：

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.xinduqiao.rule=Host(`xinduqiao.local`)"
  - "traefik.http.routers.xinduqiao.entrypoints=web"
```

## 常用命令

### 服务管理

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f [service-name]
```

### 镜像管理

```bash
# 重新构建镜像
docker-compose build --no-cache

# 拉取最新镜像
docker-compose pull

# 清理未使用的镜像
docker system prune -a
```

### 数据管理

```bash
# 备份日志
docker cp xinduqiao-travel-website:/var/log/nginx ./backup/

# 查看容器资源使用
docker stats xinduqiao-travel-website

# 进入容器
docker exec -it xinduqiao-travel-website sh
```

## 性能优化

### Nginx配置优化

1. **启用Gzip压缩**: 已默认启用，压缩CSS、JS、HTML等文件
2. **静态资源缓存**: 图片、字体等资源缓存1年
3. **安全头设置**: 已配置XSS保护、内容类型检查等安全头

### 容器优化

1. **多阶段构建**: 使用Alpine Linux减小镜像大小
2. **非root用户**: 使用nginx用户运行服务
3. **健康检查**: 自动检测服务状态

## 监控和日志

### 日志位置

- 访问日志: `./logs/nginx/access.log`
- 错误日志: `./logs/nginx/error.log`

### 监控指标

如果启用了monitoring profile，可以通过以下端点获取监控数据：

- Prometheus指标: http://localhost:9113/metrics
- 健康检查: http://localhost/health

### 日志分析

```bash
# 实时查看访问日志
tail -f logs/nginx/access.log

# 统计访问量
grep "$(date '+%d/%b/%Y')" logs/nginx/access.log | wc -l

# 查看错误日志
tail -f logs/nginx/error.log
```

## 故障排除

### 常见问题

1. **端口冲突**
   ```bash
   # 检查端口占用
   netstat -tulpn | grep :80
   
   # 修改端口映射
   # 编辑docker-compose.yml中的ports配置
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

### 调试模式

```bash
# 以调试模式启动
docker-compose -f docker-compose.yml -f docker-compose.debug.yml up

# 进入容器调试
docker exec -it xinduqiao-travel-website sh
```

## 安全建议

1. **定期更新**: 定期更新基础镜像和依赖
2. **最小权限**: 使用非root用户运行服务
3. **网络安全**: 配置防火墙规则，限制不必要的端口访问
4. **SSL/TLS**: 生产环境建议配置HTTPS
5. **备份策略**: 定期备份配置文件和日志

## 扩展功能

### 添加HTTPS支持

1. 准备SSL证书
2. 修改Nginx配置添加SSL配置
3. 更新docker-compose.yml端口映射

### 集成CDN

1. 配置CDN域名
2. 修改静态资源URL
3. 更新缓存策略

### 多环境部署

```bash
# 开发环境
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# 生产环境
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## 联系支持

如有问题，请联系：
- 技术支持: tech@xinduqiao.com
- 项目维护者: maintainer@xinduqiao.com

---

**注意**: 本部署指南基于Docker和Docker Compose，确保在生产环境中进行充分测试后再部署。
