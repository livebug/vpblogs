---
title: WSL2 Debian 全栈开发环境搭建
tags:
  - WSL2
  - Debian
  - DevEnv
  - Setup
  - Proxy
  - NodeJs
  - Java
---

# WSL2 Debian 全栈开发环境搭建

> 本文档记录了在 **WSL2 (Debian GNU/Linux 13 Trixie)** 上搭建全栈开发环境的完整过程。  
> 代理方案：Clash TUN 模式部署在 Windows 宿主机，WSL2 通过 `http_proxy` 环境变量走 Clash LAN 端口。

## 概述

| 项目 | 值 |
|------|-----|
| 系统 | Debian GNU/Linux 13 (Trixie) |
| WSL 版本 | WSL2 (内核 6.6.87.2-microsoft-standard-WSL2) |
| 架构 | x86_64 (amd64) |
| 代理 | Clash TUN (Windows) → WSL2 内 `http_proxy=http://<宿主机IP>:7890` |
| 默认 Shell | bash |

## 已安装工具清单

| 工具 | 版本 | 安装方式 |
|------|------|----------|
| Node.js | v22.22.2 (LTS) | NodeSource apt |
| npm | 10.9.7 | 随 Node.js |
| Python | 3.13.5 | Debian 自带 |
| pip | 25.1.1 | Debian 自带 |
| OpenJDK | 21.0.11 (LTS) | Debian apt |
| Git | 2.47.3 | Debian apt |
| curl | - | Debian apt |
| SSH (ed25519) | - | `ssh-keygen` |
| Docker | **建议 Docker Desktop (Windows)** | 见下方说明 |

## 一、代理配置（Clash TUN → WSL2）

### 原理

Clash 在 Windows 侧以 TUN 模式运行，TUN 虚拟网卡只能拦截 Windows 原生流量，**无法直接覆盖 WSL2 内部流量**。因此需要在 WSL2 内手动设置 `http_proxy`，指向 Windows 宿主机。

### 配置 (`~/.bashrc`)

```bash
# 通过默认网关获取 Windows 宿主机 IP
wsl_host_ip=$(ip route show default 2>/dev/null | awk '{print $3}')
if [ -n "$wsl_host_ip" ]; then
    export http_proxy="http://$wsl_host_ip:7890"
    export https_proxy="http://$wsl_host_ip:7890"
    export all_proxy="socks5://$wsl_host_ip:7890"
    export no_proxy="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
fi
unset wsl_host_ip
```

> **前提**：Clash 需开启 "Allow LAN"（允许局域网连接），混合端口默认 `7890`。

### 验证代理是否生效

```bash
curl -I https://www.google.com
# 应返回 HTTP/2 200 或 301，而非超时
```

### 详细文档

参见 [WSL2 + Clash TUN 模式代理配置](./2026-05-02-wsl2-clash-proxy.md)

## 二、基础工具

```bash
sudo apt update -y
sudo apt install -y curl git ca-certificates gnupg
```

## 三、Node.js（NodeSource 官方源）

### 安装

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install nodejs -y
```

- `-E` 保留代理环境变量，确保 apt 走 Clash 代理下载。
- `setup_22.x` 安装 Node.js 22 LTS。

### 验证

```bash
node --version   # v22.22.2
npm --version    # 10.9.7
```

### 注意事项

- `sudo npm install -g` 时需 `sudo -E` 传递代理变量。
- 若代理临时不可用，可单独为 npm 设置：
  ```bash
  npm config set proxy http://172.17.96.1:7890
  npm config set https-proxy http://172.17.96.1:7890
  ```

### 详细文档

参见 [WSL2 (Debian Trixie) 安装 Node.js](./2026-05-02-wsl2-nodejs-install.md)

## 四、Java (OpenJDK 21 LTS)

### 安装

```bash
sudo apt update -y
sudo apt install -y openjdk-21-jdk
```

> **注意**：Debian Trixie apt 源中无 JDK 11，仅有 JDK 21 和 JDK 25。JDK 21 是当前 LTS 版本，
> 向后兼容 JDK 11，多数 JDK 11 项目可直接在 JDK 21 上编译运行。
>
> 若确实需要 JDK 11，可通过 SDKMAN 安装：
> ```bash
> curl -s "https://get.sdkman.io" | bash
> source ~/.sdkman/bin/sdkman-init.sh
> sdk install java 11.0.26-tem
> ```

### 验证

```bash
java -version   # openjdk 21.0.11
javac -version  # javac 21.0.11
```

## 五、SSH Key（GitHub）

### 生成 ed25519 密钥

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519 -N ""
```

