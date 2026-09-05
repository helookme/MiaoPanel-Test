#!/bin/bash
# MiaoPanel 一键安装（一条命令：curl xxx | bash）
set -e

REPO="https://github.com/helookme/MiaoPanel-Test"
MIRROR="https://ghfast.top/https://github.com/helookme/MiaoPanel-Test"

echo "======================================"
echo "  MiaoPanel 一键安装"
echo "======================================"

cd /tmp
rm -rf mp_install mp.zip
mkdir mp_install && cd mp_install

echo "[1/3] 下载安装包..."
if curl -fSL --progress-bar --connect-timeout 10 --max-time 120 -o mp.zip "$REPO/archive/refs/heads/master.zip"; then
  echo ""
  echo "      直连 GitHub 成功"
else
  echo "      直连失败，改用镜像加速..."
  curl -fSL --progress-bar --max-time 120 -o mp.zip "$MIRROR/archive/refs/heads/master.zip"
  echo ""
  echo "      镜像下载完成"
fi

echo "[2/3] 解压..."
unzip -qo mp.zip
cd MiaoPanel-Test-master

echo "[3/3] 部署..."
chmod +x deploy.sh
./deploy.sh

cd /tmp
rm -rf mp_install
echo ""
echo "安装完成，脚本已自动清理临时文件 ✓"
