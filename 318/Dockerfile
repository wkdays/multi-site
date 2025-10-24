# 使用官方Nginx镜像作为基础镜像
FROM nginx:alpine

# 设置维护者信息
LABEL maintainer="新都桥旅行 <contact@xinduqiao.com>"
LABEL description="新都桥旅行静态网站 - 高原秘境旅行指南"

# 安装必要的工具
RUN apk add --no-cache \
    curl \
    tzdata \
    && rm -rf /var/cache/apk/*

# 设置时区为中国标准时间
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 创建必要的目录并设置权限
RUN mkdir -p /var/cache/nginx/client_temp \
    /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp \
    /var/cache/nginx/uwsgi_temp \
    /var/cache/nginx/scgi_temp \
    /var/log/nginx \
    /etc/nginx/conf.d \
    /usr/share/nginx/html

# 复制网站文件到容器
COPY . /usr/share/nginx/html/

# 复制Nginx配置文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# 设置正确的文件权限和所有权
RUN chown -R nginx:nginx /usr/share/nginx/html \
    /var/cache/nginx \
    /var/log/nginx \
    /etc/nginx/conf.d && \
    chmod -R 755 /usr/share/nginx/html && \
    chmod -R 755 /var/cache/nginx && \
    chmod -R 755 /var/log/nginx && \
    chmod -R 644 /etc/nginx/conf.d/*.conf

# 创建健康检查脚本
RUN echo '#!/bin/sh' > /usr/local/bin/healthcheck.sh && \
    echo 'curl -f http://localhost/health || exit 1' >> /usr/local/bin/healthcheck.sh && \
    chmod +x /usr/local/bin/healthcheck.sh && \
    chown nginx:nginx /usr/local/bin/healthcheck.sh

# 暴露端口
EXPOSE 80

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# 启动Nginx (以root用户运行，但nginx进程会以nginx用户运行)
CMD ["nginx", "-g", "daemon off;"]
