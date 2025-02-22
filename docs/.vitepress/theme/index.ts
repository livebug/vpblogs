// .vitepress/theme/index.ts
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import GitTimeline from './components/GitTimeline.vue'
import TagsPage from './components/TagsPage.vue'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    // 注册自定义全局组件
    app.component('GitTimeline',GitTimeline);
    app.component("TagsPage", TagsPage); // 标签页

  }
} satisfies Theme