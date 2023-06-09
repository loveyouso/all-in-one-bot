#!/bin/bash

#fonts color
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'

GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

version=v0.0.2
prj_name="aio-bot"
project_dir="/usr/local/bin"
prj_url="https://api.github.com/repos/uerax/all-in-one-bot/releases/latest"
cfg_url="/usr/local/etc"
log_url="/var/log/"

env() {
    apt update
    apt install -y curl
    apt install -y tail
}

is_root() {
    if [ $(id -u) == 0 ]; then
        echo -e "进入安装流程"
        sleep 3
    else
        echo -e "请切使用root用户执行脚本"
        echo -e "切换root用户命令: sudo su"
        exit 1
    fi
}

install() {

    # 下载链接
    download_url=$(curl -sL $prj_url | grep "browser_download_url" | cut -d '"' -f 4)
    cfg_url="https://raw.githubusercontent.com/uerax/all-in-one-bot/master/all-in-one-bot.yml"

    # 创建项目目录
    mkdir -p "$project_dir"
    mkdir -p "$log_url/$prj_name"
    mkdir -p "$cfg_url/$prj_name"

    curl -L "$download_url" -o "$project_dir/$prj_name"
    curl -L "$cfg_url" -o "$cfg_url/$prj_name/all-in-one-bot.yml"

    chmod +x $project_dir/$prj_name/$prj_name

}

start() {
    systemctl restart aio
    
}

stop() {
    systemctl stop aio
}

elog() {
    tail -f $log_url/$prj_name/error.log
}

olog() {
    tail -f $log_url/$prj_name/access.log
}

write() {
    vim $cfg_url/$prj_name/all-in-one-bot.yml
}

systemctl() {
    is_root
    env
    install

cat > /etc/systemd/system/aio.service << EOF
[Unit]
Description=Aio-Bot Service
Documentation=https://github.com/uerax/all-in-one-bot
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/aio-bot -c /usr/local/bin/aio-bot/all-in-one-bot.yml
StandardOutput=file:/var/log/aio-bot/access.log
StandardError=file:/var/log/aio-bot/error.log
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

ln -s /etc/systemd/system/aio.service /etc/systemd/system/multi-user.target.wants/aio.service

}

uninstall() {
    systemctl stop aio
    systemctl disable aio
    unlink /etc/systemd/system/multi-user.target.wants/aio.service
    rm /etc/systemd/system/aio.service
    systemctl daemon-reload

    rm -f $project_dir/$prj_name
    rm -f $cfg_url/$prj_name/all-in-one-bot.yml
    rm -rf $log_url/$prj_name
    
}

menu() {
    echo -e "${Cyan}——————————————— 脚本信息 ———————————————${Font}"
    echo -e "\t\t${Yellow}aio-bot 操作脚本${Font}"
    echo -e "\t${Yellow}---authored by uerax---${Font}"
    echo -e "\t${Yellow}https://github.com/uerax${Font}"
    echo -e "\t\t${Yellow}版本号：${version}${Font}"
    echo -e "${Cyan}——————————————— 操作向导 ———————————————${Font}"
    echo -e "${Green}1)   一键安装${Font}"
    echo -e "${Blue}2)   编辑配置文件${Font}"
    echo -e "${Blue}3)   启动服务${Font}"
    echo -e "${Blue}4)   关闭服务${Font}"
    echo -e "${Blue}5)   查看error日志(默认)${Font}"
    echo -e "${Blue}6)   查看output日志${Font}"
    echo -e "${Red}q)   退出${Font}"
    echo -e "${Cyan}————————————————————————————————————————${Font}\n"

    read -rp "输入数字(回车确认)：" menu_num
    echo -e ""
    case $menu_num in
    1)
    systemctl
    ;;
    2)
    write
    ;;
    3)
    start
    ;;
    4)
    stop
    ;;
    5)
    elog
    ;;
    6)
    olog
    ;;
    q)
    ;;
    *)
    ;;
    esac
}


menu