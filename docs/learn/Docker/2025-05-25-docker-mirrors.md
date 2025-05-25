---
title: snap的docker是如何换源
tags:
  - docker
--- 

# snap的docker是如何换源


通过 Snap 安装的 Docker 换源需要修改其专属配置文件，而非传统的 /etc/docker/daemon.json。以下是具体步骤和注意事项：

## 修改配置文件

Snap 版 Docker 的配置文件路径为：  
/var/snap/docker/current/config/daemon.json

```json
{
    "registry-mirrors": [
    	"https://docker.m.daocloud.io",
    	"https://docker.imgdb.de",
    	"https://docker-0.unsee.tech",
    	"https://docker.hlmirror.com",
    	"https://docker.1ms.run",
    	"https://func.ink",
    	"https://lispy.org",
    	"https://docker.xiaogenban1993.com"
    ]
}
```


## 重启 Docker 服务

sudo snap restart docker

## 验证配置

docker info | grep Mirrors -A 1

若输出包含配置的镜像地址，表示换源成功。 