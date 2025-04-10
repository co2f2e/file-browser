#!/bin/bash
clear

export LANG="en_US.UTF-8"
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;36m'
nc='\033[0m'

red() {
	echo -e "${red}$1${nc}"
}

green() {
	echo -e "${green}$1${nc}"
}

yellow() {
	echo -e "${yellow}$1${nc}"
}

blue() {
	echo -e "${blue}$1${nc}"
}

SERVICE_FILE="/etc/systemd/system/filebrowser.service"
TARGET_DIR="/filebrowser"
CONFIG_DB="/etc/filebrowser.db"
LOG_FILE="/var/log/filebrowser.log"
SHARE_FILES="/filebrowsersharefiles"

read -p "$(yellow "卸载会删除 "$SHARE_FILES" 下已上传的文件，你确定要卸载吗，请输入(y/n)"): " confirmation
if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]; then

    green "开始卸载 FileBrowser..."

    if systemctl is-active --quiet filebrowser; then
        green "停止 filebrowser 服务..."
        systemctl stop filebrowser
    fi

    if systemctl is-enabled --quiet filebrowser; then
        green "禁用 filebrowser 服务..."
        systemctl disable filebrowser
    fi

    if [ -f "$SERVICE_FILE" ]; then
        green "🗑删除 systemd 服务文件..."
        rm -f "$SERVICE_FILE"
        systemctl daemon-reload
    fi

    if [ -d "$TARGET_DIR" ]; then
        green "删除安装目录 $TARGET_DIR ..."
        rm -rf "$TARGET_DIR"
    fi

    if [ -f "$CONFIG_DB" ]; then
        green "删除配置数据库 $CONFIG_DB ..."
        rm -f "$CONFIG_DB"
    fi

    if [ -f "$LOG_FILE" ]; then
        green "删除日志文件 $LOG_FILE ..."
        rm -f "$LOG_FILE"
    fi
    green "✅ 卸载完成！"
else
    red "❌ 已放弃卸载！"
fi
