<h1 align="center">
  FileBrowser
</h1>
FileBrowser是一个开源的文件管理系统，主要用于提供一个简单、直观的 Web 界面，方便用户管理文件。它允许用户通过 Web 浏览器访问、上传、下载、编辑文件，还提供了文件共享、权限管理等功能。适用于个人文件管理、团队协作或者需要一个文件管理服务的场景。


### 安装
```bash
bash <(curl -Ls https://raw.githubusercontent.com/co2f2e/FileBrowser/main/bash/install_filebrowser.sh) username
```

### 卸载
```bash
bash <(curl -Ls https://raw.githubusercontent.com/co2f2e/FileBrowser/main/bash/uninstall_filebrowser.sh)
```

### 环境
Debian12
已安装Nginx，申请了域名证书

### 访问
https://域名/files

### Nginx配置
```bash
location ^~ /files/ {
        proxy_pass  http://127.0.0.1:8088/;
        proxy_set_header Host $proxy_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
```

### 登录
安装的时候只允许用户名是纯英文或英文加数字，初始密码为：admin

### 注意
确保8088端口没有被占用
