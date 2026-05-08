---
title: npm EACCES 权限错误修复与 pnpm 安装
tags:
  - NodeJs
  - npm
  - pnpm
  - Environment
  - Setup
---

# npm EACCES 权限错误修复与 pnpm 安装

## 问题背景

在使用 `npm install -g` 全局安装包（如 pnpm）时，可能会遇到以下权限错误：

```
Error: EACCES: permission denied, mkdir '/usr/lib/node_modules/pnpm'
npm error     at async mkdir (node:internal/fs/promises:858:10)
npm error   errno: -13,
npm error   code: 'EACCES',
npm error   syscall: 'mkdir',
npm error   path: '/usr/lib/node_modules/pnpm'
```

### 原因分析

npm 全局安装目录默认指向 `/usr`，对应的实际路径为 `/usr/lib/node_modules/`，普通用户没有写入权限。这通常发生在：

- 首次在系统上配置 npm 时未正确设置全局目录
- 使用系统包管理器（如 apt）安装的 Node.js，npm 默认 prefix 为 `/usr`
- 之前使用了 `sudo npm install -g` 导致配置混乱

## 解决方案：更改 npm 全局安装目录

将 npm 全局安装目录从系统目录改为用户目录，这样以后都不再需要 `sudo`。

### 步骤 1：检查当前 npm prefix

```bash
npm config get prefix
```

如果输出为 `/usr`，说明当前全局安装目录需要 root 权限。

### 步骤 2：创建用户级全局目录并设置 prefix

```bash
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global
```

- `~/.npm-global` 是用户目录下的专用文件夹，用于存放全局安装的 npm 包
- `npm config set prefix` 将 npm 的全局安装前缀指向该目录

### 步骤 3：更新 PATH 环境变量

为了让终端能够找到全局安装的命令，需要将 `~/.npm-global/bin` 加入 PATH。

```bash
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

::: tip 其他 Shell 配置
- 如果你使用 **zsh**，请将配置写入 `~/.zshrc`
- 如果你使用 **fish**，配置文件为 `~/.config/fish/config.fish`
:::

### 步骤 4：验证

```bash
npm install -g pnpm
pnpm --version
```

如果没有权限错误，且 `pnpm --version` 能正常输出版本号，则配置成功。

## 验证全局目录是否已切换

```bash
npm config get prefix
# 应输出: /home/你的用户名/.npm-global

npm config list
# 查看完整的 npm 配置，确认 prefix 已更改
```

## 修改后的目录结构

```
~/.npm-global/
├── bin/              # 可执行文件的符号链接（如 pnpm）
│   └── pnpm -> ../lib/node_modules/pnpm/bin/pnpm.cjs
└── lib/
    └── node_modules/  # 全局安装的 npm 包
        └── pnpm/
```

## 已安装的全局包迁移

如果之前使用 `sudo` 安装了一些全局包，建议重新安装：

```bash
# 查看之前安装了哪些全局包
npm list -g --depth=0

# 逐个重新安装（在新 prefix 下，无需 sudo）
npm install -g <package-name>
```

## pnpm 简介

pnpm 是一个高效、节省磁盘空间的包管理器：

- **节省磁盘空间**：使用硬链接和符号链接，相同版本的包在磁盘上只存储一份
- **安装速度快**：比 npm 和 Yarn 更快，尤其在大型 monorepo 项目中
- **严格的依赖管理**：避免幽灵依赖（phantom dependencies）问题
- **原生支持 monorepo**：内置 workspace 功能

```bash
# 基本使用
pnpm install        # 安装依赖
pnpm add <pkg>      # 添加依赖
pnpm update         # 更新依赖
pnpm run <script>   # 运行脚本
```

## 常见问题

### 1. source 后 pnpm 仍提示 command not found

检查是否在正确的 shell 配置文件中添加了 PATH：

```bash
echo $SHELL           # 查看当前使用的 shell
cat ~/.bashrc | grep npm-global  # 确认配置已写入
```

如果使用 VSCode 终端，可能需要重启终端或 VSCode 窗口。

### 2. 想要恢复默认 prefix

```bash
npm config delete prefix
# 这会恢复到系统的默认值（通常是 /usr/local）
```

### 3. 多个 Node.js 版本（nvm）下的全局包

如果使用 nvm 管理 Node.js 版本，每个 Node.js 版本都有独立的全局包。建议在 nvm 环境下也运行以上配置，或使用 nvm 自带的全局包管理。

## 核心要点

| 知识点 | 说明 |
|--------|------|
| **EACCES 错误** | npm 全局安装 prefix 默认指向 `/usr`，普通用户无写入权限 |
| **根本解决** | `npm config set prefix ~/.npm-global` 将全局安装目录改为用户目录 |
| **PATH 配置** | 需将 `~/.npm-global/bin` 加入 PATH 才能直接使用全局命令 |
| **配置文件** | Bash → `~/.bashrc`，Zsh → `~/.zshrc` |
| **永久生效** | 配置写入 shell 配置文件后，每个新终端自动生效 |

## 总结

通过将 npm 全局安装目录改为 `~/.npm-global`，可以永久解决 `EACCES: permission denied` 权限错误。这样做的好处是：

- 不再需要 `sudo` 安装全局包，降低安全风险
- 全局包安装在用户目录下，备份和迁移更方便
- 不影响系统级别的 Node.js 安装