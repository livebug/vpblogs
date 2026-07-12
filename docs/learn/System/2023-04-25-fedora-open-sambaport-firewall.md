---
title: Fedora/CentOS 配置 Samba 共享及防火墙放行
tags:
  - Linux
---

# Fedora/CentOS 配置 Samba 共享

> 在 Linux 上搭建 Samba 文件共享，并开放防火墙端口让 Windows 访问。

## 安装 Samba

```bash
# Fedora
sudo dnf install samba -y

# CentOS/RHEL
sudo yum install samba -y
```

## 配置共享目录

编辑 `/etc/samba/smb.conf`：

```ini
[shared]
   comment = Shared Folder
   path = /home/user/shared
   browseable = yes
   writable = yes
   valid users = user
```

## 添加 Samba 用户

```bash
# Samba 用户必须是系统已有用户，但密码可以独立设置
sudo smbpasswd -a username
```

## 启动服务

```bash
sudo systemctl enable smb --now
sudo systemctl status smb
```

## 开放防火墙端口

```bash
# 方式一：添加 Samba 服务（推荐）
sudo firewall-cmd --permanent --zone=public --add-service=samba
sudo firewall-cmd --reload

# 方式二：手动添加端口
sudo firewall-cmd --permanent --zone=public --add-port=139/tcp
sudo firewall-cmd --permanent --zone=public --add-port=445/tcp
sudo firewall-cmd --reload
```

## 验证

```bash
# 查看已开放的端口
sudo firewall-cmd --list-all

# Windows 访问
# 在文件资源管理器输入：\\服务器IP\shared
```

参考：[linuxprobe.com](https://www.linuxprobe.com/fedora-centos-samba.html)
