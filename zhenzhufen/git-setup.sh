#!/bin/bash

# Git 远程仓库设置脚本
# 请在使用前修改下面的仓库URL

echo "=== ZhenZhuFen 项目 Git 设置脚本 ==="
echo ""

# 检查是否已配置远程仓库
if git remote -v | grep -q "origin"; then
    echo "✅ 远程仓库已配置："
    git remote -v
    echo ""
    echo "如果要推送到远程仓库，请运行："
    echo "git push -u origin main"
else
    echo "❌ 未配置远程仓库"
    echo ""
    echo "请按以下步骤操作："
    echo ""
    echo "1. 在 GitHub/GitLab/Bitbucket 上创建新仓库"
    echo "2. 复制仓库的 HTTPS URL"
    echo "3. 运行以下命令添加远程仓库："
    echo "   git remote add origin <你的仓库URL>"
    echo ""
    echo "4. 推送到远程仓库："
    echo "   git push -u origin main"
    echo ""
    echo "示例："
    echo "   git remote add origin https://github.com/用户名/zhenzhufen.git"
    echo "   git push -u origin main"
fi

echo ""
echo "=== 当前项目状态 ==="
echo "分支：$(git branch --show-current)"
echo "最新提交：$(git log -1 --pretty=format:'%h - %s (%cr) <%an>')"
echo "文件数量：$(git ls-files | wc -l)"
