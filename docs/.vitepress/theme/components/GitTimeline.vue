<!-- docs/.vitepress/theme/components/GitTimeline.vue -->
<script setup>
import { ref, onMounted } from 'vue'
import { useData, withBase } from 'vitepress';

const { site } = useData()
const commits = ref([])
const commitRepoUrl = ref('')
const isLoading = ref(true)
const error = ref(null)

commitRepoUrl.value = site.value.themeConfig.commitRepoUrl

// 加载提交数据
onMounted(async () => {
  try {
    isLoading.value = true
    const response = await fetch(withBase('/data/commits.json'))
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    
    const data = await response.json()
    commits.value = data
    error.value = null
  } catch (err) {
    console.error('数据加载失败:', err)
    error.value = err.message
    commits.value = [{ 
      hash: 'error',
      date: new Date().toLocaleDateString(),
      message: '加载提交历史失败',
      author: '系统'
    }]
  } finally {
    isLoading.value = false
  }
})

// 复制哈希值到剪贴板
const copyHash = async (hash) => {
  try {
    await navigator.clipboard.writeText(hash)
    // 这里可以添加一个 toast 通知，但为了简单起见，我们只是 console.log
    console.log(`已复制哈希值: ${hash}`)
  } catch (err) {
    console.error('复制失败:', err)
  }
}

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return ''
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('zh-CN', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch {
    return dateString
  }
}

// 重新加载数据
const loadData = async () => {
  try {
    isLoading.value = true
    error.value = null
    const response = await fetch(withBase('/data/commits.json'))
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    
    const data = await response.json()
    commits.value = data
  } catch (err) {
    console.error('数据加载失败:', err)
    error.value = err.message
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <div class="git-timeline" :class="{ loading: isLoading }">
    <!-- 加载状态 -->
    <div v-if="isLoading" class="loading-state">
      <div class="loading-item" v-for="n in 3" :key="n">
        <div class="loading-marker"></div>
        <div class="loading-content">
          <div class="loading-header">
            <div class="loading-hash"></div>
            <div class="loading-date"></div>
          </div>
          <div class="loading-message"></div>
          <div class="loading-author"></div>
        </div>
      </div>
    </div>

    <!-- 错误状态 -->
    <div v-else-if="error" class="error-state">
      <div class="error-icon">⚠️</div>
      <div class="error-message">
        <h3>数据加载失败</h3>
        <p>{{ error }}</p>
        <button class="retry-button" @click="loadData">重试</button>
      </div>
    </div>

    <!-- 正常状态 -->
    <template v-else>
      <div 
        v-for="(commit, index) in commits" 
        :key="commit.hash" 
        class="commit-item"
        :style="{ animationDelay: `${index * 0.1}s` }"
        @click="copyHash(commit.hash)"
        :title="`点击复制哈希值: ${commit.hash}`"
      >
        <div class="timeline-marker"></div>
        <div class="timeline-content">
          <div class="commit-header">
            <a 
              :href="`${commitRepoUrl}commit/${commit.hash}`" 
              target="_blank"
              class="commit-hash"
              @click.stop
            >
              {{ commit.hash.substring(0, 8) }}
              <span class="copy-hint">📋</span>
            </a>
            <span class="commit-date">{{ formatDate(commit.date) }}</span>
          </div>
          <div class="commit-message">{{ commit.message }}</div>
          <div class="commit-author">
            <span class="author-avatar">👤</span>
            {{ commit.author }}
          </div>
        </div>
      </div>

      <!-- 空状态 -->
      <div v-if="commits.length === 0" class="empty-state">
        <div class="empty-icon">📭</div>
        <div class="empty-message">
          <h3>暂无提交记录</h3>
          <p>还没有任何提交历史</p>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
.git-timeline {
  position: relative;
  margin: 3rem 0;
  background: linear-gradient(145deg, var(--vp-c-bg-soft) 0%, var(--vp-c-bg) 100%);
  border-radius: 16px;
  box-shadow: 
    0 4px 20px rgba(0, 0, 0, 0.05),
    0 1px 3px rgba(0, 0, 0, 0.1),
    inset 0 1px 0 rgba(255, 255, 255, 0.1);
  overflow: hidden;
  border: 1px solid var(--vp-c-divider-light);
}

.git-timeline::before {
  content: '';
  position: absolute;
  top: 0;
  left: 32px;
  width: 2px;
  height: 100%;
  background: linear-gradient(
    to bottom,
    transparent,
    var(--vp-c-brand-light) 20%,
    var(--vp-c-brand-light) 80%,
    transparent
  );
  opacity: 0.3;
}

.commit-item {
  position: relative;
  padding: 1.5rem 1.8rem 1.5rem 3.5rem;
  border-bottom: 1px solid var(--vp-c-divider-light);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
  animation: fadeInUp 0.6s ease-out;
  animation-fill-mode: both;
}

.commit-item:last-child {
  border-bottom: none;
}

.commit-item:hover {
  background: linear-gradient(90deg, rgba(var(--vp-c-brand-rgb), 0.05) 0%, transparent 100%);
  transform: translateX(4px);
  box-shadow: inset 4px 0 0 var(--vp-c-brand);
}

.commit-item:hover .timeline-marker {
  transform: scale(1.2);
  box-shadow: 
    0 0 0 4px rgba(var(--vp-c-brand-rgb), 0.1),
    0 4px 12px rgba(var(--vp-c-brand-rgb), 0.3);
}

.commit-item:hover .commit-hash {
  color: var(--vp-c-brand);
  text-shadow: 0 0 8px rgba(var(--vp-c-brand-rgb), 0.3);
}

.commit-item:hover .commit-date {
  background: var(--vp-c-brand);
  color: white;
  transform: translateY(-1px);
}

.timeline-marker {
  position: absolute;
  left: 24px;
  top: 1.8rem;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--vp-c-brand) 0%, var(--vp-c-brand-light) 100%);
  border: 3px solid var(--vp-c-bg);
  box-shadow: 
    0 2px 8px rgba(0, 0, 0, 0.1),
    0 0 0 2px rgba(var(--vp-c-brand-rgb), 0.2);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  z-index: 2;
}

