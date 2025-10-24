# Docker权限问题快速修复

## 🚨 当前错误
```
permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock
```

## ⚡ 快速解决方案

### 方法1：运行自动修复脚本
```bash
# 给脚本执行权限
chmod +x scripts/fix-docker-permissions.sh

# 运行修复脚本
./scripts/fix-docker-permissions.sh
```

### 方法2：手动修复
```bash
# 1. 将用户添加到docker组
sudo usermod -aG docker $USER

# 2. 重新加载组权限
newgrp docker

# 3. 验证权限
docker ps
```

### 方法3：临时解决（不推荐）
```bash
# 临时修改socket权限（重启后失效）
sudo chmod 666 /var/run/docker.sock
```

## 🔧 完整解决步骤

1. **检查Docker服务状态**：
   ```bash
   sudo systemctl status docker
   ```

2. **启动Docker服务**（如果未运行）：
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

3. **添加用户到docker组**：
   ```bash
   sudo usermod -aG docker $USER
   ```

4. **重新加载组权限**：
   ```bash
   newgrp docker
   # 或者重新登录系统
   ```

5. **验证修复结果**：
   ```bash
   docker ps
   docker compose version
   ```

## 🚀 修复后可以运行的命令

```bash
# 启动服务
docker compose up -d

# 查看日志
docker compose logs

# 查看状态
docker compose ps

# 停止服务
docker compose down
```

## ⚠️ 注意事项

- 修改用户组后需要重新登录或使用 `newgrp docker`
- 不要使用 `sudo` 运行Docker命令（除非必要）
- 如果问题持续存在，请重启系统
