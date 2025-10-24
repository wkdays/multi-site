# 318.yongli.wang 域名部署指南

## 🌐 域名配置

您的网站域名已配置为：**318.yongli.wang**

## 📋 部署步骤

### 1. DNS 配置

确保您的域名 DNS 记录指向服务器：

```bash
# A 记录
318.yongli.wang    A    YOUR_SERVER_IP

# 或者 CNAME 记录（如果使用 CDN）
318.yongli.wang    CNAME    your-cdn-domain.com
```

### 2. 本地测试

```bash
# 启动服务
./deploy.sh start

# 健康检查
./deploy.sh health

# 访问测试
curl -H "Host: 318.yongli.wang" http://localhost/
```

### 3. 生产环境部署

#### 使用 Traefik（推荐）

```bash
# 启动生产环境（自动 HTTPS）
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

Traefik 将自动：
- 申请 Let's Encrypt SSL 证书
- 配置 HTTPS 重定向
- 设置安全头

#### 使用 Nginx 反向代理

```bash
# 使用自定义域名配置
docker-compose -f docker-compose.yml up -d

# 配置 Nginx 反向代理
cp config/nginx.domain.conf /etc/nginx/sites-available/318.yongli.wang
ln -s /etc/nginx/sites-available/318.yongli.wang /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

## 🔧 配置说明

### 已更新的配置文件

1. **docker-compose.yml** - Traefik 路由规则
2. **docker-compose.prod.yml** - 生产环境域名配置
3. **config/nginx.domain.conf** - 域名专用 Nginx 配置
4. **env.example** - 环境变量更新

### 域名相关配置

```yaml
# Traefik 标签
labels:
  - "traefik.http.routers.xinduqiao.rule=Host(`318.yongli.wang`)"
  - "traefik.http.routers.xinduqiao.entrypoints=websecure"
  - "traefik.http.routers.xinduqiao.tls.certresolver=letsencrypt"
```

## 🚀 快速部署

### 开发环境
```bash
# 本地开发
make dev
# 访问: http://localhost:3000
```

### 生产环境
```bash
# 生产部署
make prod
# 访问: https://318.yongli.wang
```

## 🔍 验证部署

### 1. DNS 解析测试
```bash
# 检查 DNS 解析
nslookup 318.yongli.wang
dig 318.yongli.wang
```

### 2. HTTP 响应测试
```bash
# 测试 HTTP 响应
curl -I http://318.yongli.wang/
curl -I https://318.yongli.wang/
```

### 3. SSL 证书检查
```bash
# 检查 SSL 证书
openssl s_client -connect 318.yongli.wang:443 -servername 318.yongli.wang
```

## 📊 监控和日志

### 访问日志
```bash
# 查看访问日志
tail -f logs/nginx/access.log | grep "318.yongli.wang"
```

### 健康检查
```bash
# 检查服务状态
curl https://318.yongli.wang/health
```

### 监控指标
```bash
# 查看 Prometheus 指标（如果启用监控）
curl https://metrics.318.yongli.wang/metrics
```

## 🔧 故障排除

### 常见问题

1. **域名无法访问**
   ```bash
   # 检查 DNS 解析
   nslookup 318.yongli.wang
   
   # 检查服务状态
   docker-compose ps
   ```

2. **SSL 证书问题**
   ```bash
   # 检查 Traefik 日志
   docker-compose logs traefik
   
   # 手动申请证书
   docker-compose exec traefik traefik-certs-dumper
   ```

3. **403/404 错误**
   ```bash
   # 检查 Nginx 配置
   docker-compose exec xinduqiao-travel-website nginx -t
   
   # 查看错误日志
   docker-compose logs xinduqiao-travel
   ```

### 调试命令

```bash
# 进入容器调试
docker exec -it xinduqiao-travel-website sh

# 检查网络连接
docker network ls
docker network inspect xinduqiao-travel-network

# 查看 Traefik 配置
docker-compose logs traefik | grep "318.yongli.wang"
```

## 📈 性能优化

### CDN 配置（可选）

如果使用 CDN，建议配置：

```bash
# 更新 DNS 记录
318.yongli.wang    CNAME    your-cdn-domain.com

# 配置 CDN 缓存规则
# - HTML: 1小时
# - CSS/JS: 1年
# - 图片: 1年
```

### 缓存策略

```nginx
# 静态资源缓存
location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## 🔒 安全配置

### SSL/TLS 配置

- ✅ 自动 HTTPS 重定向
- ✅ Let's Encrypt 证书
- ✅ HSTS 安全头
- ✅ 安全传输协议

### 安全头配置

```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
```

## 📞 技术支持

如果遇到问题，请检查：

1. **DNS 配置** - 确保域名正确解析
2. **防火墙设置** - 确保 80/443 端口开放
3. **SSL 证书** - 检查证书是否有效
4. **服务状态** - 使用 `make status` 检查

---

**注意**: 域名配置完成后，建议等待 DNS 传播（通常 5-30 分钟），然后进行访问测试。
