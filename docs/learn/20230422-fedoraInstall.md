---
title: fedora系统安装后的基本操作
date: 2023-04-22 16:39:49
toc: true
tags:
- linux
- fedora
categories: ['技术博客']
---
# fedora系统安装后的基本操作
## fedora 安装之后的操作

### 1. 换国内软件源
```bash
sudo sed -e 's|^metalink=|#metalink=|g' \
    -e 's|^#baseurl=http://download.example/pub/fedora/linux|baseurl=https://mirrors.tuna.tsinghua.edu.cn/fedora|g' \
    -i.bak \
    /etc/yum.repos.d/fedora.repo \
    /etc/yum.repos.d/fedora-modular.repo \
    /etc/yum.repos.d/fedora-updates.repo \
    /etc/yum.repos.d/fedora-updates-modular.repo

sudo dnf makecache
sudo dnf autoremove
sudo dnf remove --oldinstallonly
```
### 2. 设置 `gnome-terminal ` 快捷键 `ctrl+alt+t`
### 3. 安装基本软件
+ 2.1 edge 浏览器
+ 2.2 vscode   

    https://vscode.cdn.azure.cn/stable/704ed70d4fd1c6bd6342c436f1ede30d1cff4710/code-1.77.3-1681292829.el7.x86_64.rpm

+ 2.3 dotnet6
+ 2.4 nvm  
+ 2.5 安装 GNOME 优化和扩展应用程序  
    ```bash
    sudo dnf install gnome-tweaks gnome-extensions-app
    ```
    https://extensions.gnome.org/  
    安装 dash to dock 插件，可以让dock在桌面悬浮
### 4. 如何给Linux安装新的字体  
下载字体后放到下面目录即可:
```bash
/usr/share/fonts
$l
总计 0
drwxr-xr-x. 1 root root  246  4月14日 05:44 liberation-mono
...
```