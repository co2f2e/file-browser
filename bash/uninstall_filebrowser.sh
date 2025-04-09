#!/bin/bash
clear

SERVICE_FILE="/etc/systemd/system/filebrowser.service"
TARGET_DIR="/filebrowser"
CONFIG_DB="/etc/filebrowser.db"
LOG_FILE="/var/log/filebrowser.log"
SHARE_FILES="/filebrowsersharefiles"

read -p "卸载会删除$SHARE_FILES下已上传的文件，你确定要卸载吗，请输入(y/n): " confirmation
if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]; then

    echo "开始卸载 FileBrowser..."

    if systemctl is-active --quiet filebrowser; then
        echo "停止 filebrowser 服务..."
        systemctl stop filebrowser
    fi

    if systemctl is-enabled --quiet filebrowser; then
        echo "禁用 filebrowser 服务..."
        systemctl disable filebrowser
    fi

    if [ -f "$SERVICE_FILE" ]; then
        echo "🗑删除 systemd 服务文件..."
        rm -f "$SERVICE_FILE"
        systemctl daemon-reload
    fi

    if [ -d "$TARGET_DIR" ]; then
        echo "删除安装目录 $TARGET_DIR ..."
        rm -rf "$TARGET_DIR"
    fi

    if [ -f "$CONFIG_DB" ]; then
        echo "删除配置数据库 $CONFIG_DB ..."
        rm -f "$CONFIG_DB"
    fi

    if [ -f "$LOG_FILE" ]; then
        echo "删除日志文件 $LOG_FILE ..."
        rm -f "$LOG_FILE"
    fi
    echo "✅ 卸载完成！"
else
    echo "❌ 已放弃卸载！"
fi
