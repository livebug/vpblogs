// .vitepress/theme/index.ts
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import GitTimeline from './components/GitTimeline.vue'
import TagsPage from './components/TagsPage.vue'
import ToTop from './components/ToTop.vue'
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
    app.component("TagsPage", TagsPage); // 标签页 
  }
} satisfies Theme