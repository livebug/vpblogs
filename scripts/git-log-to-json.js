// scripts/gitlog.js
import { execSync } from 'child_process'
import { writeFileSync } from 'fs'
import { join } from 'path'
import path from 'path'

const __dirname = path.resolve();

console.log(__dirname);

// 获取 Git 提交记录
const getGitLog = () => {
  const command = [
    'git',
    'log',
    '--pretty=format:"%H~@~%an~@~%ad~@~%s"',
    '--date=iso'
  ].join(' ')

  return execSync(command).toString()
}

const regex = /fix|Merge/;

// 转换日志为 JSON
const parseLog = (log) => {
  return log.split('\n')
    .filter(Boolean)
    .map(line => {
      const [hash, author, date, message] = line.split('~@~') 
      return {
        hash: hash.substring(0, 7),
        author,
        date: new Date(date).toLocaleDateString(),
        message,
        fullDate: date
      }
    })
    .filter(item => !regex.test(item.message))
    // .reverse() // 按时间正序排列
}

// 保存到 docs/.vitepress/commits.json
const saveLog = (data) => {
  const outputPath = join(__dirname, './docs/public/data/commits.json')
  writeFileSync(outputPath, JSON.stringify(data, null, 2))
}

// 主流程
try {
  const log = getGitLog()
  const parsed = parseLog(log)
  saveLog(parsed)
  console.log(`✅ 生成 ${parsed.length} 条提交记录`)
} catch (error) {
  console.error('❌ 生成提交记录失败:', error)
}