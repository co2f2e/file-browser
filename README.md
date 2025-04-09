<h1 align="center">
  FileBrowser一键安装脚本
</h1>
FileBrowser是一个开源的文件管理系统，主要用于提供一个简单、直观的 Web 界面，方便用户管理文件。它允许用户通过 Web 浏览器访问、上传、下载、编辑文件，还提供了文件共享、权限管理等功能。

<hr>

### 安装
* 第一个参数username设置为你想注册的用户名，只能是纯英文或英文加数字
* 第二个参数port设置为一个端口号，记得NGINX中配置为相应的端口号
```bash
bash <(curl -Ls https://raw.githubusercontent.com/co2f2e/FileBrowser/main/bash/install_filebrowser.sh) username 8088
```

### 卸载
```bash
bash <(curl -Ls https://raw.githubusercontent.com/co2f2e/FileBrowser/main/bash/uninstall_filebrowser.sh)
```

### NGINX配置
```bash
location ^~ /files/ {
        proxy_pass  http://127.0.0.1:8088/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        client_max_body_size 2G; #设置单个上传文件最大限制
        proxy_buffers 4 8k; #4个8KB的缓冲区
        proxy_busy_buffers_size 8k; #允许最多使用8KB的内存
        sendfile on; #启用 sendfile 提高文件传输性能
        tcp_nopush on; #优化大文件传输
    }
```
### 服务管理命令
| 操作         | 命令                                                        |
|--------------|-------------------------------------------------------------|
| 启动服务     | ```sudo systemctl start filebrowser```                      |
| 停止服务     | ```sudo systemctl stop filebrowser```                       |
| 重启服务     | ```sudo systemctl restart filebrowser```                    |
| 查看状态     | ```sudo systemctl status filebrowser```                     |
| 查看日志     | ```sudo journalctl -u filebrowser -f```                     |
| 开机自启动   | ```sudo systemctl enable filebrowser```                     |
| 关闭开机启动 | ```sudo systemctl disable filebrowser```                    |

### 环境
* Debian12
* NGINX
* SSL
