#!/bin/bash
# MiaoPanel 一键部署（像 1Panel 一样：一条命令装完，直接可访问）
# 用法：把 miaopanel 和本脚本放到同一目录，然后 ./deploy.sh
set -e

echo "== MiaoPanel 一键部署 =="

# 1. 检查二进制
if [ ! -f ./miaopanel ]; then
  echo "错误：当前目录没有 miaopanel 文件，请先上传。"
  exit 1
fi

# 2. 安装到 /opt/miaopanel
mkdir -p /opt/miaopanel
cp -f miaopanel /opt/miaopanel/
chmod +x /opt/miaopanel/miaopanel

# 3. 清理残留进程（防止端口冲突）
pkill -x miaopanel 2>/dev/null || true
sleep 0.5

# 4. 首次运行生成配置（等 4 秒确保密码打印出来，低配设备 bcrypt 较慢）
cd /opt/miaopanel
if [ ! -f miaopanel.json ]; then
  echo "首次运行，生成配置（请稍候）..."
  ./miaopanel > /tmp/mp_first.log 2>&1 &
  sleep 4
  kill %1 2>/dev/null || true
  sleep 0.5
fi

# 5. 提取初始密码（通用正则，不依赖 grep -P）
PASS=$(grep -oE '密码 [0-9a-f]+' /tmp/mp_first.log 2>/dev/null | head -1 | awk '{print $2}')

# 6. 写入 systemd 服务
cat > /etc/systemd/system/miaopanel.service << 'SVC'
[Unit]
Description=MiaoPanel
After=network.target

[Service]
ExecStart=/opt/miaopanel/miaopanel
WorkingDirectory=/opt/miaopanel
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
SVC

systemctl daemon-reload
systemctl enable miaopanel > /dev/null 2>&1 || true
systemctl restart miaopanel
sleep 1

# 7. 防火墙放行（如果有 ufw）
if command -v ufw > /dev/null 2>&1; then
  ufw allow 8080/tcp > /dev/null 2>&1 || true
fi

# 8. 输出结果
IP=$(hostname -I 2>/dev/null | awk '{print $1}')
echo ""
echo "=============================="
echo "  MiaoPanel 部署完成！"
echo "=============================="
echo "访问地址: http://$IP:8080"
echo "账号:     admin"
if [ -n "$PASS" ]; then
  echo "初始密码: $PASS"
  echo "（登录后请立即在面板右上角「改密」修改！）"
else
  echo "初始密码: 看日志 /tmp/mp_first.log；若没有，删掉 /opt/miaopanel/miaopanel.json 再跑一次本脚本"
fi
if systemctl is-active --quiet miaopanel; then
  echo "服务状态: 运行中 ✓"
else
  echo "服务状态: 异常，看日志: journalctl -u miaopanel -n 30"
fi
echo "=============================="
