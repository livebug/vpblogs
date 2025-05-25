<!-- 一个在页面右下角，点击返回顶部的按钮组件 -->
<template>
  <div 
    v-show="visible" 
    class="back-to-top" 
    @click="scrollToTop"
  >
    ↑
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue' // 导入 Vue 的 ref 和 onMounted

const visible = ref(false) // 定义响应式变量，控制按钮显示与否

onMounted(() => {
    // 组件挂载后执行
    window.addEventListener('scroll', () => {
        // 监听窗口滚动事件
        visible.value = window.scrollY > 300 // 当滚动高度大于 300 时显示按钮
    })
})

const scrollToTop = () => {
    // 返回顶部的方法
    window.scrollTo({ top: 0, behavior: 'smooth' }) // 平滑滚动到顶部
}
</script>

<style scoped>
.back-to-top {
  position: fixed;
  right: 20px;
  bottom: 20px;
  width: 40px;
  height: 40px;
  background: var(--vp-c-brand);
  color: white;
  border-radius: 50%;
  cursor: pointer;
  text-align: center;
  line-height: 40px;
  z-index: 999;
}
</style>