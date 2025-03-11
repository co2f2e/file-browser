#!/bin/bash
clear
TARGET_DIR="/filebrowser"
CONFIG_DB="/etc/filebrowser.db"
LOG_FILE="/var/log/filebrowser.log"
RC_LOCAL="/etc/rc.local"
SHARE_FILES="/filebrowsersharefiles"
USERNAME=$1

regex="^[a-zA-Z0-9]+$"
if [[ "$USERNAME" == "username" ]]; then
    echo "不能使用 username 作为用户名！"
    exit 0
elif [[ -z "$USERNAME" ]]; then
    echo "用户名不能为空！"
    exit 0
elif [[ ! "$USERNAME" =~ $regex ]]; then
    echo "用户名只能是纯英文或英文和数字组成，不能包含空格或符号！"
    exit 0
fi

if [ -d "$TARGET_DIR" ]; then
    echo "检测到 $TARGET_DIR 存在，正在删除..."
    rm -rf "$TARGET_DIR"
fi
mkdir -p "$TARGET_DIR"
LATEST_RELEASE=$(curl -sL https://api.github.com/repos/filebrowser/filebrowser/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
FILE_NAME="linux-amd64-filebrowser.tar.gz"
FILEBROWSER_URL="https://github.com/filebrowser/filebrowser/releases/download/$LATEST_RELEASE/$FILE_NAME"
curl -L "$FILEBROWSER_URL" -o "$TARGET_DIR/$FILE_NAME"
if [ ! -f "$TARGET_DIR/$FILE_NAME" ]; then
    echo "下载失败，请检查网络连接或 GitHub 资源是否可用！"
    exit 1
fi
tar -xzvf "$TARGET_DIR/$FILE_NAME" -C "$TARGET_DIR"
rm -f "$TARGET_DIR/$FILE_NAME"
if [ ! -f "$TARGET_DIR/filebrowser" ]; then
    echo "解压失败，未找到 filebrowser 可执行文件！"
    exit 1
fi
echo "FileBrowser ($LATEST_RELEASE) 已下载并解压到 $TARGET_DIR，接下来进行配置修改"
chmod +x "$TARGET_DIR"/filebrowser

"$TARGET_DIR"/filebrowser -d $CONFIG_DB config init >/dev/null 2>&1
"$TARGET_DIR"/filebrowser -d $CONFIG_DB config set --address 127.0.0.1 >/dev/null 2>&1
"$TARGET_DIR"/filebrowser -d $CONFIG_DB config set --port 8088 >/dev/null 2>&1
"$TARGET_DIR"/filebrowser -d $CONFIG_DB config set --locale zh-cn >/dev/null 2>&1
"$TARGET_DIR"/filebrowser -d $CONFIG_DB config set --log $LOG_FILE >/dev/null 2>&1
"$TARGET_DIR"/filebrowser -d $CONFIG_DB config set --baseurl /files >/dev/null 2>&1
"$TARGET_DIR"/filebrowser -d $CONFIG_DB config set --root $SHARE_FILES >/dev/null 2>&1
"$TARGET_DIR"/filebrowser -d $CONFIG_DB users add $USERNAME admin --perm.admin >/dev/null 2>&1

nohup "$TARGET_DIR"/filebrowser -d $CONFIG_DB >/dev/null 2>&1 &
PID=$!
sleep 2
if ps -p $PID > /dev/null; then
    sed -i '/exit 0/i\nohup filebrowser -d \/etc\/filebrowser.db >\/dev\/null 2>&1 &' /etc/rc.local
    echo
    echo "filebrowser 服务已成功启动并添加到开机自启！"
    echo
    echo 访问：https://域名/files
    echo 用户名：$USERNAME
    echo 密码：admin
else
    rm -rf "$TARGET_DIR"
    rm -f "$CONFIG_DB"
    rm -f "$LOG_FILE"
    rm -rf "$SHARE_FILES"
    if [ -f "$RC_LOCAL" ]; then
        sed -i '/filebrowser/d' "$RC_LOCAL"
    fi
    echo
    echo "filebrowser 启动失败，已删除相关文件"
fi
