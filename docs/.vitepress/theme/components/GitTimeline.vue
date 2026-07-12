<!-- Git 提交历史组件 — 简洁卡片布局 -->
<script setup>
import { ref, onMounted, computed } from 'vue'
import { useData, withBase } from 'vitepress'

const { site } = useData()
const commits = ref([])
const commitRepoUrl = ref('')
const isLoading = ref(true)
const error = ref(null)
const copiedHash = ref('')

commitRepoUrl.value = site.value.themeConfig.commitRepoUrl

const shortHash = (h) => h?.substring(0, 7) ?? 'unknown'

const formatDate = (d) => {
  if (!d) return ''
  try {
    return new Date(d).toLocaleDateString('zh-CN', {
      year: 'numeric', month: '2-digit', day: '2-digit',
      hour: '2-digit', minute: '2-digit'
    })
  } catch { return d }
}

// 按年月分组
const groupedCommits = computed(() => {
  const groups = {}
  for (const c of commits.value) {
    try {
      const d = new Date(c.date)
      const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
      if (!groups[key]) groups[key] = { year: d.getFullYear(), month: String(d.getMonth() + 1).padStart(2, '0'), items: [] }
      groups[key].items.push(c)
    } catch {
      if (!groups['----']) groups['----'] = { year: '·', month: '··', items: [] }
      groups['----'].items.push(c)
    }
  }
  return Object.entries(groups).sort((a, b) => b[0].localeCompare(a[0]))
})

const loadData = async () => {
  try {
    isLoading.value = true
    error.value = null
    const resp = await fetch(withBase('/data/commits.json'))
    if (!resp.ok) throw new Error(`HTTP ${resp.status}`)
    commits.value = await resp.json()
  } catch (err) {
    error.value = err.message
  } finally {
    isLoading.value = false
  }
}

const copyHash = async (hash) => {
  try {
    await navigator.clipboard.writeText(hash)
    copiedHash.value = hash
    setTimeout(() => { copiedHash.value = '' }, 1500)
  } catch {}
}

onMounted(loadData)
</script>

<template>
  <div class="gh-timeline">

    <!-- 统计 -->
    <div class="gh-stats" v-if="!isLoading && !error">
      <span>{{ commits.length }} commits</span>
      <span class="gh-dot">·</span>
      <span>{{ groupedCommits.length }} groups</span>
    </div>

    <!-- 骨架 -->
    <div v-if="isLoading" class="gh-skel">
      <div v-for="n in 4" :key="n" class="gh-skel-row">
        <span class="skel-hash"></span>
        <span class="skel-date"></span>
        <span class="skel-msg"></span>
      </div>
    </div>

    <!-- 错误 -->
    <div v-else-if="error" class="gh-err">
      <p>⚠ 加载失败：{{ error }}</p>
      <button @click="loadData">重试</button>
    </div>

    <!-- 列表 -->
    <template v-else>
      <div v-if="!commits.length" class="gh-empty">暂无提交记录</div>

      <div v-for="[key, group] in groupedCommits" :key="key" class="gh-group">
        <div class="gh-month-head">
          <span>{{ group.year }} 年 {{ group.month }} 月</span>
          <span class="gh-month-n">{{ group.items.length }}</span>
        </div>

        <div
          v-for="commit in group.items"
          :key="commit.hash"
          class="gh-row"
          @click="copyHash(commit.hash)"
          :title="`复制 ${shortHash(commit.hash)}`"
        >
          <a
            :href="`${commitRepoUrl}commit/${commit.hash}`"
            target="_blank"
            class="gh-hash"
            @click.stop
          >{{ shortHash(commit.hash) }}</a>

          <span class="gh-date">{{ formatDate(commit.date) }}</span>

          <span class="gh-msg">{{ commit.message }}</span>

          <span class="gh-copied" v-if="copiedHash === commit.hash">已复制</span>

          <span class="gh-auth">{{ commit.author }}</span>
        </div>
      </div>
    </template>

  </div>
</template>

<style scoped>
.gh-timeline {
  font-family: var(--vp-font-family-base);
}

