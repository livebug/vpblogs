---
title : 'WSL2配置代理'
date : 2023-12-21T21:53:07+08:00
toc: true
tags: ['wsl2','proxy']
categories: ['技术博客']
---
# WSL2配置代理

>该方法引用自： https://www.cnblogs.com/tuilk/p/16287472.html 

## 配置WSL2
这种配置方法适用于长期配置，也就是写一个脚本，然后可以通过命令启动代理。新建proxy.sh脚本如下：

```shell
#!/bin/sh
hostip=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
wslip=$(hostname -I | awk '{print $1}')
port=7890
 
PROXY_HTTP="http://${hostip}:${port}"
 
set_proxy(){
  export http_proxy="${PROXY_HTTP}"
  export HTTP_PROXY="${PROXY_HTTP}"
 
  export https_proxy="${PROXY_HTTP}"
  export HTTPS_proxy="${PROXY_HTTP}"
 
  export ALL_PROXY="${PROXY_SOCKS5}"
  export all_proxy=${PROXY_SOCKS5}
 
  git config --global http.https://github.com.proxy ${PROXY_HTTP}
  git config --global https.https://github.com.proxy ${PROXY_HTTP}
 
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

>注意：其中第4行的<PORT>更换为自己的代理端口号。

```shell
source ./proxy.sh set：开启代理
source ./proxy.sh unset：关闭代理
source ./proxy.sh test：查看代理状态
```

2.1 任意路径下开启代理  
可以在~/.bashrc中添加如下内容，并将其中的路径修改为上述脚本的路径：
```shell
alias proxy="source /path/to/proxy.sh"
```
然后输入如下命令：
```shell
source ~/.bashrc
```
那么可以直接在任何路径下使用如下命令：

```shell
proxy set：开启代理
proxy unset：关闭代理
proxy test：查看代理状态
```
2.2 自动设置代理  
也可以添加如下内容，即在每次shell启动时自动设置代理，同样的，更改其中的路径为自己的脚本路径：

```shell
. /path/to/proxy.sh set
```