// .vitepress/theme/index.ts
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import GitTimeline from './components/GitTimeline.vue'
import TagsPage from './components/TagsPage.vue'
import ToTop from './components/ToTop.vue'
import RangeJt from './components/RangeJt.vue'
import './custom.css'

// 只需添加以下一行代码，引入时间线样式
import "vitepress-markdown-timeline/dist/theme/index.css";

import { h } from 'vue'

export default {
  extends: DefaultTheme,
  Layout() {
    return h(DefaultTheme.Layout, null, {
      'layout-bottom': () => h(ToTop) // 注入到底部插槽
    })
  },
  enhanceApp({ app }) {
    // 注册自定义全局组件
    app.component('GitTimeline',GitTimeline);
    app.component("RandomJiTiao", RangeJt); // 标签页 
    app.component("TagsPage", TagsPage); // 标签页 
  }
} satisfies Theme