.timeline-marker::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: white;
  box-shadow: 0 0 4px rgba(255, 255, 255, 0.8);
}

.commit-header {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: center;
  margin-bottom: 0.8rem;
}

.commit-hash {
  font-family: var(--vp-font-family-mono);
  font-size: 0.95em;
  color: var(--vp-c-text-2);
  text-decoration: none;
  font-weight: 600;
  letter-spacing: 0.5px;
  transition: all 0.3s ease;
  padding: 4px 8px;
  background: var(--vp-c-bg-soft);
  border-radius: 6px;
  border: 1px solid var(--vp-c-divider-light);
}

.commit-hash:hover {
  color: var(--vp-c-brand);
  background: rgba(var(--vp-c-brand-rgb), 0.1);
  border-color: var(--vp-c-brand-light);
  text-decoration: none;
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(var(--vp-c-brand-rgb), 0.2);
}

.commit-date {
  color: var(--vp-c-text-2);
  font-size: 0.85em;
  font-weight: 500;
  background: var(--vp-c-bg-soft);
  padding: 4px 10px;
  border-radius: 20px;
  border: 1px solid var(--vp-c-divider-light);
  transition: all 0.3s ease;
  letter-spacing: 0.3px;
}

.commit-message {
  color: var(--vp-c-text-1);
  margin-bottom: 0.5rem;
  font-size: 1.1em;
  font-weight: 500;
  line-height: 1.5;
  word-break: break-word;
  position: relative;
  padding-left: 12px;
}

.commit-message::before {
  content: '📝';
  position: absolute;
  left: -12px;
  opacity: 0.6;
}

.commit-author {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: var(--vp-c-text-2);
  font-size: 0.9em;
  font-weight: 500;
  padding: 4px 10px;
  background: var(--vp-c-bg-soft);
  border-radius: 20px;
  border: 1px solid var(--vp-c-divider-light);
  transition: all 0.3s ease;
}

.commit-author::before {
  content: '👤';
  font-size: 0.9em;
}

.commit-author:hover {
  background: rgba(var(--vp-c-brand-rgb), 0.1);
  color: var(--vp-c-brand);
  border-color: var(--vp-c-brand-light);
  transform: translateY(-1px);
}

/* 动画效果 */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 为每个提交项添加延迟动画 */
.commit-item:nth-child(1) { animation-delay: 0.1s; }
.commit-item:nth-child(2) { animation-delay: 0.2s; }
.commit-item:nth-child(3) { animation-delay: 0.3s; }
.commit-item:nth-child(4) { animation-delay: 0.4s; }
.commit-item:nth-child(5) { animation-delay: 0.5s; }
.commit-item:nth-child(6) { animation-delay: 0.6s; }
.commit-item:nth-child(7) { animation-delay: 0.7s; }
.commit-item:nth-child(8) { animation-delay: 0.8s; }
.commit-item:nth-child(9) { animation-delay: 0.9s; }
.commit-item:nth-child(10) { animation-delay: 1.0s; }

