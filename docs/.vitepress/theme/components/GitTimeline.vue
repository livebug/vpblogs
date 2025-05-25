<!-- docs/.vitepress/theme/components/GitTimeline.vue -->
<script setup>
import { ref } from 'vue'
import { useData, withBase } from 'vitepress';

const { site } = useData()
const commits = ref([])
const commitRepoUrl =ref('')

commitRepoUrl.value = site.value.themeConfig.commitRepoUrl

// 加载提交数据

// 加载提交数据
fetch(withBase('/data/commits.json'))
  .then(res => res.json())
  .then(data => commits.value = data)
  .catch(error => {
        console.error('数据加载失败:')
        commits.value = [{ message: '加载提交历史失败' }]
      })

</script>

<template>
  <div class="git-timeline">
    <div v-for="commit in commits" :key="commit.hash" class="commit-item">
      <div class="timeline-marker"></div>
      <div class="timeline-content">
        <div class="commit-header">
          <a :href="`${commitRepoUrl}commit/${commit.hash}`" target="_blank"
            class="commit-hash">
            {{ commit.hash }}
          </a>
          <span class="commit-date">{{ commit.date }}</span>
        </div>
        <div class="commit-message">{{ commit.message }}</div>
        <div class="commit-author">👤 {{ commit.author }}</div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.git-timeline {
  position: relative;
  padding-left: 32px;
  margin: 2.5rem 0;
  background: var(--vp-c-bg-soft);
  border-radius: 10px;
  box-shadow: 0 2px 12px 0 rgba(60,60,60,0.04);
}

.commit-item {
  position: relative;
  padding: 1.2rem 0 1.2rem 2.5rem;
  border-left: 3px solid var(--vp-c-divider);
  transition: background 0.2s;
}

.commit-item:hover {
  background: var(--vp-c-bg);
}

.timeline-marker {
  position: absolute;
  left: -11px;
  top: 1.7rem;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--vp-c-brand) 60%, #fff 100%);
  border: 3px solid #fff;
  box-shadow: 0 2px 8px 0 rgba(60,60,60,0.08);
  transition: background 0.2s;
}

.commit-header {
  display: flex;
  gap: 1.2rem;
  align-items: baseline;
  margin-bottom: 0.5rem;
}

.commit-hash {
  font-family: var(--vp-font-family-mono);
  font-size: 1em;
  color: var(--vp-c-brand);
  text-decoration: none;
  font-weight: 600;
  letter-spacing: 0.5px;
  transition: color 0.2s;
}

.commit-hash:hover {
  text-decoration: underline;
  color: var(--vp-c-brand-dark);
}

.commit-date {
  color: var(--vp-c-text-2);
  font-size: 0.95em;
  background: var(--vp-c-bg-soft);
  padding: 2px 8px;
  border-radius: 6px;
}

.commit-message {
  color: var(--vp-c-text-1);
  margin-bottom: 0.3rem;
  font-size: 1.08em;
  font-weight: 500;
  word-break: break-word;
}

.commit-author {
  color: var(--vp-c-text-2);
  font-size: 0.9em;
  font-style: italic;
  margin-top: 2px;
}
</style>