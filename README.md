# 多站点Docker部署项目

这是一个多站点Docker部署项目，包含两个独立的Web服务：

- **318服务**：新都桥旅行网站 (318.yongli.wang)
- **dt服务**：中晋数据科技网站 (dt.yongli.wang)

## 项目结构

```
multi-site-docker/
├── 318/                    # 新都桥旅行网站
│   ├── assets/            # 静态资源
│   ├── config/            # 配置文件
│   ├── logs/              # 日志目录
│   ├── scripts/           # 部署脚本
│   ├── traefik/           # Traefik配置
│   ├── Dockerfile         # 318服务Dockerfile
│   ├── docker-compose.yml # 318服务编排文件
│   └── deploy.sh          # 318服务部署脚本
├── dt/                     # 中晋数据科技网站
│   ├── assets/            # 静态资源
│   ├── monitoring/        # 监控配置
│   ├── proxy/             # 代理配置
│   ├── Dockerfile         # dt服务Dockerfile
│   ├── docker-compose.yml # dt服务编排文件
│   └── deploy.sh          # dt服务部署脚本
├── nginx/                  # 根目录nginx配置
├── docker-compose.yml     # 根目录统一编排文件
├── nginx.conf             # 根目录nginx配置
└── README.md              # 项目说明
```

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/wkdays/multi-site.git
cd multi-site
```

### 2. 部署方式

#### 方式一：统一部署（推荐）

```bash
# 使用根目录docker-compose.yml统一部署
docker-compose up -d
```

#### 方式二：独立部署

```bash
# 部署318服务
cd 318
./deploy.sh start

# 部署dt服务
cd dt
./deploy.sh run
```

## 服务访问

- **318服务**：http://318.yongli.wang
- **dt服务**：http://dt.yongli.wang
- **本地访问**：
  - 318服务：http://localhost
  - dt服务：http://localhost:8080

## 功能特性

### 318服务（新都桥旅行）
- ✅ 静态网站服务
- ✅ Nginx优化配置
- ✅ Gzip压缩
- ✅ 静态资源缓存
- ✅ 安全头配置
- ✅ 健康检查
- ✅ Traefik自动HTTPS
- ✅ 监控指标

### dt服务（中晋数据科技）
- ✅ 企业级数据恢复网站
- ✅ 响应式设计
- ✅ 静态资源优化
- ✅ 健康检查
- ✅ 监控配置

## 技术栈

- **容器化**：Docker + Docker Compose
- **Web服务器**：Nginx Alpine
- **反向代理**：Traefik
- **SSL证书**：Let's Encrypt自动申请
- **监控**：Prometheus + Grafana
- **日志**：Nginx访问日志

## 部署要求

- Docker 20.10+
- Docker Compose 2.0+
- 至少1GB内存
- 至少2GB磁盘空间

## 域名配置

确保以下域名解析到服务器IP：
- `318.yongli.wang` → 服务器IP
- `dt.yongli.wang` → 服务器IP

## SSL证书

项目支持自动SSL证书申请：
- 使用Let's Encrypt免费证书
- Traefik自动申请和续期
- 支持HTTPS重定向

## 监控和日志

### 健康检查
```bash
# 318服务
curl http://318.yongli.wang/health

# dt服务
curl http://dt.yongli.wang/health
```

### 查看日志
```bash
# 318服务日志
cd 318
./deploy.sh logs

# dt服务日志
cd dt
./deploy.sh logs
```

## 管理命令

### 318服务管理
```bash
cd 318

# 启动服务
./deploy.sh start

# 停止服务
./deploy.sh stop

# 重启服务
./deploy.sh restart

# 查看状态
./deploy.sh status

# 查看日志
./deploy.sh logs

# 健康检查
./deploy.sh health
```

### dt服务管理
```bash
cd dt

# 构建并运行
./deploy.sh run

# 停止服务
./deploy.sh stop

# 重启服务
./deploy.sh restart

# 查看状态
./deploy.sh status

# 查看日志
./deploy.sh logs
```

## 故障排除

### 常见问题

1. **端口冲突**
   ```bash
   # 检查端口占用
   netstat -tulpn | grep :80
   ```

2. **域名无法访问**
   ```bash
   # 检查DNS解析
   nslookup 318.yongli.wang
   nslookup dt.yongli.wang
   ```

3. **SSL证书问题**
   ```bash
   # 检查Traefik日志
   docker-compose logs traefik
   ```

### 调试命令

```bash
# 进入容器调试
docker exec -it <container-name> sh

# 查看容器状态
docker ps -a

# 查看网络配置
docker network ls
```

## 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 联系方式

- 项目维护者：yongli.wang
- 邮箱：admin@yongli.wang
- GitHub：https://github.com/wkdays/multi-site

---

**注意**：部署前请确保服务器满足系统要求，并正确配置域名解析。
