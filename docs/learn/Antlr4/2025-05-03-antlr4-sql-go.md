---
title: go-antlr4-sql sql 语句分析
tags:
  - Antlr4
  - Go
---

# 使用 Antlr4 + Go 实现 SQL 语句分析

> 通过 Antlr4 解析 SQL 语法树，用 Go 实现 SQL 血缘分析、表依赖提取等能力。

## 为什么用 Go + Antlr4 做 SQL 分析

在大数据开发中，经常需要分析 ETL 脚本中的 SQL 语句——提取表依赖关系、字段血缘、SQL 改写等。Antlr4 是工业级的语法解析器生成器，配合 Go 的高并发特性，非常适合构建 SQL 分析工具。

**与 Java 方案的对比：**

| 维度 | Go | Java |
|:---|:---|:---|
| 内存占用 | 低（编译为原生二进制） | 高（JVM 开销） |
| 部署难度 | 单文件部署 | 需要 JDK 环境 |
| 并发模型 | goroutine 轻量级 | 线程池较重量 |
| Antlr4 运行时 | `antlr4-go` | `antlr4-runtime` |

## 环境准备

### 1. 安装 Antlr4 工具

```bash
# 安装 Java（Antlr4 工具需要）
sudo apt install default-jre -y

# 下载 antlr4 工具 jar
curl -O https://www.antlr.org/download/antlr-4.13.1-complete.jar
alias antlr4='java -Xmx500M -cp "$PWD/antlr-4.13.1-complete.jar" org.antlr.v4.Tool'
alias grun='java -Xmx500M -cp "$PWD/antlr-4.13.1-complete.jar" org.antlr.v4.gui.TestRig'
```

### 2. 获取 SQL 语法文件

推荐使用社区维护的 [antlr/grammars-v4](https://github.com/antlr/grammars-v4) 中的 SQL 语法：

```bash
# 以 MySQL 为例
wget https://raw.githubusercontent.com/antlr/grammars-v4/master/sql/mysql/Positive-Technologies/MySqlLexer.g4
wget https://raw.githubusercontent.com/antlr/grammars-v4/master/sql/mysql/Positive-Technologies/MySqlParser.g4
```

如果你需要解析 Hive SQL 或 GaussDB SQL，可以选择对应的语法文件。

### 3. 生成 Go 代码

```bash
antlr4 -Dlanguage=Go -o parser MySqlLexer.g4 MySqlParser.g4
```

## Go 代码示例

### 基础使用：解析 SQL 并提取表名

```go
package main

import (
	"fmt"
	"strings"

	"github.com/antlr4-go/antlr/v4"
	"your-project/parser"
)

// SQLTableListener 监听器：遍历语法树提取表名
type SQLTableListener struct {
	*parser.BaseMySqlParserListener
	TableNames []string
}

func (l *SQLTableListener) EnterTableName(ctx *parser.TableNameContext) {
	l.TableNames = append(l.TableNames, ctx.GetText())
}

func ExtractTableNames(sql string) ([]string, error) {
	// 创建词法分析器
	input := antlr.NewInputStream(sql)
	lexer := parser.NewMySqlLexer(input)
	stream := antlr.NewCommonTokenStream(lexer, antlr.TokenDefaultChannel)

	// 创建语法分析器
	p := parser.NewMySqlParser(stream)
	p.RemoveErrorListeners()
	
	// 自定义错误收集
	errListener := &ErrorListener{}
	p.AddErrorListener(errListener)

	// 遍历语法树
	tree := p.Root()
	listener := &SQLTableListener{}
	antlr.ParseTreeWalkerDefault.Walk(listener, tree)

	return listener.TableNames, nil
}

// ErrorListener 自定义错误监听
type ErrorListener struct {
	*antlr.DefaultErrorListener
	Errors []string
}

func (e *ErrorListener) SyntaxError(_ antlr.Recognizer, _ interface{}, line, column int, msg string, _ antlr.RecognitionException) {
	e.Errors = append(e.Errors, fmt.Sprintf("line %d:%d %s", line, column, msg))
}

func main() {
	sql := `SELECT a.name, b.amount 
FROM users a 
JOIN orders b ON a.id = b.user_id 
WHERE b.status = 'active'`

	tables, _ := ExtractTableNames(sql)
	fmt.Printf("涉及的源表: %s\n", strings.Join(tables, ", "))
	// 输出: 涉及的源表: users, orders
}
```

### 进阶：SQL 血缘分析

```go
type SQLLineageListener struct {
	*parser.BaseMySqlParserListener
	Lineage map[string][]string // 表 → 使用的字段
}

func (l *SQLLineageListener) EnterSelectElement(ctx *parser.SelectElementContext) {
	// 记录 SELECT 中的字段引用
	field := ctx.GetChild(0).GetText()
	// ... 解析逻辑
	_ = field
}

func (l *SQLLineageListener) EnterTableSource(ctx *parser.TableSourceContext) {
	// 记录 FROM / JOIN 中的表
	tableName := ctx.GetText()
	if _, ok := l.Lineage[tableName]; !ok {
		l.Lineage[tableName] = []string{}
	}
}
```

### 实际应用场景

1. **ETL 脚本解析**：自动提取脚本中读写的表，生成数据流图
2. **SQL 改写**：将供应商特定的 SQL 转移到标准 SQL 或目标数据库方言
3. **安全审计**：检查 SQL 中是否包含敏感表或危险操作
4. **数据治理**：构建字段级血缘关系，追踪数据流向

## 常见问题

### 1. go mod 依赖

```bash
go get github.com/antlr4-go/antlr/v4@latest
```

### 2. 解析 Hive SQL

Hive SQL 支持 `INSERT OVERWRITE`、`LATERAL VIEW` 等特有语法，需要使用对应的 Hive 语法文件：

```bash
wget https://raw.githubusercontent.com/antlr/grammars-v4/master/sql/hive/HiveLexer.g4
wget https://raw.githubusercontent.com/antlr/grammars-v4/master/sql/hive/HiveParser.g4
antlr4 -Dlanguage=Go -o parser HiveLexer.g4 HiveParser.g4
```

## 小结

Go + Antlr4 的组合非常适合构建轻量级 SQL 分析工具。核心思路是：获取语法文件 → 生成 Go 代码 → 实现 Listener/Visitor → 提取所需信息。由于 Go 生成的二进制文件可直接分发，特别适合在 CI/CD 流程或离线环境中使用。

