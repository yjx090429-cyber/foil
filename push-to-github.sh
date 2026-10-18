#!/bin/bash
# 当前文件：辅助将 Folia iOS 项目推送到 GitHub 以触发云端 IPA 构建
# 使用前请先在 https://github.com/new 创建一个空仓库（不要勾选 README/.gitignore）

set -e

cd "$(dirname "$0")"

echo "============================================"
echo "  Folia iOS - 推送到 GitHub 触发云端构建"
echo "============================================"
echo ""

# 检查 git 是否初始化
if [ ! -d ".git" ]; then
  echo "[错误] 当前目录不是 git 仓库"
  exit 1
fi

# 检查是否有未提交的改动
if [ -n "$(git status --porcelain)" ]; then
  echo "[1/3] 提交本地改动..."
  git add -A
  git commit -m "feat: add iOS Capacitor build for 爱思助手 signing" 2>/dev/null || {
    echo "[警告] 没有可提交的改动，继续..."
  }
else
  echo "[1/3] 无未提交改动，跳过 commit"
fi

echo ""
echo "[2/3] 请输入你的 GitHub 仓库地址（例如 https://github.com/你的用户名/folia-ios.git）："
read -r GITHUB_REPO

if [ -z "$GITHUB_REPO" ]; then
  echo "[错误] 未输入仓库地址"
  exit 1
fi

# 设置或更新 remote
if git remote get-url origin &>/dev/null; then
  git remote set-url origin "$GITHUB_REPO"
else
  git remote add origin "$GITHUB_REPO"
fi

echo ""
echo "[3/3] 推送到 GitHub..."
git branch -M main
git push -u origin main --force

echo ""
echo "============================================"
echo "  推送完成！"
echo "============================================"
echo ""
echo "下一步："
echo "1. 打开 $GITHUB_REPO/actions"
echo "2. 等待 'Build iOS IPA (Unsigned for 爱思助手)' 构建完成（约 10-15 分钟）"
echo "3. 点击最新一次构建 → Artifacts → 下载 Folia-unsigned-ipa"
echo "4. 解压得到 Folia-unsigned.ipa"
echo "5. 用爱思助手签名并安装到 iPhone"
echo ""
