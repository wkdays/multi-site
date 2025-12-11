# New-API 部署指南

## 🎯 部署概述

本指南详细介绍了如何在现有 Docker 环境中部署 new-api 服务，并通过 nginx 反向代理使用域名 `newapi.yongli.wang` 进行访问。

## 📋 配置清单

### 1. Docker Compose 配置
- **服务名称**: `site-newapi`
- **镜像**: `calciumion/new-api:latest`
- **端口**: 3000 (内部)
- **数据卷**: `./new-api:/data`
- **环境变量**: `TZ=Asia/Shanghai`

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

### 日志查看
```bash
# 查看 new-api 日志
docker-compose logs -f site-newapi

# 查看 nginx 日志
docker-compose logs -f nginx
```

## 🔄 更新和维护

### 更新服务
```bash
# 拉取最新镜像
docker-compose pull site-newapi

# 重新启动服务
docker-compose up -d site-newapi
```

### 数据备份
```bash
# 备份数据目录
tar -czf new-api-backup-$(date +%Y%m%d).tar.gz new-api/
```

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