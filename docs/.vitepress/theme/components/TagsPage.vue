<template>
  <div class="tp-root">

    <!-- 搜索 & 统计 -->
    <div class="tp-bar">
      <span class="tp-count">{{ postsData.length }} 篇文章</span>
      <span class="tp-count-div">·</span>
      <span class="tp-count">{{ tagMap.size }} 个标签</span>
      <span v-if="selectedTag" class="tp-active-tag">
        ← {{ selectedTag }}
        <button class="tp-clear" @click="clearTag" title="清除筛选">✕</button>
      </span>
    </div>

    <!-- 标签云 -->
    <div class="tp-cloud">
      <span
        v-for="[tag, count] in tagMap"
        :key="tag"
        class="tp-chip"
        :class="{ active: selectedTag === tag }"
        @click="filterByTag(tag)"
      >
        {{ tag }}
        <sup>{{ count }}</sup>
      </span>
    </div>

    <!-- 文章列表 -->
    <div class="tp-list">
      <a
        v-for="post in filteredPosts"
        :key="post.url"
        :href="post.url"
        class="tp-card"
      >
        <span class="tp-card-dir">{{ post.dir.split(' / ')[0] }}</span>
        <span class="tp-card-title">{{ post.title }}</span>
        <span class="tp-card-tags">
          <span v-for="t in normalizedTags(post)" :key="t" class="tp-card-tag">{{ t }}</span>
        </span>
      </a>
      <div v-if="!filteredPosts.length" class="tp-empty">
        没有找到包含「{{ selectedTag }}」标签的文章
      </div>
    </div>

  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { data as postsData } from '../../post.data'

const selectedTag = ref(null)

onMounted(() => {
  const q = new URLSearchParams(window.location.search).get('tag')
  if (q) selectedTag.value = normalize(q)
})

// ---- 标签归并：大小写变体、同义词统一为规范名 ----
const TAG_ALIAS = {
  'docker': 'Docker', 'dockerfile': 'Docker',
  'git': 'Git', 'github': 'GitHub', 'gitee': 'GitHub', 'github actions': 'GitHub',
  'vscode': 'VSCode', 'vscode-extension': 'VSCode', 'vscodeex': 'VSCode',
  'linux': 'Linux', 'debian': 'Linux', 'fedora': 'Linux',
  'wsl': 'WSL2', 'wsl2': 'WSL2',
  'nodejs': 'Node.js', 'npm': 'Node.js', 'pnpm': 'Node.js', 'nvm': 'Node.js',
  'go': 'Go', 'golang': 'Go',
  'python': 'Python', 'pypi': 'Python',
  'c#': '.NET', 'asp.net': '.NET', 'asp.net core': '.NET', 'backend': '.NET', 'openiddict': '.NET',
  'vue3': 'Vue', 'frontend': 'Vue', 'css': 'Vue', 'mockjs': 'Vue',
  'proxy': 'Proxy', 'network': 'Proxy', 'clash': 'Proxy',
  'ssh': 'DevEnv', 'devenv': 'DevEnv', 'environment': 'DevEnv', 'setup': 'DevEnv',
  'java': 'BigData', 'hive': 'BigData', 'gauss': 'BigData', 'sql': 'BigData',
  'powershell': 'Windows', 'system': 'Windows',
  'vitepress': 'VitePress', 'hugo': 'VitePress', 'markdown': 'VitePress',
  'antlr4': 'Antlr4',
  'programming': '编程基础', 'regex': '编程基础',
  'timeline': '站点', 'changelog': '站点', 'tags': '站点',
  'vcs': '站点',
  'infrastructure': '站点',
  'samba': 'Linux',
  'tdh': 'BigData',
  'etl': 'BigData',
  'verdaccio': 'Docker',
  'obsidian': 'DevEnv',
  'code-server': 'DevEnv',
  '博客': '站点', '标签': '站点', 'demo': '站点', 'example': '站点',
  '网络': 'Proxy',
  '问题排查': 'DevEnv',
}

function normalize(tag) {
  const t = tag.trim().toLowerCase()
  return TAG_ALIAS[t] || tag.trim()
}

