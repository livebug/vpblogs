---
title: vitepress 时间轴组件 用于展示git提交信息
tags:
  - VitePress
  - Vue3
---

# vitepress 时间轴组件 用于展示git提交信息


## 遇到的问题

1. 开始使用 fetch 访问静态资源来生成组件，但是到build时一直报错。

分析原因就是 build 时要生成静态页面，组件会把访问的URL转为静态的，调整为了直接读取json的方式。

又经过实验，build的报错是个烟雾弹！！

先说明一个前提，非常关键， `vitepress` 最终是以静态文件的形式部署到 `github`   `page` 的，所以自定义组件中 `api` 的访问都会在 `build` 时被处理为静态页面，所以在 `dev` 时正常访问的 `API` ，到 `build` 时就会报错， `api` 访问失效，是因为只有当应用服务启动时，前端直接访问/data/commits.json才不报错。

==build时报错，真正部署时并不会有问题，关键是API的路径对。==

## 开发说明

大体思路：新增一个工具脚本，在项目启动时会扫面git 提交信息，生成提交json，组件读取这个json文件，生成时间轴内容

1. 新增组件 `GitTimeline.vue` 
```
 └─theme
    ├─components
    │    └─ GitTimeline.vue
    └─index.ts
```

2. 全局注册，在 index.ts 中
```typescript
// .vitepress/theme/index.ts
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import GitTimeline from './components/GitTimeline.vue'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    // 注册自定义全局组件
    app.component('GitTimeline',GitTimeline)
  }
} satisfies Theme
```

然后在页面中既可以使用组件了 `<GitTimeline />` 
