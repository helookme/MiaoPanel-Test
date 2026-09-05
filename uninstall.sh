#!/bin/bash
# MiaoPanel 一键卸载
set -e
echo "== MiaoPanel 卸载 =="

# 1. 停止并禁用服务
systemctl stop miaopanel 2>/dev/null || true
systemctl disable miaopanel 2>/dev/null || true

# 2. 删除 systemd 服务文件
rm -f /etc/systemd/system/miaopanel.service

# 3. 杀掉残留进程
pkill -x miaopanel 2>/dev/null || true

# 4. 删除安装目录与日志
rm -rf /opt/miaopanel
rm -f /tmp/mp_first.log

# 5. 刷新 systemd
systemctl daemon-reload

echo "=============================="
echo "MiaoPanel 已卸载 ✓"
echo "（/opt/miaopanel、systemd 服务、进程均已清理）"
echo "=============================="