/* 统计 */
.gh-stats {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 24px;
  font-size: 0.82rem;
  color: var(--vp-c-text-3);
  font-family: var(--vp-font-family-mono);
}
.gh-dot { opacity: 0.4; }

/* 骨架 */
.gh-skel {
  display: flex;
  flex-direction: column;
  gap: 0;
  border: 1px solid var(--vp-c-divider);
  border-radius: 10px;
  overflow: hidden;
}
.gh-skel-row {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 12px 18px;
  border-bottom: 1px solid var(--vp-c-divider);
}
.gh-skel-row:last-child { border-bottom: none; }
.skel-hash, .skel-date, .skel-msg {
  height: 14px;
  border-radius: 4px;
  background: var(--vp-c-divider);
  animation: skel-pulse 1.5s ease-in-out infinite;
}
.skel-hash { width: 60px; flex-shrink: 0; }
.skel-date { width: 100px; flex-shrink: 0; }
.skel-msg  { flex: 1; }
@keyframes skel-pulse {
  0%, 100% { opacity: 0.35; }
  50% { opacity: 0.7; }
}

/* 错误 / 空 */
.gh-err, .gh-empty {
  text-align: center;
  padding: 40px;
  color: var(--vp-c-text-3);
}
.gh-err button {
  margin-top: 10px;
  padding: 5px 18px;
  border: 1px solid var(--vp-c-brand);
  background: transparent;
  color: var(--vp-c-brand);
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.85rem;
}
.gh-err button:hover {
  background: var(--vp-c-brand);
  color: #fff;
}

/* 月份分组 */
.gh-group {
  margin-bottom: 24px;
}
.gh-month-head {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 0 6px;
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--vp-c-text-1);
  border-bottom: 2px solid var(--vp-c-divider);
  margin-bottom: 4px;
}
.gh-month-n {
  font-size: 0.68rem;
  font-weight: 500;
  color: var(--vp-c-text-3);
  background: var(--vp-c-bg-soft);
  padding: 1px 8px;
  border-radius: 10px;
  font-family: var(--vp-font-family-mono);
}

/* 单行 */
.gh-row {
  display: flex;
  align-items: baseline;
  gap: 12px;
  padding: 9px 14px;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.18s;
  flex-wrap: wrap;
  position: relative;
}
.gh-row:hover {
  background: var(--vp-c-bg-soft);
}

/* hash */
.gh-hash {
  font-family: var(--vp-font-family-mono);
  font-size: 0.78rem;
  color: var(--vp-c-text-3);
  text-decoration: none;
  flex-shrink: 0;
  min-width: 54px;
  padding: 1px 6px;
  border-radius: 4px;
  border: 1px solid transparent;
  transition: all 0.2s;
}
.gh-hash:hover {
  color: var(--vp-c-brand);
  border-color: var(--vp-c-brand);
  background: rgba(var(--vp-c-brand-rgb), 0.05);
}

/* 日期 */
.gh-date {
  font-family: var(--vp-font-family-mono);
  font-size: 0.72rem;
  color: var(--vp-c-text-3);
  flex-shrink: 0;
  min-width: 110px;
}

/* 消息 */
.gh-msg {
  flex: 1;
  font-size: 0.88rem;
  color: var(--vp-c-text-1);
  min-width: 200px;
  line-height: 1.4;
}

/* 复制提示 */
.gh-copied {
  font-family: var(--vp-font-family-mono);
  font-size: 0.68rem;
  color: #16a34a;
  flex-shrink: 0;
  animation: fadeout 1.4s ease forwards;
}
@keyframes fadeout {
  0%, 65% { opacity: 1; }
  100% { opacity: 0; }
}

/* 作者 */
.gh-auth {
  font-family: var(--vp-font-family-mono);
  font-size: 0.68rem;
  color: var(--vp-c-text-3);
  flex-shrink: 0;
  opacity: 0.55;
}

/* 响应式 */
@media (max-width: 640px) {
  .gh-row { gap: 8px; padding: 8px 10px; }
  .gh-date { min-width: auto; }
  .gh-msg { min-width: 0; font-size: 0.82rem; }
  .gh-month-head { font-size: 0.8rem; }
}
</style>
