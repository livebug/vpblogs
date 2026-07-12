---
title: Obsidian 使用体验与 VitePress 集成
tags:
  - DevEnv
  - markdown
---

# Obsidian + VitePress 写作工作流

> 使用 Obsidian 管理 Markdown 笔记，直接作为 VitePress 博客的内容源。

## 为什么选择 Obsidian

[Obsidian](https://obsidian.md/) 是一个基于本地 Markdown 文件的知识管理工具，相比 Notion、语雀等在线工具，有几个显著优势：

| 特性 | Obsidian | 在线笔记 |
|:---|:---|:---|
| 数据存储 | 本地 Markdown 文件 | 云端数据库 |
| 离线使用 | ✅ 完全离线 | ❌ 需要网络 |
| Git 版本控制 | ✅ 天然支持 | ❌ 导出后才能 |
| VitePress 集成 | 直接读取 docs 目录 | 需要导出/转换 |
| 插件生态 | 丰富（社区插件 1000+） | 各有差异 |

## 集成步骤

### 1. 下载与安装

从 [obsidian.md](https://obsidian.md/) 下载对应平台版本。

### 2. 配置笔记库

将 Obsidian 的笔记库（Vault）直接设为 VitePress 的 `docs` 目录：

```
vpblogs/
├── docs/          ← Obsidian Vault 指向这里
│   ├── learn/
│   ├── note/
│   ├── think/
│   └── write/
├── package.json
└── pnpm-lock.yaml
```

### 3. 工作流程

```mermaid
flowchart LR
    A[Obsidian 写作] --> B[本地预览 vite dev]
    B --> C[Git 提交]
    C --> D[GitHub Actions]
    D --> E[自动部署到 Pages]
```

1. **在 Obsidian 中写作**：享受实时预览、双向链接、标签管理
2. **终端 `pnpm run docs:dev`**：VitePress 热重载预览
3. **手动 Git 提交**：Obsidian 的 Git 插件体验一般，建议用命令行或 VSCode 提交
4. **推送触发部署**：GitHub Actions 自动构建发布

### 4. 推荐插件

| 插件 | 用途 |
|:---|:---|
| **Paste Image Rename** | 粘贴图片时自动规范命名 |
| **Tag Wrangler** | 批量管理标签 |
| **Calendar** | 按日期查看笔记 |
| **Templater** | 创建文章模板 |

### 5. 调整图片格式和位置

在 Obsidian 中粘贴图片后，可以将图片存放在 `docs/public/images/` 目录下：

```markdown
![](../../public/images/your-image.png)
```

> **提示**：`public` 目录下的文件会被 VitePress 原样复制到输出目录，路径相对于 `docs` 根目录。

## 常见问题

### Obsidian Git 插件怎么用？

社区有 `Obsidian Git` 插件可以自动提交，但由于 VitePress 构建脚本 (`git-log-to-json.js`) 依赖准确的提交信息，建议手动在终端提交以获得更清晰的 commit message。

### 图片不显示？

检查 `public/images/` 目录是否存在，以及 Markdown 中的相对路径是否正确。