/* 响应式设计 */
@media (max-width: 768px) {
  .git-timeline {
    margin: 2rem 0;
    border-radius: 12px;
  }
  
  .git-timeline::before {
    left: 28px;
  }
  
  .commit-item {
    padding: 1.2rem 1.2rem 1.2rem 2.8rem;
  }
  
  .timeline-marker {
    left: 20px;
    width: 16px;
    height: 16px;
  }
  
  .commit-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .commit-hash,
  .commit-date,
  .commit-author {
    font-size: 0.85em;
  }
  
  .commit-message {
    font-size: 1em;
    padding-left: 8px;
  }
  
  .commit-message::before {
    left: -8px;
  }
}

/* 暗色模式优化 */
:global(.dark) .git-timeline {
  box-shadow: 
    0 4px 20px rgba(0, 0, 0, 0.2),
    0 1px 3px rgba(0, 0, 0, 0.3),
    inset 0 1px 0 rgba(255, 255, 255, 0.05);
}

:global(.dark) .commit-hash,
:global(.dark) .commit-date,
:global(.dark) .commit-author {
  background: rgba(255, 255, 255, 0.05);
  border-color: rgba(255, 255, 255, 0.1);
}

:global(.dark) .commit-item:hover {
  background: linear-gradient(90deg, rgba(var(--vp-c-brand-rgb), 0.1) 0%, transparent 100%);
}

/* 加载状态、错误状态、空状态样式 */
.loading-state {
  padding: 2rem;
}

.loading-item {
  position: relative;
  padding: 1.5rem 1.8rem 1.5rem 3.5rem;
  border-bottom: 1px solid var(--vp-c-divider-light);
}

.loading-item:last-child {
  border-bottom: none;
}

.loading-marker {
  position: absolute;
  left: 24px;
  top: 1.8rem;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: var(--vp-c-divider-light);
  animation: pulse 1.5s ease-in-out infinite;
}

.loading-hash,
.loading-date,
.loading-message,
.loading-author {
  background: var(--vp-c-divider-light);
  border-radius: 4px;
  animation: pulse 1.5s ease-in-out infinite;
}

.loading-hash {
  width: 120px;
  height: 24px;
  margin-bottom: 8px;
}

.loading-date {
  width: 80px;
  height: 20px;
}

.loading-message {
  width: 100%;
  height: 20px;
  margin: 12px 0 8px 0;
}

.loading-author {
  width: 60px;
  height: 18px;
}

.error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem 2rem;
  text-align: center;
  color: var(--vp-c-text-2);
}

.error-icon {
  font-size: 3rem;
  margin-bottom: 1.5rem;
  opacity: 0.7;
}

.error-message h3 {
  color: var(--vp-c-text-1);
  margin-bottom: 0.5rem;
  font-size: 1.2em;
}

.error-message p {
  margin-bottom: 1.5rem;
  font-size: 0.95em;
  opacity: 0.8;
}

.retry-button {
  padding: 8px 20px;
  background: var(--vp-c-brand);
  color: white;
  border: none;
  border-radius: 20px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.retry-button:hover {
  background: var(--vp-c-brand-dark);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(var(--vp-c-brand-rgb), 0.3);
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem 2rem;
  text-align: center;
  color: var(--vp-c-text-2);
}

.empty-icon {
  font-size: 3rem;
  margin-bottom: 1.5rem;
  opacity: 0.5;
}

.empty-message h3 {
  color: var(--vp-c-text-1);
  margin-bottom: 0.5rem;
  font-size: 1.2em;
}

.empty-message p {
  font-size: 0.95em;
  opacity: 0.8;
}

/* 复制提示 */
.copy-hint {
  margin-left: 6px;
  opacity: 0.6;
  font-size: 0.9em;
  transition: opacity 0.3s ease;
}

.commit-hash:hover .copy-hint {
  opacity: 1;
  transform: scale(1.1);
}

.author-avatar {
  opacity: 0.7;
}

/* 加载状态动画 */
@keyframes pulse {
  0%, 100% {
    opacity: 0.6;
  }
  50% {
    opacity: 0.3;
  }
}
</style>
