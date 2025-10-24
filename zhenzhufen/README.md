# 珍一润珍珠粉官网

珍一润珍珠粉官网 - 湛江珍珠粉美容养颜抗衰老品牌

## 项目简介

珍一润珍珠粉官网是一个展示湛江珍珠粉品牌的专业网站，提供珍珠粉产品介绍、功效说明、使用方法等信息。

## 功能特性

- ✅ 响应式设计，支持移动端访问
- ✅ 静态网站服务
- ✅ Nginx优化配置
- ✅ Gzip压缩
- ✅ 静态资源缓存
- ✅ 安全头配置
- ✅ 健康检查
- ✅ SEO优化

## 技术栈

- **前端**: HTML5, CSS3, JavaScript
- **服务器**: Nginx Alpine
- **容器化**: Docker + Docker Compose
- **部署**: 自动化部署脚本

## 快速开始

### 1. 独立部署

```bash
cd zhenzhufen
./deploy.sh start
```

### 2. 统一部署

```bash
# 在根目录
docker-compose up -d
```

## 访问地址

- **本地访问**: http://localhost:8080
- **生产环境**: https://zhenzhufen.yongli.wang
- **健康检查**: http://localhost:8080/health

## 部署要求

- Docker 20.10+
- Docker Compose 2.0+
- 至少512MB内存
- 至少1GB磁盘空间

## 管理命令

```bash
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

## 项目结构

```
zhenzhufen/
├── assets/              # 静态资源
├── docs/                # 文档目录
├── src/                 # 源码目录
├── Dockerfile           # Docker配置
├── docker-compose.yml   # 服务编排
├── nginx.conf          # Nginx配置
├── deploy.sh           # 部署脚本
├── index.html          # 主页面
├── styles.css          # 样式文件
├── scripts.js          # 脚本文件
├── robots.txt          # 搜索引擎配置
├── sitemap.xml         # 站点地图
└── README.md           # 项目说明
```

## 域名配置

确保以下域名解析到服务器IP：

- `zhenzhufen.yongli.wang` → 服务器IP

## 监控和日志

### 健康检查

```bash
curl http://localhost:8080/health
```

### 查看日志

```bash
# 查看服务日志
./deploy.sh logs

# 查看Nginx日志
tail -f logs/nginx/access.log
tail -f logs/nginx/error.log
```

## 故障排除

### 常见问题

1. **端口冲突**
   ```bash
   # 检查端口占用
   netstat -tulpn | grep :8080
   ```

2. **容器无法启动**
   ```bash
   # 查看详细错误信息
   ./deploy.sh logs
   ```

3. **域名无法访问**
   ```bash
   # 检查DNS解析
   nslookup zhenzhufen.yongli.wang
   ```

## 联系支持

- 项目维护者：yongli.wang
- 邮箱：admin@yongli.wang
- GitHub：https://github.com/wkdays/multi-site

---

**注意**: 部署前请确保服务器满足系统要求，并正确配置域名解析。