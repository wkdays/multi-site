# New-API 配置说明

此目录用于 new-api 服务的数据持久化存储。

## 服务信息
- **镜像**: calciumion/new-api:latest
- **端口**: 3000
- **域名**: newapi.yongli.wang
- **数据目录**: ./new-api

## 环境变量
- **TZ**: Asia/Shanghai (时区设置)

## 启动命令
```bash
docker-compose up -d site-newapi
```

## 访问地址
- 管理界面: http://newapi.yongli.wang

## 数据备份
此目录下的文件为 new-api 的数据文件，建议定期备份。