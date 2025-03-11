#!/bin/bash

clear
USERNAME=$1
regex="^[a-zA-Z]+$"

if [[ -z "$USERNAME" ]]; then
    echo "用户名不能为空！"
    exit 0
elif [[ ! "$USERNAME" =~ $regex ]]; then
    echo "用户名只能包含英文字符，不能包含空格或符号！"
    exit 0
fi

TARGET_DIR="/filebrowser"

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

echo "FileBrowser ($LATEST_RELEASE) 已下载并解压到 /$TARGET_DIR，接下来进行配置修改"

chmod +x "$TARGET_DIR"/filebrowser

"$TARGET_DIR"/filebrowser -d /etc/filebrowser.db config init

"$TARGET_DIR"/filebrowser -d /etc/filebrowser.db config set --address 127.0.0.1

"$TARGET_DIR"/filebrowser -d /etc/filebrowser.db config set --port 8088

"$TARGET_DIR"/filebrowser -d /etc/filebrowser.db config set --locale zh-cn

"$TARGET_DIR"/filebrowser -d /etc/filebrowser.db config set --log /var/log/filebrowser.log

"$TARGET_DIR"/filebrowser -d /etc/filebrowser.db config set --baseurl /files

"$TARGET_DIR"/filebrowser -d /etc/filebrowser.db config set --root /filebrowsersharefiles

"$TARGET_DIR"/filebrowser -d /etc/filebrowser.db users add $USERNAME admin --perm.admin

nohup "$TARGET_DIR"/filebrowser -d /etc/filebrowser.db >/dev/null 2>&1 &

sed -i '/exit 0/i\nohup filebrowser -d \/etc\/filebrowser.db >\/dev\/null 2>&1 &' /etc/rc.local
