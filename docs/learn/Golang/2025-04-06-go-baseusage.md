---
title: go 基础使用
tags:
  - go
---
# go 基础使用

## 1. 链接数据库
```go
package excample

// 链接pgsql

import (
	"context"
	"fmt"
	"os"

	"github.com/jackc/pgx/v5"
)

// TestPgsqlConnet 演示如何使用 pgx 库连接到 PostgreSQL 数据库，
// 执行查询以从 pg_stat_activity 视图中检索信息，并处理结果。
//
// 此函数执行以下步骤：
//  1. 使用连接 URL 建立到 PostgreSQL 数据库的连接。
//  2. 执行查询以从 pg_stat_activity 视图中检索活动查询的进程 ID (pid)、查询文本和状态，
//     排除空闲查询。
//  3. 遍历结果集并打印检索到的信息。
//
// 注意：
// - 确保在项目中正确导入并配置 pgx 库。
// - 根据您的环境替换连接 URL 中的凭据和数据库详细信息。
// - 安全地处理数据库凭据等敏感信息。
// - 如果任何步骤失败，函数将打印错误信息并退出程序。
func TestPgsqlConnet() {
	urlExample := "postgres://postgres:postgres@10.31.2.54:5432/postgres"
	conn, err := pgx.Connect(context.Background(), urlExample)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to connect to database: %v\n", err)
		os.Exit(1)
	}
	defer conn.Close(context.Background()) // 关闭连接

	var pid int64
	var query string
	var state string
	querySql := "SELECT pid, query, $1 state FROM pg_stat_activity WHERE query <> '<IDLE>' ;"
	rows, err := conn.Query(context.Background(), querySql, "idle")
	if err != nil {
		fmt.Fprintf(os.Stderr, "QueryRow failed: %v\n", err)
		os.Exit(1)
	}
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(&pid, &query, &state)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Scan failed: %v\n", err)
			os.Exit(1)
		}
		fmt.Printf("pid: %d, query: %s, state: %s\n", pid, query, state)
	}
}
```

其他常用的函数：

- 执行增删改 Exec
- 单行查询 QueryRow

事务处理：

```go
func InsertUsersInTransaction(conn *pgx.Conn, users []User) error {
    tx, err := conn.Begin(context.Background())
    if err != nil {
        return err
    }

    for _, user := range users {
        _, err := tx.Exec(context.Background(), "INSERT INTO users (id, name) VALUES (1,2)", user.ID, user.Name)
        if err != nil {
            tx.Rollback(context.Background())
            return err
        }
    }

    err = tx.Commit(context.Background())
    if err != nil {
        return err
    }

    return nil
}
```

## 其他提问

### 1. go 模块，函数如何让其他包调用

​**​首字母大写​**​的函数或变量才能被其他包访问（称为"导出"）。
使用`import`关键字导入目标包，路径需与`go.mod`中的模块名匹配。

### 2. 在Go语言中，​**​package（包）​**​和​**​module（模块）​**​是两个核心概念，主要区别如下：

- **Package（包）**  
  - 是代码组织和复用的基本单位，由同一目录下的`.go`文件组成，共享相同的包名。  
  - 通过首字母大小写控制标识符（变量、函数等）的可见性（如`Add`可导出，`add`仅包内可用）。  
  - 示例：`package utils`定义了一个工具包，其他包可通过`import "your-module/utils"`调用其导出函数。

- **Module（模块）**  
  - 是依赖管理和版本控制的单元，包含一个或多个相关包，由`go.mod`文件定义。  
  - 记录项目依赖及其版本（如`require github.com/gin-gonic/gin v1.7.0`），确保构建一致性。  
  - 示例：`module github.com/user/project`声明模块路径，其下可包含多个子包。

### 3. go 多行字符串 

使用反引号（`）定义原生多行字符串（推荐）
```go
str := `第一行
第二行
第三行`
```
**特点**：
• 保留所有换行和空格（原样输出）
• 不支持转义字符（如`\n`会直接显示为字符）
• 适合嵌入SQL、HTML模板等场景

| 方法             | 保留格式 | 支持转义 | 适用场景            |
| -------------- | ---- | ---- | --------------- |
| 反引号            | ✔️   | ❌    | 静态文本（SQL/HTML等） |
| 双引号+`\n`       | ❌    | ✔️   | 需要转义字符的场景       |
| `strings.Join` | ❌    | ✔️   | 动态生成多行内容        |
### 4. `defer` 的作用

`defer` 是Go语言的关键字，用于延迟执行一个函数调用，直到包含它的函数返回（无论正常返回还是异常退出）。

- ​**​资源管理​**​：常用于文件、数据库连接、锁等资源的释放，避免泄漏。
- ​**​执行顺序​**​：多个`defer`按后进先出（LIFO）顺序执行。