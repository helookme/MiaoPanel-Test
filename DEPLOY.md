# MiaoPanel 部署教程（随身WiFi Debian / 任何 Linux 通用）

## 第 0 步：把文件传到服务器

把 `miaopanel` 和 `deploy.sh` 两个文件传到服务器，任选一种方式：

```bash
# 方式 A：电脑上 scp 直传
scp miaopanel deploy.sh root@服务器IP:/tmp/

# 方式 B：手机传（用支持 SFTP/文件管理的 SSH 客户端）
# 方式 C：如果服务器能访问外网，也可以用网盘/直链下载
```

## 第 1 步：一键部署（推荐）

```bash
cd /tmp
chmod +x deploy.sh
./deploy.sh
```

脚本会自动完成：安装到 /opt/miaopanel → 生成配置 → 注册 systemd 服务 → 开机自启 → 打印初始密码。

## 第 2 步：远程访问设置

默认只监听本机（127.0.0.1），要远程访问就改配置：

```bash
nano /opt/miaopanel/miaopanel.json
```
把 `"host": "127.0.0.1"` 改成 `"host": "0.0.0.0"`，保存后：

```bash
systemctl restart miaopanel
```

## 第 3 步：防火墙放行端口

```bash
ufw allow 8080/tcp
```

## 第 4 步：登录面板

浏览器打开：`http://服务器IP:8080`

- 账号：`admin`
- 密码：部署时脚本打印的**初始密码**（或看 `/tmp/mp_first.log`）
- **登录后立刻点右上角「改密」换掉初始密码！**

## 第 5 步：日常管理命令

```bash
systemctl status miaopanel     # 看状态
systemctl restart miaopanel    # 重启
journalctl -u miaopanel -n 50  # 看日志
systemctl stop miaopanel       # 停止
systemctl disable miaopanel    # 取消开机自启
```

## 安全建议（重要）

1. **改密**：登录后立即修改初始密码
2. **不要直接暴露 8080 到公网**（面板是 HTTP 明文）：建议用 Nginx/Caddy 反向代理 + HTTPS，或者只在内网/VPN 里访问
3. 如果一定要公网直连：换一个高位端口 + 改掉 token_secret + 保持系统更新
4. 面板本身是管理工具，权限很大，保护好它 = 保护好服务器
