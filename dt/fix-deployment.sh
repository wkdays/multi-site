#!/bin/bash

# 修复部署脚本 - 解决端口冲突问题
# 作者: 中晋数据科技

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 修复部署问题...${NC}"

# 1. 停止所有相关容器
echo -e "${YELLOW}停止现有容器...${NC}"
docker stop zhongjin-datarecover datarecover-proxy 2>/dev/null || true
docker rm zhongjin-datarecover datarecover-proxy 2>/dev/null || true

# 2. 检查端口占用
echo -e "${YELLOW}检查端口占用...${NC}"
if netstat -tulpn 2>/dev/null | grep -q ":443"; then
    echo -e "${RED}⚠️  端口443被占用，将使用替代方案${NC}"
    echo -e "${BLUE}💡 建议：直接访问网站服务，跳过HTTPS代理${NC}"
fi

# 3. 重新构建镜像
echo -e "${YELLOW}重新构建镜像...${NC}"
docker build -f Dockerfile.simple -t zhongjin-datarecover-web .

# 4. 启动网站服务（仅HTTP，端口8080）
echo -e "${YELLOW}启动网站服务...${NC}"
docker run -d \
    --name zhongjin-datarecover \
    --restart unless-stopped \
    -p 8080:80 \
    zhongjin-datarecover-web:latest

# 5. 等待服务启动
echo -e "${YELLOW}等待服务启动...${NC}"
sleep 5

# 6. 检查服务状态
echo -e "${YELLOW}检查服务状态...${NC}"
if docker ps | grep -q zhongjin-datarecover; then
    echo -e "${GREEN}✅ 网站服务启动成功${NC}"
    echo -e "${BLUE}访问地址: http://localhost:8080${NC}"
    
    # 测试访问
    if curl -f -s http://localhost:8080 > /dev/null; then
        echo -e "${GREEN}✅ 网站访问正常${NC}"
    else
        echo -e "${YELLOW}⚠️  网站可能仍在启动中${NC}"
    fi
else
    echo -e "${RED}❌ 网站服务启动失败${NC}"
    echo -e "${YELLOW}查看日志: docker logs zhongjin-datarecover${NC}"
fi

echo -e "${GREEN}🎉 修复完成！${NC}"
echo -e "${BLUE}访问地址: http://localhost:8080${NC}"
echo -e "${BLUE}管理命令: docker logs zhongjin-datarecover${NC}"