### 查看公钥

```bash
cat ~/.ssh/id_ed25519.pub
```

### 导入 GitHub

1. 打开 <https://github.com/settings/keys>
2. 点击 **New SSH Key**
3. Title 填写 `WSL2`（或自定义名称）
4. Key 粘贴公钥内容
5. 点击 **Add SSH Key**

### 验证连接

```bash
ssh -T git@github.com
# 首次需输 yes 确认 host fingerprint
# 成功输出: Hi <username>! You've authenticated...
```

### Git 基础配置

```bash
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

## 六、Docker 方案

### 推荐：Docker Desktop (Windows 端)

| 维度 | 说明 |
|------|------|
| daemon 位置 | Windows（由 WSL2 backend 管理容器） |
| CLI 可用性 | WSL2 终端直接使用 `docker` 命令 |
| 代理 | Clash TUN 直接覆盖拉镜像流量，**零配置** |
| 性能 | 容器实际跑在 WSL2 内，性能与原生无异 |

#### 安装步骤

1. 从 <https://www.docker.com/products/docker-desktop/> 下载 Windows 安装包
2. 安装时勾选 **Use WSL 2 instead of Hyper-V**
3. 进入 Settings → Resources → WSL Integration，启用地当前 Debian 发行版
4. 在 WSL2 终端验证：
   ```bash
   docker --version
   docker run hello-world
   ```

### 备选：Docker Engine (WSL2 内)

若选择纯命令行方案，需手动为 Docker daemon 配置代理：

```bash
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://<宿主机IP>:7890"
Environment="HTTPS_PROXY=http://<宿主机IP>:7890"
Environment="NO_PROXY=localhost,127.0.0.1,::1"
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 七、`.bashrc` 关键配置

现有 `~/.bashrc` 中已添加以下自定义配置：

```bash
# 1. 排除 Windows PATH（避免干扰）
export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '/mnt/' | tr '\n' ':')

# 2. Clash 代理自动配置
wsl_host_ip=$(ip route show default 2>/dev/null | awk '{print $3}')
if [ -n "$wsl_host_ip" ]; then
    export http_proxy="http://$wsl_host_ip:7890"
    export https_proxy="http://$wsl_host_ip:7890"
    export all_proxy="socks5://$wsl_host_ip:7890"
    export no_proxy="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
fi
unset wsl_host_ip
```

## 八、快速初始化（新环境）

若要在一台全新 WSL2 Debian 上复现本环境，下载并运行初始化脚本：

```bash
curl -fsSL https://raw.githubusercontent.com/livebug/vpblogs/main/scripts/setup-debian-dev.sh | bash
```

或者先下载再执行：

```bash
curl -fsSL -o setup-debian-dev.sh https://raw.githubusercontent.com/livebug/vpblogs/main/scripts/setup-debian-dev.sh
chmod +x setup-debian-dev.sh
bash setup-debian-dev.sh
```

> 脚本源码参见项目 `scripts/setup-debian-dev.sh`，可直接下载 [setup-debian-dev.sh](/resources/setup-debian-dev.sh)。

## 九、维护备忘

| 操作 | 命令 |
|------|------|
| 更新 Node.js | `sudo apt update && sudo apt upgrade nodejs` |
| 更新 JDK | `sudo apt update && sudo apt upgrade openjdk-21-jdk` |
| 查看代理状态 | `echo $http_proxy` |
| 临时关闭代理 | `unset http_proxy https_proxy all_proxy` |
| 重新加载 bashrc | `source ~/.bashrc` |
| 测试 GitHub SSH | `ssh -T git@github.com` |

## 十、相关文档

- [WSL2 + Clash TUN 代理配置](./2026-05-02-wsl2-clash-proxy.md)
- [Node.js 安装记录](../NodeJs/2026-05-02-wsl2-nodejs-install.md)
- [初始化脚本下载](/resources/setup-debian-dev.sh)
