# 使用官方Nginx镜像作为基础镜像
FROM nginx:alpine

# 设置维护者信息
LABEL maintainer="珍一润珍珠粉 <service@zhenzhufen.com>"
LABEL description="珍一润珍珠粉官网 - 湛江珍珠粉美容养颜抗衰老品牌"
LABEL version="1.0.0"

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
COPY index.html /usr/share/nginx/html/
COPY assets/ /usr/share/nginx/html/assets/
COPY docs/ /usr/share/nginx/html/docs/
COPY styles.css /usr/share/nginx/html/
COPY scripts.js /usr/share/nginx/html/
COPY robots.txt /usr/share/nginx/html/
COPY sitemap.xml /usr/share/nginx/html/
COPY google8262a10223033c27.html /usr/share/nginx/html/
COPY vercel.json /usr/share/nginx/html/

# 复制自定义Nginx配置
COPY nginx.conf /etc/nginx/nginx.conf

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
