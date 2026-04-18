#!/bin/bash

# 颜色定义
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# 检查 root 权限
[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 请使用 root 用户运行 \n " && exit 1

# 架构检测
arch() {
    case "$(uname -m)" in
    x86_64 | x64 | amd64) echo 'amd64' ;;
    armv8* | armv8 | arm64 | aarch64) echo 'arm64' ;;
    *) echo -e "${red}不支持的 CPU 架构! ${plain}" && exit 1 ;;
    esac
}

# 1. 安装基础依赖
install_base() {
    echo -e "${yellow}正在安装 Alpine 必要依赖...${plain}"
    apk update
    apk add --no-cache wget curl tar tzdata ca-certificates libc6-compat gcompat
}

# 2. 生成适配 Alpine 的循环管理脚本
generate_menu_script() {
    cat > /usr/local/s-ui/s-ui.sh << 'EOF'
#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

check_status() {
    if ps | grep -v grep | grep -q "sui"; then return 0; else return 1; fi
}

while true; do
    echo -e "\n--- ${yellow}S-UI Alpine 管理脚本 (适配版)${plain} ---"
    if check_status; then
        echo -e "状态: ${green}运行中${plain}"
    else
        echo -e "状态: ${red}停止${plain}"
    fi
    echo "--------------------------------"
    echo "1. 安装 / 2. 更新 / 4. 卸载"
    echo "--------------------------------"
    echo "6. 设置管理员账号 / 7. 查看账号"
    echo "9. 设置面板/订阅设置 / 10. 查看当前设置"
    echo "--------------------------------"
    echo "11. 启动 / 12. 停止 / 13. 重启"
    echo "15. 查看日志"
    echo "--------------------------------"
    echo "0. 退出"
    echo "--------------------------------"
    read -p "选择 [0-20]: " choice
    
    case $choice in
        0) exit 0 ;;
        6) read -p "用户:" u; read -p "密码:" p; /usr/local/s-ui/sui admin -username $u -password $p ;;
        7) /usr/local/s-ui/sui admin -show ;;
        9) 
            read -p "面板端口:" pt; read -p "面板路径:" ph
            [[ ! $ph =~ ^/ ]] && ph="/$ph"
            [[ ! $ph =~ /$ ]] && ph="$ph/"
            read -p "订阅端口:" spt; read -p "订阅路径:" sph
            [[ ! $sph =~ ^/ ]] && sph="/$sph"
            [[ ! $sph =~ /$ ]] && sph="$sph/"
            /usr/local/s-ui/sui setting -port $pt -path $ph -subPort $spt -subPath $sph
            echo -e "${green}设置已更新，请重启面板生效${plain}" 
            ;;
        10) /usr/local/s-ui/sui setting -show ;;
        11) nohup /usr/local/s-ui/sui > /usr/local/s-ui/s-ui.log 2>&1 & echo -e "${green}服务已启动${plain}" ;;
        12) pkill -9 sui; echo -e "${red}服务已停止${plain}" ;;
        13) pkill -9 sui; sleep 1; nohup /usr/local/s-ui/sui > /usr/local/s-ui/s-ui.log 2>&1 & echo -e "${green}服务已重启${plain}" ;;
        15) echo -e "${yellow}按 Ctrl+C 退出日志${plain}"; tail -f /usr/local/s-ui/s-ui.log ;;
        *) echo -e "${red}无效选项${plain}" ;;
    esac
done
EOF
    chmod +x /usr/local/s-ui/s-ui.sh
    ln -sf /usr/local/s-ui/s-ui.sh /usr/bin/s-ui
}

# 3. 执行安装流程
install_s-ui() {
    echo -e "--- ${green}自定义安装配置${plain} ---"
    read -p "1. 面板端口 (默认20270): " config_port
    config_port=${config_port:-20270}
    
    read -p "2. 面板路径 (例如 /ke/): " config_path
    # 路径格式化处理
    config_path=${config_path:-/}
    [[ ! $config_path =~ ^/ ]] && config_path="/$config_path"
    [[ ! $config_path =~ /$ ]] && config_path="$config_path/"
    
    read -p "3. 订阅端口 (默认2096): " config_subPort
    config_subPort=${config_subPort:-2096}
    
    read -p "4. 订阅路径 (默认 /sub/): " config_subPath
    config_subPath=${config_subPath:-/sub/}
    [[ ! $config_subPath =~ ^/ ]] && config_subPath="/$config_subPath"
    [[ ! $config_subPath =~ /$ ]] && config_subPath="$config_subPath/"

    read -p "5. 管理员用户名 (默认随机): " user_t
    read -p "6. 管理员密码 (默认随机): " pass_t
    
    cd /tmp/
    last_version=$(curl -Ls "https://api.github.com/repos/alireza0/s-ui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    echo -e "最新版本: ${last_version}，下载中..."
    wget -N --no-check-certificate -O /tmp/s-ui-linux-$(arch).tar.gz https://github.com/alireza0/s-ui/releases/download/${last_version}/s-ui-linux-$(arch).tar.gz

    pkill -9 sui > /dev/null 2>&1
    rm -rf /usr/local/s-ui/
    tar zxvf s-ui-linux-$(arch).tar.gz
    cp -rf s-ui /usr/local/
    
    # 初始化程序
    /usr/local/s-ui/sui migrate
    
    # 应用配置
    /usr/local/s-ui/sui setting -port ${config_port} -path ${config_path} -subPort ${config_subPort} -subPath ${config_subPath}
    
    # 账户处理
    [ -z "${user_t}" ] && user_t=$(head -c 4 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9')
    [ -z "${pass_t}" ] && pass_t=$(head -c 6 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9')
    /usr/local/s-ui/sui admin -username ${user_t} -password ${pass_t}

    # 启动与生成菜单
    nohup /usr/local/s-ui/sui > /usr/local/s-ui/s-ui.log 2>&1 &
    generate_menu_script
    
    # 开机自启
    mkdir -p /etc/local.d/
    echo -e "#!/bin/sh\nnohup /usr/local/s-ui/sui > /usr/local/s-ui/s-ui.log 2>&1 &" > /etc/local.d/s-ui.start
    chmod +x /etc/local.d/s-ui.start
    rc-update add local default >/dev/null 2>&1

    echo -e "------------------------------------------------"
    echo -e "${green}s-ui 安装成功！${plain}"
    echo -e "面板地址: ${yellow}http://IP:${config_port}${config_path}${plain}"
    echo -e "订阅地址: ${yellow}http://IP:${config_subPort}${config_subPath}${plain}"
    echo -e "管理账号: ${yellow}${user_t}${plain} / ${yellow}${pass_t}${plain}"
    echo -e "管理命令: ${green}s-ui${plain}"
    echo -e "------------------------------------------------"
}

install_base
install_s-ui