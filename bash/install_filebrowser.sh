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

TARGET_DIR="/filebrowser"
CONFIG_DB="/etc/filebrowser.db"
LOG_FILE="/var/log/filebrowser.log"
RC_LOCAL="/etc/rc.local"
SHARE_FILES="/filebrowsersharefiles"
SERVICE_FILE="/etc/systemd/system/filebrowser.service"
PORT=$1
USERNAME=$2
DEFAULT_PASSWORD=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 16)

regex="^[a-zA-Z0-9]+$"
if [[ "$USERNAME" == "username" ]]; then
    red "不能使用 username 作为用户名！"
    exit 0
elif [[ -z "$USERNAME" ]]; then
    red "用户名不能为空！"
    exit 0
elif [[ ! "$USERNAME" =~ $regex ]]; then
    red "用户名只能是纯英文或英文和数字组成，不能包含空格或符号！"
    exit 0
fi

if [[ -z "$PORT" ]]; then
    red "端口不能为空！"
    exit 0
fi

if [[ ! "$PORT" =~ ^[0-9]+$ ]]; then
    red "端口只能是纯数字！"
    exit 0
fi

if [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    red "端口号必须在 1 到 65535 之间！"
    exit 0
fi

if ss -tuln | grep -q ":$PORT"; then
    red "端口 $PORT 已被占用！"
    exit 0
fi

if [ -d "$TARGET_DIR" ]; then
    yellow "检测到 $TARGET_DIR 存在，正在删除..."
    rm -rf "$TARGET_DIR"
fi
mkdir -p "$TARGET_DIR"
LATEST_RELEASE=$(curl -sL https://api.github.com/repos/filebrowser/filebrowser/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
FILE_NAME="linux-amd64-filebrowser.tar.gz"
FILEBROWSER_URL="https://github.com/filebrowser/filebrowser/releases/download/$LATEST_RELEASE/$FILE_NAME"
curl -L "$FILEBROWSER_URL" -o "$TARGET_DIR/$FILE_NAME"
if [ ! -f "$TARGET_DIR/$FILE_NAME" ]; then
    red "下载失败，请检查网络连接或 GitHub 资源是否可用！"
    exit 0
fi
tar -xzvf "$TARGET_DIR/$FILE_NAME" -C "$TARGET_DIR"
rm -f "$TARGET_DIR/$FILE_NAME"
if [ ! -f "$TARGET_DIR/filebrowser" ]; then
    red "解压失败，未找到 filebrowser 可执行文件！"
    exit 0
fi
green "FileBrowser ($LATEST_RELEASE) 已下载并解压到 $TARGET_DIR，接下来进行配置修改"
chmod +x "$TARGET_DIR"/filebrowser

if [ -f "$CONFIG_DB" ]; then
    yellow "检测到旧的数据库，删除旧数据库..."
    rm -f "$CONFIG_DB"
fi

"$TARGET_DIR"/filebrowser -d $CONFIG_DB config init >/dev/null 2>&1
"$TARGET_DIR"/filebrowser -d $CONFIG_DB config set --address 127.0.0.1 >/dev/null 2>&1
"$TARGET_DIR"/filebrowser -d $CONFIG_DB config set --port $PORT >/dev/null 2>&1
"$TARGET_DIR"/filebrowser -d $CONFIG_DB config set --locale zh-cn >/dev/null 2>&1
"$TARGET_DIR"/filebrowser -d $CONFIG_DB config set --log $LOG_FILE >/dev/null 2>&1
"$TARGET_DIR"/filebrowser -d $CONFIG_DB config set --baseurl / >/dev/null 2>&1
"$TARGET_DIR"/filebrowser -d $CONFIG_DB config set --root $SHARE_FILES >/dev/null 2>&1
"$TARGET_DIR"/filebrowser -d $CONFIG_DB users add $USERNAME $DEFAULT_PASSWORD --perm.admin 

green "正在创建 systemd 服务文件..."

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=FileBrowser Service
After=network.target

[Service]
Type=simple
ExecStart=$TARGET_DIR/filebrowser -d $CONFIG_DB
Restart=on-failure
RestartSec=3
StandardOutput=file:$LOG_FILE
StandardError=file:$LOG_FILE

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable filebrowser
systemctl start filebrowser

if systemctl is-active --quiet filebrowser; then
    echo
    green "FileBrowser 安装并已启动成功！"
    echo
    yellow "登录后请先修改密码，否则只能卸载了重新安装"
    echo
    green "访问地址: https://<服务器IP>:$PORT"
    green "用户名: $USERNAME"
    green "密码: $DEFAULT_PASSWORD"
else
    red "FileBrowser 启动失败，请检查日志: $LOG_FILE"
fi
