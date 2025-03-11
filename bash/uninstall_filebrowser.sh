#!/bin/bash
clear
TARGET_DIR="/filebrowser"
CONFIG_DB="/etc/filebrowser.db"
LOG_FILE="/var/log/filebrowser.log"
RC_LOCAL="/etc/rc.local"
SHARE_FILES="/filebrowsersharefiles"

echo "卸载会删除$SHARE_FILES下上传的文件，你确定要卸载吗?"
echo
read -p "请输入 (y/n): " confirmation
if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]; then
    echo "正在停止 FileBrowser 进程..."
    pkill -f "$TARGET_DIR/filebrowser"
    echo "正在删除 FileBrowser 相关文件..."
    rm -rf "$TARGET_DIR"
    rm -f "$CONFIG_DB"
    rm -f "$LOG_FILE"
    rm -rf "$SHARE_FILES"
    if [ -f "$RC_LOCAL" ]; then
        sed -i '/filebrowser/d' "$RC_LOCAL"
    fi
    echo "FileBrowser 已成功卸载！"
else
    echo "卸载操作已取消"
fi