// 标签 → 文章数映射
const tagMap = computed(() => {
  const map = new Map()
  for (const post of postsData) {
    const seen = new Set()
    for (const rawTag of (post.tags || [])) {
      const canon = normalize(rawTag)
      if (!canon || seen.has(canon)) continue
      seen.add(canon)
      map.set(canon, (map.get(canon) || 0) + 1)
    }
  }
  return new Map([...map.entries()].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0])))
})

const filteredPosts = computed(() => {
  if (!selectedTag.value) return postsData
  return postsData.filter(p =>
    (p.tags || []).some(t => normalize(t) === selectedTag.value)
  )
})

function filterByTag(tag) {
  selectedTag.value = selectedTag.value === tag ? null : tag
}

function clearTag() {
  selectedTag.value = null
}

function normalizedTags(post) {
  const seen = new Set()
  return (post.tags || [])
    .map(t => normalize(t))
    .filter(t => t && !seen.has(t) && seen.add(t))
}
</script>

<style scoped>
.tp-root {
  max-width: 100%;
}

/* ---- 顶栏 ---- */
.tp-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 20px;
  font-family: var(--vp-font-family-mono);
  font-size: 0.8rem;
  color: var(--vp-c-text-3);
  flex-wrap: wrap;
}
.tp-count-div {
  opacity: 0.3;
}
.tp-active-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  margin-left: auto;
  padding: 3px 12px;
  border-radius: 14px;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
  font-weight: 600;
  font-size: 0.78rem;
}
.tp-clear {
  border: none;
  background: none;
  color: var(--vp-c-brand);
  cursor: pointer;
  font-size: 0.85rem;
  padding: 0;
  line-height: 1;
  opacity: 0.7;
  transition: opacity 0.15s;
}
.tp-clear:hover { opacity: 1; }

/* ---- 标签云 ---- */
.tp-cloud {
  display: flex;
  flex-wrap: wrap;
  gap: 7px;
  margin-bottom: 28px;
}
.tp-chip {
  display: inline-flex;
  align-items: center;
  gap: 3px;
  padding: 4px 12px;
  border-radius: 6px;
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  cursor: pointer;
  user-select: none;
  transition: all 0.2s;
}
.tp-chip sup {
  font-size: 0.65rem;
  color: var(--vp-c-text-3);
  font-weight: 400;
  top: 0;
}
.tp-chip:hover {
  color: var(--vp-c-brand);
  border-color: var(--vp-c-brand);
  background: rgba(var(--vp-c-brand-rgb), 0.04);
}
.tp-chip.active {
  background: var(--vp-c-brand);
  color: #fff;
  border-color: var(--vp-c-brand);
}
.tp-chip.active sup {
  color: rgba(255, 255, 255, 0.7);
}

/* ---- 列表 ---- */
.tp-list {
  display: flex;
  flex-direction: column;
}
.tp-card {
  display: flex;
  align-items: baseline;
  gap: 14px;
  padding: 10px 14px;
  border-radius: 8px;
  text-decoration: none;
  transition: background 0.18s;
  flex-wrap: wrap;
}
.tp-card:hover {
  background: var(--vp-c-bg-soft);
}
.tp-card-dir {
  font-family: var(--vp-font-family-mono);
  font-size: 0.68rem;
  color: var(--vp-c-text-3);
  flex-shrink: 0;
  min-width: 56px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.tp-card-title {
  font-size: 0.92rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
  flex: 1;
  min-width: 160px;
  line-height: 1.4;
}
.tp-card-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
  flex-shrink: 0;
}
.tp-card-tag {
  font-family: var(--vp-font-family-mono);
  font-size: 0.64rem;
  color: var(--vp-c-text-3);
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 4px;
  padding: 1px 6px;
  transition: all 0.15s;
}
.tp-card:hover .tp-card-tag {
  border-color: var(--vp-c-divider);
}

/* ---- 空状态 ---- */
.tp-empty {
  padding: 40px 20px;
  text-align: center;
  color: var(--vp-c-text-3);
  font-size: 0.9rem;
}

/* ---- 响应式 ---- */
@media (max-width: 640px) {
  .tp-card { gap: 8px; padding: 8px 10px; }
  .tp-card-tags { width: 100%; margin-top: 2px; }
  .tp-active-tag { margin-left: 0; }
}
</style>
