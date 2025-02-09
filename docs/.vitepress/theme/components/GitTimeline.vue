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
  padding-left: 20px;
  margin: 2rem 0;
}

.commit-item {
  position: relative;
  padding: 1rem 0 1rem 2rem;
  border-left: 2px solid var(--vp-c-divider);
}

.timeline-marker {
  position: absolute;
  left: -7px;
  top: 1.5rem;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: var(--vp-c-brand);
  border: 2px solid white;
}

.commit-header {
  display: flex;
  gap: 1rem;
  align-items: baseline;
  margin-bottom: 0.5rem;
}

.commit-hash {
  font-family: var(--vp-font-family-mono);
  font-size: 0.9em;
  color: var(--vp-c-brand);
  text-decoration: none;
}

.commit-hash:hover {
  text-decoration: underline;
}

.commit-date {
  color: var(--vp-c-text-2);
  font-size: 0.9em;
}

.commit-message {
  color: var(--vp-c-text-1);
  margin-bottom: 0.25rem;
}

.commit-author {
  color: var(--vp-c-text-2);
  font-size: 0.85em;
}
</style>