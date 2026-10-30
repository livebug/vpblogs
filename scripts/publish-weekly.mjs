#!/usr/bin/env node
/**
 * 将《金融监管信息周报》一期发布到博客。
 *
 * 用法：
 *   node scripts/publish-weekly.mjs --src ../自动任务-金融监管信息周报/2026-10-26 \
 *     --week 43 --period "2026-10-19 — 2026-10-25" \
 *     --title "第43周：AI 治理升级与报送严监管" \
 *     --summary "金融街论坛定调 AI 治理；EAST 报送处罚独立化；一表通 2.1 映射发布"
 *
 * 行为：
 *   1. 读取 --src/report.md，注入 frontmatter 后写入 docs/regwatch/weekly/<日期>.md
 *   2. 复制 --src/*.svg 到同目录（Markdown 相对图片路径可直接引用）
 *   3. 在 docs/regwatch/index.md 的期次表格中插入/更新一行
 *   幂等：同一日期重复执行会覆盖旧文件与旧表格行。
 */
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const ROOT = path.resolve(__dirname, '..')
const WEEKLY_DIR = path.join(ROOT, 'docs/regwatch/weekly')
const INDEX_FILE = path.join(ROOT, 'docs/regwatch/index.md')

function parseArgs(argv) {
  const out = {}
  for (let i = 2; i < argv.length; i += 2) {
    const k = argv[i].replace(/^--/, '')
    out[k] = argv[i + 1]
  }
  return out
}

function pad(n) {
  return String(n).padStart(2, '0')
}

function today() {
  const d = new Date()
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
}

const args = parseArgs(process.argv)
const src = args.src && path.resolve(args.src)
if (!src || !fs.existsSync(path.join(src, 'report.md'))) {
  console.error('用法: node scripts/publish-weekly.mjs --src <报告目录> --week <周数> --period <期间> --title <标题> --summary <看点>')
  process.exit(1)
}

const date = path.basename(src.replace(/\/+$/, ''))
if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
  console.error(`目录名需为 YYYY-MM-DD，当前为: ${date}`)
  process.exit(1)
}

const year = date.slice(0, 4)
const week = args.week || ''
const period = args.period || ''
const title = args.title || `第${week}周金融监管信息周报`
const summary = args.summary || ''
const created = args.created || date
const updated = today()

let md = fs.readFileSync(path.join(src, 'report.md'), 'utf8')

// 去掉已有 frontmatter（若被重复处理）
md = md.replace(/^---\n[\s\S]*?\n---\n/, '')

// 博客版措辞：不暴露本地生成脚本路径
md = md.replace(
  '> 图表由 `tools/make_chart.py` 生成（零依赖 SVG，数据来自本期正文表格）。',
  '> 图表为本报告自制矢量图，数据与正文表格一致。'
)

const fm = [
  '---',
  `title: ${JSON.stringify(title)}`,
  `created: ${created}`,
  `updated: ${updated}`,
  `week: ${week}`,
  `period: ${JSON.stringify(period)}`,
  `summary: ${JSON.stringify(summary)}`,
  'tags:',
  '  - 金融监管',
  '  - 监管动态',
  '  - 监管报送',
  '---',
  '',
].join('\n')

// 死链检查：报告里的相对链接/图片必须存在于 weekly 目录，否则 CI 会构建失败
const broken = []
for (const [, href] of md.matchAll(/!?\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g)) {
  if (/^(https?:)?\/\//.test(href) || href.startsWith('/') || href.startsWith('#') || href.startsWith('mailto:')) continue
  const clean = decodeURIComponent(href.split('#')[0].split('?')[0])
  if (!clean) continue
  if (!fs.existsSync(path.join(WEEKLY_DIR, clean))) broken.push(href)
}
if (broken.length) {
  console.error(`❌ 发现 ${broken.length} 个死链（会导致 VitePress 构建失败）：`)
  for (const b of broken) console.error(`   - ${b}`)
  console.error('   请先修正报告里的相对链接，或先发布被引用的文章。')
  process.exit(1)
}

fs.mkdirSync(WEEKLY_DIR, { recursive: true })

// 复制图表
const charts = fs.readdirSync(src).filter((f) => f.endsWith('.svg'))
for (const c of charts) {
  fs.copyFileSync(path.join(src, c), path.join(WEEKLY_DIR, c))
}

const dest = path.join(WEEKLY_DIR, `${date}.md`)
fs.writeFileSync(dest, fm + md, 'utf8')

// 更新索引表格
const displayWeek = week ? `${year} 第 ${week} 周` : `${year} ${date}`
const row = `| ${displayWeek} | ${period || date} | ${summary} | [阅读](/regwatch/weekly/${date}) |`

let idx = fs.existsSync(INDEX_FILE)
  ? fs.readFileSync(INDEX_FILE, 'utf8')
  : ['---', 'title: 金融监管周报', '---', '', '# 金融监管周报', '',
     '## 期次索引', '',
     '| 期次 | 覆盖期间 | 主要看点 | 文章 |',
     '|---|---|---|---|', ''].join('\n')

const lines = idx.split('\n')
const hit = lines.findIndex((l) => l.startsWith(`| ${displayWeek} |`))
if (hit >= 0) {
  lines[hit] = row
} else {
  // 找到表头分隔行后插入（新期次置顶）
  const sep = lines.findIndex((l) => /^\|\s*-{3,}/.test(l.replace(/\s/g, '')) || l.startsWith('|---|'))
  if (sep >= 0) lines.splice(sep + 1, 0, row)
  else lines.push(row)
}
idx = lines.join('\n')
if (!idx.endsWith('\n')) idx += '\n'
fs.writeFileSync(INDEX_FILE, idx, 'utf8')

console.log(`✅ 已发布: docs/regwatch/weekly/${date}.md`)
console.log(`   图表: ${charts.length} 个${charts.length ? '（' + charts.join(', ') + '）' : ''}`)
console.log(`   索引: docs/regwatch/index.md`)
