---
title: nvm 和 Node.js 安装指南
tags:
  - Frontend
  - NodeJs
  - Environment
  - Setup
---

# nvm 和 Node.js 安装指南

## 概述

nvm（Node Version Manager）是一个用于管理多个 Node.js 版本的工具。它允许你在同一台机器上安装、切换和使用不同版本的 Node.js，非常适合开发和测试环境。

## 安装 nvm

### Windows 系统

对于 Windows 系统，我们使用 nvm-windows（也称为 nvm for Windows）。

#### 步骤 1：下载安装程序

1. 访问 [nvm-windows 发布页面](https://github.com/coreybutler/nvm-windows/releases)
2. 下载最新版本的 `nvm-setup.exe` 安装程序

或者使用 PowerShell 直接下载：

```powershell
Invoke-WebRequest -Uri "https://github.com/coreybutler/nvm-windows/releases/download/1.1.12/nvm-setup.exe" -OutFile "nvm-setup.exe"
```

#### 步骤 2：运行安装程序

1. 以管理员身份运行 `nvm-setup.exe`
2. 按照安装向导完成安装
3. 安装完成后，重启终端（命令提示符或 PowerShell）

#### 步骤 3：验证安装

打开新的终端窗口，运行以下命令验证 nvm 是否安装成功：

```bash
nvm version
```

如果显示版本号（如 `1.1.12`），则表示安装成功。

### macOS/Linux 系统

对于 macOS 和 Linux 系统，使用原版 nvm：

```bash
# 使用 curl 安装
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# 或者使用 wget 安装
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
```

安装完成后，重启终端或运行：

```bash
source ~/.bashrc  # 或 source ~/.zshrc，取决于你的 shell
```

验证安装：

```bash
nvm --version
```

## 安装 Node.js

### 查看可用版本

安装 nvm 后，可以查看所有可用的 Node.js 版本：

```bash
nvm list available
```

### 安装 LTS（长期支持）版本

推荐安装最新的 LTS 版本：

```bash
# Windows
nvm install 24.15.0

# macOS/Linux
nvm install --lts
```

### 安装特定版本

如果需要安装特定版本：

```bash
nvm install 20.18.0  # 安装 Node.js 20.18.0
nvm install 18.20.3  # 安装 Node.js 18.20.3
```

### 设置默认版本

设置默认使用的 Node.js 版本：

```bash
nvm use 24.15.0
```

要使某个版本在新建的终端中默认使用：

```bash
nvm alias default 24.15.0
```

## 常用 nvm 命令

### 版本管理

```bash
# 查看已安装的版本
nvm list
nvm ls

# 查看当前使用的版本
nvm current

# 切换到指定版本
nvm use 24.15.0
nvm use 20.18.0

# 卸载指定版本
nvm uninstall 18.20.3
```

### 其他实用命令

```bash
# 查看 nvm 帮助
nvm --help

# 查看 Node.js 下载镜像（中国用户可能需要设置镜像）
nvm node_mirror https://npmmirror.com/mirrors/node/
nvm npm_mirror https://npmmirror.com/mirrors/npm/
```

## 验证安装

安装完成后，验证 Node.js 和 npm 是否正常工作：

```bash
# 检查 Node.js 版本
node --version

# 检查 npm 版本
npm --version

# 检查 npx 版本
npx --version
```

## 解决常见问题

### 1. PowerShell 执行策略错误

在 Windows PowerShell 中运行 npm 命令时，可能会遇到执行策略错误：

```
npm : 无法加载文件 ... 因为在此系统上禁止运行脚本。
```

**解决方案：**

1. **临时解决方案**（仅当前会话）：
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

2. **永久解决方案**（需要管理员权限）：
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   ```

3. **使用命令提示符（CMD）**：
   ```cmd
   npm --version
   ```

### 2. nvm 命令找不到

如果安装后 nvm 命令仍然找不到：

1. **Windows**：检查环境变量是否已正确设置
   - `NVM_HOME`：指向 nvm 安装目录
   - `NVM_SYMLINK`：指向 Node.js 符号链接目录
   - 确保 `%NVM_HOME%` 和 `%NVM_SYMLINK%` 已添加到 PATH

2. **macOS/Linux**：确保 shell 配置文件已正确加载
   ```bash
   source ~/.bashrc  # 或 source ~/.zshrc
   ```

### 3. 安装速度慢（中国用户）

对于中国用户，可以设置淘宝镜像加速下载：

```bash
# Windows
nvm node_mirror https://npmmirror.com/mirrors/node/
nvm npm_mirror https://npmmirror.com/mirrors/npm/

# macOS/Linux
export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/
export NVM_IOJS_ORG_MIRROR=https://npmmirror.com/mirrors/iojs/
```

## 最佳实践

1. **使用 LTS 版本**：生产环境推荐使用 LTS（长期支持）版本
2. **保持更新**：定期更新到新的 LTS 版本
3. **项目特定版本**：在项目中使用 `.nvmrc` 文件指定 Node.js 版本
   ```bash
   # 创建 .nvmrc 文件
   echo "24.15.0" > .nvmrc
   
   # 自动使用 .nvmrc 中指定的版本
   nvm use
   ```
4. **全局包管理**：使用 nvm 时，每个 Node.js 版本都有独立的全局包，安装全局包时需要先切换到对应版本

## 总结

nvm 是管理 Node.js 版本的强大工具，特别适合需要同时维护多个项目的开发者。通过 nvm，你可以轻松地在不同版本的 Node.js 之间切换，确保每个项目使用最适合的 Node.js 版本。

安装完成后，你可以开始使用 Node.js 开发应用程序，享受 JavaScript 全栈开发的便利。