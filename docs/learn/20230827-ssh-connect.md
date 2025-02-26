---
title: ssh基本介绍和问题解答
date: 2023-06-27 23:48:19
toc: true
tags:
- ssh
- linux
categories: ['技术博客']
---

# ssh基本介绍和问题解答

## SSH 简单介绍
在 Linux 系统上 SSH 是非常常用的工具，通过 SSH Client 我们可以连接到运行了 SSH Server 的远程机器上。SSH Client 的基本使用方法是：

```bash
ssh user@remote -p port
```

+ user 是你在远程机器上的用户名，如果不指定的话默认为当前用户
+ remote 是远程机器的地址，可以是 IP，域名，或者是后面会提到的别名
+ port 是 SSH Server 监听的端口，如果不指定的话就为默认值 22


### 免密码登入
每次 ssh 都要输入密码是不是很烦呢？与密码验证相对的，是公钥验证。也就是说，要实现免密码登入，首先要设置 SSH 钥匙。

其实就是把自己的公钥给服务器，让服务器可以认证你


### 查看有没有ssh server ？
```bash
/etc/init.d/ssh status
```

### 怎么生成密钥 ？
```bash
ssh-keygen -t rsa 
```

### 查看本机的ssh密钥公钥 ？
```bash
-- windows 目录
/c/Users/xxxx/.ssh

cat id_rsa.pub  # 这个是用rsa协议来生成的
```

### 怎么添加公钥到其他机器的
可以直接用工具传输
```bash
# 密钥发送
 ssh-copy-id -i id_rsa.pub xxx@192.168.0.103

```
也可以直接复制里面的内容，直接复制到服务器ssh目录下的

### 防火墙 ufw 开启ssh ？
```bash
   41  /usr/sbin/ufw
   47  /usr/sbin/ufw allow ssh
   60  /usr/sbin/ufw status
   70  /etc/init.d/ufw restart
   60  /usr/sbin/ufw status
   60  /usr/sbin/ufw enable # 开机自启

```
### ssh 开机自启 ?
```bash
   87  systemctl enable ssh
```
### 重启后 ufw 状态变为 inactive 的问题。
```bash
在设置开机自启后还有问题那大概率可能为启动顺序问题，修改/lib/systemd/system/ufw.service文件，在[Unit]中加入After=netfilter-persistent.service即可。

After=netfilter-persistent.service

```
### root安装的docker，普通用户无法使用  
需要将普通用户增加到docker用户组，见[安装 docker - 权限问题]({{< ref "20230426-fedora-install-docker.md/#权限问题" >}} "安装 docker - 权限问题")

```bash
permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/containers/json": dial unix /var/run/docker.sock: connect: permission denied
```

