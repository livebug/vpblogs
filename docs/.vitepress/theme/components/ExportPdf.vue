<!-- 周报页面右下角的「导出 PDF」按钮：调用浏览器打印（另存为 PDF） -->
<template>
  <div v-if="visible" class="export-pdf" title="使用浏览器打印，目标选择“另存为 PDF”" @click="exportPdf">
    <span class="export-pdf__icon">PDF</span>
    <span class="export-pdf__text">导出</span>
  </div>
</template>

<script setup lang="ts">
import { computed, watchEffect } from 'vue'
import { useData } from 'vitepress'

const { page } = useData()

// 仅在「金融监管周报」栏目展示
const visible = computed(() => page.value.relativePath.startsWith('regwatch/'))

// 给 body 加标记类，用于把周报正文放宽到 A4 宽度（见 custom.css）
watchEffect(() => {
  if (typeof document === 'undefined') return
  document.body.classList.toggle('regwatch-page', visible.value)
})

function exportPdf() {
  window.print()
}
</script>

<style scoped>
.export-pdf {
  position: fixed;
  right: 20px;
  bottom: 72px;
  z-index: 998;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 46px;
  height: 46px;
  border-radius: 50%;
  cursor: pointer;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
  transition: transform 0.15s ease, box-shadow 0.15s ease;
}

.export-pdf:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.18);
  border-color: var(--vp-c-brand);
}

.export-pdf__icon {
  font-size: 11px;
  font-weight: 700;
  line-height: 1.1;
  color: var(--vp-c-brand);
  letter-spacing: 0.5px;
}

.export-pdf__text {
  font-size: 10px;
  line-height: 1.1;
  color: var(--vp-c-text-2);
}

@media print {
  .export-pdf {
    display: none !important;
  }
}
</style>
