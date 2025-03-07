#!/bin/bash

TARGET_DIR="/filebrowser"
CONFIG_DB="/etc/filebrowser.db"
LOG_FILE="/var/log/filebrowser.log"
RC_LOCAL="/etc/rc.local"

echo "正在停止 FileBrowser 进程..."
pkill -f "$TARGET_DIR/filebrowser"

echo "正在删除 FileBrowser 相关文件..."
rm -rf "$TARGET_DIR"
rm -f "$CONFIG_DB"
rm -f "$LOG_FILE"

if [ -f "$RC_LOCAL" ]; then
    sed -i '/filebrowser/d' "$RC_LOCAL"
fi

echo "FileBrowser 已成功卸载！"
