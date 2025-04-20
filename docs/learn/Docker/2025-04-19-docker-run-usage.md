---
title: docker run 手册
tags:
  - docker
---
# docker run 手册

开篇先看一个语句： 用docker启动一个ubuntu
```bash
`docker run --name ubuntu_demo -itd ubuntu` 
```

命令解释
`docker run --name ubuntu_demo -itd ubuntu` 的作用是创建一个名为 `ubuntu_demo` 的容器，并在后台以交互模式运行 Ubuntu 镜像。具体参数解析如下：
1. `--name ubuntu_demo`  
   为容器指定名称 `ubuntu_demo`，便于后续通过名称管理容器（如启动、停止等）。
2. `-itd`  
   这是三个参数的组合：
   • `-i`（`--interactive`）：保持标准输入（STDIN）打开，允许与容器交互。

   • `-t`（`--tty`）：分配一个伪终端（pseudo-TTY），通常与 `-i` 结合使用以实现交互式命令行操作。

   • `-d`（`--detach`）：在后台运行容器，不占用当前终端。

3. `ubuntu`  
   指定使用的镜像名称（默认为最新标签 `ubuntu:latest`）。

---

`docker run` 常用参数手册
一、容器运行模式

| 参数 | 说明 | 示例 |
|------|------|------|
| `-d`/`--detach` | 后台运行容器 | `docker run -d nginx` |
| `-it` | 交互式终端（需组合使用 `-i` + `-t`） | `docker run -it ubuntu bash` |
| `--rm` | 容器退出后自动删除 | `docker run --rm alpine` |
| `--restart` | 设置重启策略（`always`/`unless-stopped`/`on-failure`） | `docker run --restart=always nginx` |

二、资源管理

| 参数 | 说明 | 示例 |
|------|------|------|
| `--cpus` | 限制 CPU 核心数 | `docker run --cpus=2.5 nginx` |
| `--memory` | 限制内存使用（如 `512m`） | `docker run --memory=1g nginx` |
| `--device` | 挂载宿主机设备到容器 | `docker run --device=/dev/sda:/dev/sda` |

三、网络与端口

| 参数 | 说明 | 示例 |
|------|------|------|
| `-p`/`--publish` | 端口映射（主机端口:容器端口） | `docker run -p 8080:80 nginx` |
| `--network` | 指定网络模式（`host`/`bridge`/`none`） | `docker run --network=host nginx` |

四、存储与挂载

| 参数 | 说明 | 示例 |
|------|------|------|
| `-v`/`--volume` | 挂载宿主机目录到容器 | `docker run -v /data:/app/data nginx` |
| `--mount` | 更灵活的挂载方式（支持类型如 `bind`/`volume`） | `docker run --mount type=bind,src=/host,dst=/container` |

五、环境与权限

| 参数 | 说明 | 示例 |
|------|------|------|
| `-e`/`--env` | 设置环境变量 | `docker run -e MYSQL_ROOT_PASSWORD=123456 mysql` |
| `--privileged` | 赋予容器特权模式（访问宿主机设备） | `docker run --privileged nginx` |
| `-u`/`--user` | 指定运行用户（如 `1000:1000`） | `docker run -u www-data nginx` |

---

扩展说明
• 完整参数列表可通过 `docker run --help` 查看，或参考 Docker 官方文档。

• 若需限制容器权限，可用 `--cap-add`/`--cap-drop` 调整 Linux 能力。

• 数据持久化推荐使用 `-v` 或 `--mount`，避免容器删除后数据丢失。


以上参数覆盖了容器生命周期管理、资源控制、网络配置等核心场景，更多高级用法可结合具体需求查阅文档。


小结：启动一个docker中的ubuntu，能够自启动，并挂载/data目路到本地目录