[中文版]
S-UI for Alpine Linux
这是一个专门为 Alpine Linux (特别是 LXC 架构的 NAT VPS) 深度适配的 S-UI 面板安装脚本。

🚀 项目特点
完全适配 Alpine：彻底解决了原生脚本因缺少 systemctl 而在 Alpine 上安装失败的问题。

运行环境补全：自动安装 gcompat 兼容库，让基于 glibc 的二进制文件在 Alpine 上完美运行。

全交互配置：安装过程中可一键设置面板端口、路径、订阅端口、路径及管理员凭据。

持久化管理菜单：重写了 s-ui 管理命令，支持循环操作界面，适配 Alpine 进程管理逻辑。

自动启动：基于 Alpine 的 local.d 机制实现服务开机自启动，无需手动拉起。

🛠️ 安装方法
在你的 Alpine 终端执行以下一键命令：


apk add --no-cache bash && wget -N --no-check-certificate https://raw.githubusercontent.com/wangkewdg2/S-UI-for-alpine/main/install.sh && chmod +x install.sh && bash install.sh
📖 使用说明
安装完成后，在终端输入以下命令即可进入循环管理菜单：


s-ui


支持的操作：

启动 / 停止 / 重启面板

修改管理员用户名及密码

批量修改面板与订阅的端口及路径

实时查看运行日志 (tail -f)

[English Version]
S-UI for Alpine Linux
A dedicated S-UI panel installation script deeply optimized for Alpine Linux (especially NAT VPS based on LXC architecture).

🚀 Features
Alpine Native Support: Completely resolves the "systemctl not found" error that occurs with original scripts.

Environment Completion: Automatically installs gcompat to ensure glibc-based binaries run flawlessly on Alpine.

Interactive Configuration: Customize panel/subscription ports, paths, and admin credentials during the installation process.

Persistent Management Menu: A rewritten s-ui command featuring a loop-based UI, fully compatible with Alpine's process management.

Auto-Start: Implements service persistence via Alpine's local.d mechanism, ensuring the panel starts on boot.

🛠️ Installation
Run the following command in your Alpine terminal:

apk add --no-cache bash && wget -N --no-check-certificate https://raw.githubusercontent.com/wangkewdg2/S-UI-for-alpine/main/install.sh && chmod +x install.sh && bash install.sh

📖 Usage
After installation, simply type the following command to manage your panel:

s-ui
Supported Operations:

Start / Stop / Restart the panel.

Modify administrator username and password.

Update panel and subscription ports/paths.

View real-time logs (tail -f).

⚠️ NAT VPS Tips / 贴士
Port Mapping: Ensure the Internal Port you set during installation matches the forwarding rule in your VPS dashboard.

Access URL: Use the format http://Public_IP:Mapped_Port/Your_Path/ to access the web UI.

Firewall: If you can't access the panel, try clearing the rules with iptables -F.
