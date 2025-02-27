---
title: fedora打开Samba端口
date: 2023-04-25 10:36:21
toc: true
tags:
- fedora
- linux
- samba

---
# fedora打开Samba端口

来源：  
https://www.linuxprobe.com/fedora-centos-samba.html 

在CentOS/RHEL 7中打开Samba端口  
使用以下命令：

```
firewall-cmd --permanent --zone=public --add-service=samba
firewall-cmd --reload
```

注意事项：
1. 需要加用户密码时，使用本机已经有的账户，但秘密可以随便设置