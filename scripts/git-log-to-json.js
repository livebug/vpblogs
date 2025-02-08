// scripts/gitlog.js
const { execSync } = require('child_process')
const fs = require('fs')
const path = require('path')

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
    .reverse() // 按时间正序排列
}

// 保存到 docs/.vitepress/commits.json
const saveLog = (data) => {
  const outputPath = path.join(__dirname, '../docs/public/data/commits.json')
  fs.writeFileSync(outputPath, JSON.stringify(data, null, 2))
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