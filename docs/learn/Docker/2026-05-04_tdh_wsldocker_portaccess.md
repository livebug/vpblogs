---
title: WSL2 Docker 运行 TDH 开发版端口无法访问的排查与解决
tags:
  - Docker
  - WSL2
  - TDH
  - 网络
---

# WSL2 Docker 运行 TDH 开发版端口无法访问的排查与解决

## 背景

在 WSL2 环境下使用 Docker 安装 TDH（Transwarp Data Hub）开发版，启动容器后发现 `docker ps` 没有显示端口映射，本地也无法通过浏览器访问 Web 管理界面。

## 现象

```
$ docker ps -a
CONTAINER ID   IMAGE                   STATUS         PORTS     NAMES
1a992da98a57   tdh-standalone:2024.5   Up 10 minutes            hopeful_yalow
```

`PORTS` 列为空，没有任何端口映射信息。

但进入容器内部检查，服务是正常运行的：

```bash
$ docker exec hopeful_yalow ss -tlnp
LISTEN   0    100    *:8180    *:*    users:(("java",pid=316,fd=456))
LISTEN   0    80     *:3308    *:*    users:(("mysqld",pid=205,fd=21))

$ docker exec hopeful_yalow curl -s -o /dev/null -w '%{http_code}' http://localhost:8180
200
```

容器内部 8180 端口正常监听且返回 200，但从 WSL2 宿主机访问却 Connection Refused。

## 排查过程

### 1. 确认网络模式

```bash
$ docker inspect hopeful_yalow --format '{{.HostConfig.NetworkMode}}'
host
```

容器使用了 `--network=host` 模式。在原生 Linux 上，这意味着容器直接共享宿主机的网络命名空间，端口会直接出现在宿主机上。但 WSL2 并非如此。

### 2. 理解 WSL2 + Docker Desktop 的网络架构

在 WSL2 环境下，Docker Desktop 并不直接在 WSL2 内核中运行，而是在 WSL2 内部启动一个独立的 Linux 虚拟机来运行 Docker Engine。这个 VM 有自己的 IP：

```bash
$ docker exec hopeful_yalow hostname -I
192.168.65.6 192.168.65.3 172.17.0.1
```

`192.168.65.x` 是 Docker Desktop VM 的内部网络。当使用 `--network=host` 时，容器共享的是 Docker Desktop VM 的网络命名空间，而不是 WSL2 宿主机的网络。这就是为什么 WSL2 宿主机上 `ss -tlnp` 看不到 8180 端口，也无法直接访问。

```
┌─────────────────────────────────────────┐
│              Windows 物理机              │
│  ┌───────────────────────────────────┐  │
│  │           WSL2 发行版              │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │    Docker Desktop VM         │  │  │
│  │  │  IP: 192.168.65.6           │  │  │
│  │  │  ┌───────────────────────┐  │  │  │
│  │  │  │  容器 (host网络模式)    │  │  │  │
│  │  │  │  端口 8180 绑定在 VM    │  │  │  │
│  │  │  └───────────────────────┘  │  │  │
│  │  └─────────────────────────────┘  │  │
│  │        ↑ 宿主机无法直接访问         │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### 3. 确认根因

- WSL2 宿主机 `ss -tlnp` 看不到 8180 → 端口在 Docker VM 内部
- WSL2 宿主 `curl localhost:8180` Connection Refused → 端口没有暴露到 WSL2 网络
- `ping 192.168.65.6` 不通 → WSL2 无法路由到 Docker VM 的内部 IP

## 解决方案

**用 `-p` 端口映射替代 `--network=host`。**

### 操作步骤

#### 1. 确认正确挂载路径

先检查原来容器的挂载配置：

```bash
$ docker inspect hopeful_yalow --format '{{json .Mounts}}'
[{"Source":"/home/livebug/tdh","Destination":"/opt/transwarp"}]
```

#### 2. 停止原容器，用正确参数重新启动

```bash
# 停止原容器
docker stop hopeful_yalow

# 用端口映射模式重新启动
docker run -d \
  --name tdh-dev \
  -p 8180:8180 \
  -p 3308:3308 \
  -p 10208:10208 \
  --privileged \
  -v /home/livebug/tdh:/opt/transwarp \
  tdh-standalone:2024.5
```

#### 3. 验证结果

```bash
$ ss -tlnp | grep -E "8180|3308|10208"
LISTEN  0  4096  *:10208  *:*
LISTEN  0  4096  *:8180   *:*
LISTEN  0  4096  *:3308   *:*

$ curl -s -o /dev/null -w "%{http_code}" http://localhost:8180
200
```

| 端口 | 服务 | 访问地址 |
|------|------|----------|
| 8180 | TDH Manager Web 管理界面 | `http://localhost:8180` |
| 3308 | MariaDB 数据库 | `mysql -h localhost -P 3308` |
| 10208 | 其他 TDH 服务 | - |

## 关键点总结

1. **WSL2 中 `--network=host` 的陷阱**：容器共享的是 Docker Desktop VM 的网络，而非 WSL2 宿主机网络，端口不会直接暴露到 WSL2 上。
2. **优先使用端口映射**：在 WSL2 + Docker Desktop 环境下，用 `-p` 显式映射端口是最可靠的方式。
3. **挂载路径**：TDH 容器要求挂载宿主机目录到 `/opt/transwarp`，否则启动失败。
4. **启动时间**：TDH 包含 MySQL + Java 服务，完全就绪大约需要 60-90 秒。

## 相关命令速查

```bash
# 查看容器网络模式
docker inspect <container> --format '{{.HostConfig.NetworkMode}}'

# 查看容器内监听端口
docker exec <container> ss -tlnp

# 查看容器挂载
docker inspect <container> --format '{{json .Mounts}}'

# 查看容器 IP
docker exec <container> hostname -I