---
title: WSL2 (Debian Trixie) 安装 Node.js
tags:
  - NodeJs
  - WSL2
  - Debian
  - Setup
  - Proxy
---

# WSL2 (Debian Trixie) 安装 Node.js

## 环境

| 项目 | 值 |
|------|-----|
| 系统 | Debian GNU/Linux 13 (Trixie) |
| WSL 版本 | WSL2 |
| 代理 | Clash TUN 模式，通过 `http_proxy` 连接宿主机 `172.17.96.1:7890` |
| 架构 | amd64 |

## 安装方式

使用 [NodeSource](https://github.com/nodesource/distributions) 官方 apt 源安装，而非 Debian 自带的旧版本。

### 步骤 1：安装依赖

```bash
sudo apt update -y
sudo apt install -y curl
```

### 步骤 2：添加 NodeSource 源并安装

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install nodejs -y
```

- `-E` 保留 `http_proxy` 环境变量，使 apt 通过 Clash 代理下载。
- `setup_22.x` 安装 Node.js 22 LTS。

### 步骤 3：验证

```bash
node --version   # v22.22.2
npm --version    # 10.9.7
```

## 安装结果

| 工具 | 版本 |
|------|------|
| Node.js | v22.22.2 (LTS) |
| npm | 10.9.7 |

## 注意事项

- 如果切换代理端口或关闭代理，npm 下载包时可能需要临时设置：
  ```bash
  npm config set proxy http://172.17.96.1:7890
  npm config set https-proxy http://172.17.96.1:7890
  ```
- 安装全局包时建议使用 `sudo -E` 确保代理环境变量传递：
  ```bash
  sudo -E npm install -g <package>
  ```

## 相关文档

- [WSL2 + Clash TUN 模式代理配置](../DevEnv/2026-05-02-wsl2-clash-proxy.md)
- [WSL2 Debian 全栈开发环境搭建](../DevEnv/2026-05-02-wsl2-debian-dev-setup.md)