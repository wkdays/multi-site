# 新都桥旅行网站

> 高原秘境静态旅行指南 - 探索川藏线最美风景

## 🌟 项目简介

新都桥旅行网站是一个展示川藏线最美风景、藏式美食、精品民宿与交通攻略的静态网站。项目采用现代化的设计理念，结合Docker容器化部署，提供完整的开发和生产环境支持。

## 🚀 快速开始

### 环境要求

- Docker 20.10+
- Docker Compose 2.0+
- 至少 512MB 可用内存
- 至少 1GB 可用磁盘空间

### 一键部署

```bash
# 克隆项目
git clone <repository-url>
cd 318

# 启动服务
./deploy.sh start

# 访问网站
open http://localhost
```

### 使用 Makefile

```bash
# 构建并启动
make build && make start

# 查看状态
make status

# 查看日志
make logs
```

## 🌐 访问地址

- **本地开发**: http://localhost
- **生产环境**: https://318.yongli.wang
- **健康检查**: http://localhost/health

## 📁 项目结构

```
318/
├── 📄 index.html              # 主页面
├── 📁 assets/                 # 静态资源
│   ├── 📁 css/               # 样式文件
│   ├── 📁 js/                # JavaScript 文件
│   └── 📁 images/            # 图片资源
├── 📄 Dockerfile             # Docker 镜像配置
├── 📄 docker-compose.yml     # 基础服务编排
├── 📄 docker-compose.dev.yml # 开发环境配置
├── 📄 docker-compose.prod.yml# 生产环境配置
├── 📄 docker-compose.traefik.yml # Traefik 配置
├── 📁 config/                # 配置文件目录
├── 📁 scripts/               # 管理脚本
├── 📁 traefik/               # Traefik 配置
├── 📄 Makefile               # 便捷命令
├── 📄 deploy.sh              # 部署脚本
└── 📁 logs/                  # 日志目录
```

## 🛠️ 管理命令

### 基础操作

```bash
# 启动服务
./deploy.sh start
make start

# 停止服务
./deploy.sh stop
make stop

# 重启服务
./deploy.sh restart
make restart

# 查看状态
./deploy.sh status
make status
```

### 环境管理

```bash
# 开发环境
make dev
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# 生产环境
make prod
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 使用 Traefik（自动 HTTPS）
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml up -d
```

### 监控和维护

```bash
# 健康检查
./deploy.sh health
make health

# 查看日志
./deploy.sh logs
make logs

# 备份数据
./scripts/backup.sh

# 监控服务
./scripts/monitor.sh

# SSL 证书设置
./scripts/ssl-setup.sh
```

## 🔧 配置说明

### 环境变量

复制 `env.example` 为 `.env` 并根据需要修改：

```bash
cp env.example .env
```

主要配置项：
- `SITE_DOMAIN`: 网站域名 (318.yongli.wang)
- `TZ`: 时区设置 (Asia/Shanghai)
- `LOG_LEVEL`: 日志级别 (warn)

### Nginx 配置

- `nginx.conf`: 主配置文件
- `default.conf`: 基础站点配置
- `config/nginx.dev.conf`: 开发环境配置
- `config/nginx.prod.conf`: 生产环境配置

### Docker 配置

- `Dockerfile`: 基于 Nginx Alpine 的容器镜像
- `docker-compose.yml`: 基础服务编排
- `docker-compose.dev.yml`: 开发环境（端口 3000）
- `docker-compose.prod.yml`: 生产环境（资源限制、监控）
- `docker-compose.traefik.yml`: Traefik 自动 HTTPS

## 🔒 SSL/HTTPS 配置

### 使用 Traefik（推荐）

```bash
# 启动 Traefik 自动 HTTPS
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml up -d

# 访问 https://318.yongli.wang
```

### 手动配置 SSL

```bash
# 申请 Let's Encrypt 证书
./scripts/ssl-setup.sh manual

# 配置 Nginx SSL
./scripts/ssl-setup.sh nginx
```

## 📊 监控和日志

### 健康检查

```bash
# 检查服务状态
curl http://localhost/health

# 检查 Nginx 状态
curl http://localhost/nginx_status
```

### 日志查看

```bash
# 查看访问日志
tail -f logs/nginx/access.log

# 查看错误日志
tail -f logs/nginx/error.log

# 查看容器日志
docker-compose logs -f xinduqiao-travel
```

### 监控脚本

```bash
# 检查服务状态
./scripts/monitor.sh status

# 连续监控
./scripts/monitor.sh monitor 60

# 生成监控报告
./scripts/monitor.sh report
```

## 🔄 备份和恢复

### 自动备份

```bash
# 完整备份
./scripts/backup.sh full

# 仅备份配置
./scripts/backup.sh config

# 清理旧备份
./scripts/backup.sh cleanup 7
```

### 手动备份

```bash
# 使用 Makefile
make backup

# 备份到指定目录
cp -r . /backup/xinduqiao-$(date +%Y%m%d)
```

## 🚀 部署到生产环境

### 1. 服务器准备

```bash
# 安装 Docker 和 Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 安装 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. 域名配置

```bash
# 设置 DNS 记录
318.yongli.wang    A    YOUR_SERVER_IP
```

### 3. 部署服务

```bash
# 克隆项目
git clone <repository-url>
cd 318

# 生产环境部署
make prod

# 或使用 Traefik 自动 HTTPS
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml up -d
```

### 4. 验证部署

```bash
# 健康检查
curl https://318.yongli.wang/health

# 检查 SSL 证书
openssl s_client -connect 318.yongli.wang:443 -servername 318.yongli.wang
```

## 🔧 故障排除

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

### 调试模式

```bash
# 进入容器调试
docker exec -it xinduqiao-travel-website sh

# 查看容器资源使用
docker stats xinduqiao-travel-website

# 查看网络配置
docker network inspect xinduqiao-travel-network
```

## 📈 性能优化

### 已实现的优化

- ✅ Gzip 压缩
- ✅ 静态资源缓存
- ✅ 连接池优化
- ✅ 工作进程优化
- ✅ 安全头配置

### 进一步优化建议

1. **CDN 集成**
   ```bash
   # 配置 CDN 域名
   318.yongli.wang    CNAME    your-cdn-domain.com
   ```

2. **图片优化**
   ```bash
   # 使用 WebP 格式
   # 配置图片压缩
   ```

3. **缓存策略**
   ```nginx
   # 配置更长的缓存时间
   location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
       expires 1y;
       add_header Cache-Control "public, immutable";
   }
   ```

## 🤝 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 技术支持

- **项目维护者**: maintainer@xinduqiao.com
- **技术支持**: tech@xinduqiao.com
- **问题反馈**: [GitHub Issues](https://github.com/your-repo/issues)

## 🙏 致谢

- [Nginx](https://nginx.org/) - Web 服务器
- [Docker](https://www.docker.com/) - 容器化平台
- [Traefik](https://traefik.io/) - 反向代理
- [Let's Encrypt](https://letsencrypt.org/) - SSL 证书

---

**注意**: 本网站仅用于展示新都桥旅行信息，请确保在生产环境中进行充分测试后再部署。
