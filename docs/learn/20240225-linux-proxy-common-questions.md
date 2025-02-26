---
title : 'linux 使用代理以及遇到的问题'
date : 2024-02-25T17:30:25+08:00
toc: true
tags: ['linux','proxy']
categories: ['技术博客']
---
# linux 使用代理以及遇到的问题

## 前提 你得有一个代理
我的场景是wsl，使用主机打开的 clash 代理

clash for windows 支持端口代理，所以在wsl中需要科学上网的场景可以走这个代理提高访问速度

理论可行，实现优点曲折。

小插曲，wsl2的网络模式与wsl1不一致，本质上是两台机器，通过网络链接，所以需要知道windows的IP,在wsl网络里的IP,
```bash
# windows下执行 ipconfig即可看到
> ipconfig
以太网适配器 vEthernet (WSL (Hyper-V firewall)):

   连接特定的 DNS 后缀 . . . . . . . :
   本地链接 IPv6 地址. . . . . . . . : fe80::e4ec:39b6:69cb:8afe%42
   IPv4 地址 . . . . . . . . . . . . : 172.31.192.1
   子网掩码  . . . . . . . . . . . . : 255.255.240.0
   默认网关. . . . . . . . . . . . . :

# wsl2   执行 
cat /etc/resolv.conf | grep nameserver 
nameserver 172.31.192.1
```

## linux设置代理,一个脚本完事
```bash
#!/bin/sh
hostip=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
wslip=$(hostname -I | awk '{print $1}')
port=58972  # 代理的端口
 
PROXY_HTTP="http://${hostip}:${port}"
 
set_proxy(){
  export http_proxy="${PROXY_HTTP}"
  export HTTP_PROXY="${PROXY_HTTP}"
 
  export https_proxy="${PROXY_HTTP}"
  export HTTPS_proxy="${PROXY_HTTP}"
 
  export ALL_PROXY="${PROXY_SOCKS5}"
  export all_proxy=${PROXY_SOCKS5}
  
  git config --global http.https://github.com.proxy ${PROXY_HTTP}
  git config --global https.https://github.com.proxy ${PROXY_HTTP} # git 的代理

  echo "Proxy has been opened."
}
 
unset_proxy(){
  unset http_proxy
  unset HTTP_PROXY
  unset https_proxy
  unset HTTPS_PROXY
  unset ALL_PROXY
  unset all_proxy
  git config --global --unset http.https://github.com.proxy
  git config --global --unset https.https://github.com.proxy
 
  echo "Proxy has been closed."
}
 
test_setting(){
  echo "Host IP:" ${hostip}
  echo "WSL IP:" ${wslip}
  echo "Try to connect to Google..."
  resp=$(curl -I -s --connect-timeout 5 -m 5 -w "%{http_code}" -o /dev/null www.google.com)
  if [ ${resp} = 200 ]; then
    echo "Proxy setup succeeded!"
  else
    echo "Proxy setup failed!"
  fi
}
 
if [ "$1" = "set" ]
then
  set_proxy
 
elif [ "$1" = "unset" ]
then
  unset_proxy
 
elif [ "$1" = "test" ]
then
  test_setting
else
  echo "Unsupported arguments."
fi
```
启动

## 设置 vscode 的代理
设置里找到加上就行
```json
    "http.proxy": "http://172.31.192.1:58972",
```

