---
title: 编程字体推荐——中英文等宽
tags:
  - DevEnv
  - VSCode
---

# 编程字体推荐——中英文等宽字体

> 选一个舒服的编程字体，提升日常开发体验。

## 推荐：Maple Mono NF CN

**Maple Mono** 是一个带连字 (ligatures) 和 Nerd Font 图标的开源等宽字体，中英文宽度完美 2:1。

GitHub 地址：[subframe7536/maple-font](https://github.com/subframe7536/Maple-font)

### 特点

- ✅ 中英文严格 2:1 等宽对齐
- ✅ 圆角设计，长时间阅读不疲劳
- ✅ 内置 Nerd Font 图标，终端美化无需额外安装
- ✅ 连字支持（`=>` `!=` `<=` 等显示为合并字符）
- ✅ 多字重可选（Light / Regular / SemiBold / Bold）

### 安装

```bash
# macOS
brew install --cask font-maple-mono-nf-cn

# Arch Linux
yay -S ttf-maple-mono-nf-cn

# 通用方式
# 从 GitHub Release 下载字体文件，双击安装
```

### VSCode 配置

```json
{
  "editor.fontFamily": "'Maple Mono NF CN', 'Cascadia Code', 'Fira Code', monospace",
  "editor.fontLigatures": true,
  "editor.fontSize": 15,
  "editor.lineHeight": 1.6
}
```

## 其他优秀等宽字体

| 字体 | 特点 | 适合场景 |
|:---|:---|:---|
| **Cascadia Code** | 微软出品，Windows Terminal 默认 | Windows 开发 |
| **Fira Code** | 连字丰富，社区最大 | 通用编程 |
| **JetBrains Mono** | JetBrains IDE 默认，清晰锐利 | Java/Kotlin 开发 |
| **Sarasa Gothic (更纱黑体)** | 中英文等宽，支持 CJK | 中文环境 |
| **Intel One Mono** | Intel 出品，可读性极佳 | 低视力友好 |

## Windows 字体渲染优化

在高分屏（2K/4K）上，Windows 的字体渲染可能偏小或模糊。

**建议设置：**

1. **Windows 11**：设置 → 辅助功能 → 文本大小 → 拖动滑块到 110%-125%
2. 该设置仅放大文本，不影响图标和布局，很适合高分屏

## 对比效果

| 普通字体 | Maple Mono |
|:---|:---|
| 中文和English对不齐 | 中文与English完美2:1对齐 |
| `->` 显示为两个字符 | `->` 自动连字为箭头 |

对于写技术文档或 Markdown 频繁中英混排的场景，等宽对齐可以显著提升排版美观度。
