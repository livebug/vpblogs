---
title: CSS 用户代理样式表与重置方案
tags:
  - Frontend
  - CSS
---

# CSS 用户代理样式表 (User Agent Stylesheet)

> 理解浏览器默认样式，掌握 CSS Reset 和 Normalize 的区别。

## 什么是用户代理样式表

**用户代理样式表**（User Agent Stylesheet）是浏览器内置的默认样式表。当你写一个裸 HTML 页面时，`<h1>` 会显示为大字号粗体、`<ul>` 会有缩进和圆点——这些都来自浏览器的默认样式。

```html
<!-- 没有写任何 CSS -->
<h1>这是一级标题</h1>
<p>这是段落，段落之间有默认间距。</p>
<ul>
  <li>列表项有默认的圆点和缩进</li>
</ul>
```

在 Chrome DevTools 的 Styles 面板中，你会看到带有 `user agent stylesheet` 标注的样式规则。

## 各浏览器的差异

不同浏览器内核的默认样式存在细微差异：

| 浏览器 | 内核 | 默认样式特点 |
|:---|:---|:---|
| Chrome / Edge | Blink | 较标准的默认样式 |
| Firefox | Gecko | 略有不同的默认边距 |
| Safari | WebKit | 表单元素样式差异大 |

## 解决方案

### 方案一：添加 DOCTYPE

```html
<!DOCTYPE html>
```

这是最基础的修复——告诉浏览器使用标准模式渲染，而不是怪异模式 (Quirks Mode)。

### 方案二：CSS Reset（清零）

完全清除所有默认样式，从零开始：

```css
/* 经典 Reset */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

ul, ol {
  list-style: none;
}

a {
  text-decoration: none;
  color: inherit;
}
```

**适合场景**：UI 组件库开发、完全自定义的设计系统。

### 方案三：Normalize.css（标准化）

保留有用的默认样式，只修正跨浏览器差异：

```bash
npm install normalize.css
```

```css
@import 'normalize.css';
```

**适合场景**：内容型网站（博客、文档站），希望保留默认的排版层次。

### 方案四：VitePress 的做法

VitePress 本身已经处理了大部分默认样式差异，你通常不需要额外引入 Reset 或 Normalize。如果需要覆盖特定默认样式：

```css
/* 在 .vitepress/theme/custom.css 中 */
.vp-doc ul {
  list-style: disc;
  padding-left: 1.5em;
}
```

## 常见问题

**Q: 加了 Reset 后 h1 和正文一样大了怎么办？**

A: 需要重新声明标题的字体大小。Reset 清零了所有样式，你需要显式定义每个元素的样式。

**Q: `!important` 和用户代理样式冲突？**

A: 通常不需要 `!important`。如果确实无法覆盖，检查选择器的优先级是否足够。`!important` 是最后的武器，滥用会让样式难以维护。
