# MiaoPanel · 极致轻量服务器运维面板

面向低配设备（随身WiFi/树莓派/老机器）的运维面板。单二进制、无依赖、前端内嵌。

## 特性
- Go 单二进制（约 6.5MB），内存占用 10MB 以内
- 系统监控：CPU / 内存 / 磁盘 / 网络 / 负载 / 运行时间（2 秒实时刷新）
- 进程管理：列表、状态、内存、结束进程
- 服务管理：systemd 服务启停/重启
- 文件管理：目录浏览 / 文本编辑 / 新建 / 删除
- Web 终端：xterm.js 真终端（内嵌，无 CDN 依赖）
- 登录鉴权：bcrypt 密码 + HMAC 签名 token（24 小时有效）
- 修改密码：面板内一键修改
- 手机端适配：响应式布局
- 一键部署 / 一键卸载
- 深色 UI，原生 JS 零依赖（xterm 除外，已内嵌）

## 部署
```bash
# 1. 上传 miaopanel 到服务器（arm64 版本）
chmod +x miaopanel

# 2. 首次运行（自动生成 miaopanel.json 并打印初始密码）
./miaopanel

# 3. 浏览器访问
#    本机:  http://127.0.0.1:8080
#    远程:  修改 miaopanel.json 中 host 为 0.0.0.0 后重启，访问 http://服务器IP:8080
# 4. 登录后立即修改密码
```

## 配置（miaopanel.json）
```json
{
  "host": "127.0.0.1",
  "port": "8080",
  "username": "admin",
  "password": "$2a$10$...",
  "token_secret": "..."
}
```
- host：监听地址，远程访问改为 0.0.0.0
- password：bcrypt 哈希（面板内改密即可，无需手改）

## 作为 systemd 服务（推荐）
```bash
mkdir -p /opt/miaopanel && cp miaopanel /opt/miaopanel/

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

systemctl daemon-reload && systemctl enable --now miaopanel
```

## 安全建议
- 远程访问建议配合 Nginx 反向代理 + HTTPS（面板本身只做 HTTP）
- 防火墙只放行必要端口
- 默认监听 127.0.0.1，非必要不暴露公网
