---
title: VS Code Git 完全操作手册——ETL 脚本仓库实战
tags:
  - DevEnv
  - Git
  - VSCode
  - ETL
---

# VS Code Git 完全操作手册——ETL 脚本仓库实战

> 本文面向**零基础**读者，无需任何 Git 或 VS Code 经验。所有示例和场景均基于 **ETL SQL 脚本仓库**的实际工作流，从概念到发版，每一步都有流程图和截图说明，跟着操作即可上手。

---

## 一、先搞懂基础概念

### 1.1 什么是版本控制？

假设你在维护一堆 ETL 脚本：

```
数据源A_增量抽取_v1.sql
数据源A_增量抽取_v2_修复日期格式.sql
数据源A_增量抽取_v3_最终版.sql
数据源A_增量抽取_v4_真最终.sql
数据源A_增量抽取_v5_打死不改.sql
```

这就是最原始的"版本控制"——手动备份。而 **Git** 自动记录每次修改历史，你可以随时回到任意版本，还能看到谁在什么时候改了什么。

### 1.2 Git 的三个区域

```mermaid
flowchart LR
    A["📝 工作区<br/>Working Directory<br/>正在编辑的 SQL 文件"] -->|"git add<br/>暂存"| B["📦 暂存区<br/>Staging Area<br/>准备提交的 SQL"]
    B -->|"git commit<br/>提交"| C["📚 本地仓库<br/>Local Repository<br/>永久保存的历史"]
    C -->|"git push<br/>推送"| D["☁️ 远程仓库<br/>Remote Repository<br/>GitLab/GitHub等"]
    D -->|"git pull<br/>拉取"| A
```

> **通俗理解：**
> - **工作区** = 你的书桌，正在写的 SQL 脚本
> - **暂存区** = 购物车，确认要提交的脚本
> - **本地仓库** = 家里的保险柜，永久保存
> - **远程仓库** = 公司服务器，云端备份 + 团队共享

### 1.3 什么是分支（Branch）？

```mermaid
gitGraph
   commit id: "初始：日增脚本"
   branch fb_new_table
   checkout fb_new_table
   commit id: "新增目标表抽取"
   commit id: "加数据质量校验"
   checkout main
   branch fb_fix_date
   checkout fb_fix_date
   commit id: "修复日期格式"
   checkout main
   merge fb_fix_date
   checkout fb_new_table
   commit id: "加异常处理"
   checkout main
   merge fb_new_table
   commit id: "15号 版本发布"
```

分支就像不同的工作台——从 `master` 分出 `fb_new_table` 去开发新表抽取，分出 `fb_fix_date` 去修复日期问题。两边互不影响，开发完再合并。

| 术语 | ETL 仓库中的含义 |
|------|-----------------|
| `master` | 生产环境正在运行的脚本，**只在版本发布日更新** |
| `fb_xxx` | 功能分支，命名如 `fb_new_cust_sync`，从 master 检出 |
| `dev` | 代码审查分支，fb_xxx 通过 PR 合入，用于 Code Review |
| `uat` | UAT 测试分支，由发版人从 dev 部署，测试人员在此验证 |
| `release` | 准生产分支，uat 测试全部通过后合入到这里 |
| `HEAD` | 指针，指向你当前所在的分支/提交 |

---

## 二、VS Code 中的 Git 界面速览

打开 VS Code，左侧活动栏点击 **源代码管理** 图标，快捷键 `Ctrl+Shift+G`。

```
┌─────────────────────────────────────────┐
│  源代码管理 (Ctrl+Shift+G)               │
├─────────────────────────────────────────┤
│  🔍 Message (Ctrl+Enter 提交)            │  ← 写提交信息
├─────────────────────────────────────────┤
│  暂存的更改 (Staged Changes)             │  ← 即将提交的 SQL
│  ├─ M  dwd_order_inc.sql                │
│  └─ A  dws_cust_sum.sql                 │
├─────────────────────────────────────────┤
│  更改 (Changes)                         │  ← 已修改未暂存
│  ├─ M  dim_date.sql                     │
│  └─ U  dwd_new_table.sql                │
├─────────────────────────────────────────┤
│  ⋮  更多操作菜单                         │
│  ↕️  拉取/推送                           │
│  🔀 fb_new_cust  ← 当前分支名            │
└─────────────────────────────────────────┘
```

**文件状态标记：**

| 标记 | 含义 | 示例 |
|------|------|------|
| `M` | 已修改 | 改了 `dim_date.sql` 的过滤条件 |
| `A` | 新添加 | 新建了 `dws_cust_sum.sql` |
| `D` | 已删除 | 删除了废弃的旧脚本 |
| `U` | 未跟踪 | 新文件还没被 Git 管理 |
| `C` | 有冲突 | 两人改了同一个 SQL |

---

## 三、仓库分支模型——本仓库核心流程

> **这是最重要的章节。** 理解分支模型，后面的操作才有意义。

### 3.1 分支全景图

```mermaid
flowchart LR
    %% ═══ 分支节点定义 ═══
    M["🏭 master<br/><i>生产环境</i>"]
    FB["🌿 fb_xxx<br/><i>你的开发分支</i>"]
    D("📋 dev<br/><i>代码审查</i>")
    U("🧪 uat<br/><i>UAT 测试</i>")
    R("🚦 release<br/><i>准生产验证</i>")

    %% ═══ 流转关系 ═══
    M -- "① 从 master 检出" --> FB
    FB -- "② 双人评审 + PR 合并<br/>→ 开发完成" --> D
    FB -. "③ 测试发版人部署 fb→uat" .-> U
    FB -. "④ 测试通过 + 评审批准<br/>fb→release" .-> R
    R -- "⑤ 版本日发版" --> M

    %% ═══ 样式 ═══
    classDef prod fill:#ff444420,stroke:#ff4444,stroke-width:2px,color:#ff6666
    classDef fb   fill:#4fc08d20,stroke:#4fc08d,stroke-width:2px,color:#4fc08d
    classDef dev  fill:#e6a23c20,stroke:#e6a23c,stroke-width:2px,color:#e6a23c
    classDef uat  fill:#409eff20,stroke:#409eff,stroke-width:2px,color:#409eff
    classDef rel  fill:#f56c6c20,stroke:#f56c6c,stroke-width:2px,color:#f56c6c

    class M prod
    class FB fb
    class D dev
    class U uat
    class R rel
```

### 3.2 各分支职责

| 分支 | 用途 | 谁操作 | 更新时机 |
|------|------|--------|----------|
| `master` | 生产运行脚本 | 发版负责人 | **仅在版本日**（15/24/29）|
| `dev` | 代码审查，fb_xxx 通过 PR 合入 | 开发者提 PR | 日常，每个 fb_xxx 完成就合入 |
| `uat` | UAT 测试分支，测试发版人将 fb_xxx 合并到此，测试人员验证 | 测试发版人部署、测试人验证 | 每次测试发版人部署时更新 |
| `release` | 准生产，fb_xxx 测试通过 + 发版评审批准后合入 | 发版负责人 | 版本日前 1-2 天 |
| `fb_xxx` | 你的开发分支 | 你 | 从 master 检出，开发完提交 PR 到 dev |

### 3.3 版本窗口机制

本仓库采用**固定版本窗口**发版，每月有三个生产发版日：

```
┌──────────┬──────────┬──────────┬──────────┐
│  15日    │  24日    │  29日    │  下月15日 │
│  版本窗口1 │  版本窗口2 │  版本窗口3 │  ...     │
└──────────┴──────────┴──────────┴──────────┘
     ↑          ↑          ↑
  生产发版    生产发版    生产发版
```

**关键规则：**

1. **master 在非版本日锁定不动**——生产环境稳定第一
2. 一个版本窗口内，可能有多个 `fb_xxx` 在并行开发
3. 开发完成 = 双人代码评审通过后，提交 PR 将 `fb_xxx` 合并到 `dev`
4. 测试发版人将 `fb_xxx` 合并到 `uat` 分支，测试人员在 `uat` 上验证
5. UAT 测试通过 **且** 发版评审批准后，发版负责人将 `fb_xxx` 合入 `release`（准生产）
6. 生产发版人员在版本日当天，将 `release` → `master`，完成发版，新一轮开发开始

### 3.4 完整开发到发版流程

```mermaid
sequenceDiagram
    actor 你 as 开发者
    actor 评审 as 代码评审人（双人）
    actor 测试发版 as 测试发版人
    actor 测试 as 测试人员
    actor 生产发版 as 生产发版人
    participant Master as master
    participant FB as fb_xxx
    participant Dev as dev
    participant Uat as uat
    participant Rel as release
    participant Prod as 生产(master)

    Note over 你,Prod: === 日常开发（版本窗口内） ===
    你->>Master: 1. 从 master 检出 fb_new_sql
    你->>FB: 2. 写 SQL、本地语法校验
    你->>FB: 3. Push fb_new_sql 到远程
    你->>Dev: 4. 创建 PR: fb_new_sql → dev
    评审->>Dev: 5. 双人代码评审
    Note over Dev: 6. 评审通过，合并 PR 到 dev（开发完成 ✅）

    Note over 你,Prod: === UAT 测试阶段 ===
    测试发版->>Uat: 7. 将 fb_xxx 合并到 uat 分支
    测试->>Uat: 8. 在 uat 分支执行测试用例
    Note over 测试: 9. 验证数据准确性、性能等
    测试-->>测试发版: 10. ✅ 测试通过，提交测试报告

    Note over 你,Prod: === 准生产发版（版本日前1-2天） ===
    测试发版->>测试发版: 11. 发起发版评审
    Note over 测试发版: 12. 评审批准通过
    测试发版->>Rel: 13. fb_xxx 合入 release（准生产）
    Note over Rel: 14. 准生产最终验证

    Note over 你,Prod: === 版本日（15/24/29） ===
    生产发版->>Prod: 15. release → master 生产发版
    Note over Prod: ✅ 发版完成，master 再次锁定
    Note over 你: 🔄 新一轮开发开始，从 master 检出新的 fb_xxx
```

---

## 四、第一步：克隆项目到本地

### 4.1 从 GitLab / GitHub 克隆

```mermaid
flowchart TD
    A["打开 VS Code"] --> B["按 F1 打开命令面板"]
    B --> C["输入 Git: Clone"]
    C --> D["粘贴仓库 URL<br/>如: https://gitlab.com/team/etl-scripts.git"]
    D --> E["选择本地保存文件夹"]
    E --> F["等待克隆完成<br/>全是 .sql 文件"]
    F --> G["VS Code 提示：是否打开？<br/>点击 Open"]
```

**操作步骤：**

1. 按 `F1`（或 `Ctrl+Shift+P`）打开命令面板
2. 输入 `Git: Clone`，选中该命令
3. 粘贴仓库的 HTTPS URL（从 GitLab 仓库页面复制）
4. 选择一个本地文件夹
5. 克隆完成后，点击右下角 **"Open"** 打开项目

---

## 五、日常开发全流程

### 5.1 完整工作流

```mermaid
sequenceDiagram
    participant M as master（远程）
    participant 你
    participant FB as fb_xxx（你的分支）
    participant Dev as dev（远程）

    Note over 你,Dev: 早上来第一件事
    你->>M: 1. git fetch 查看 master 最新状态
    Note over 你: master 若在版本窗口内，无更新
    你->>FB: 2. 从 master 检出 fb_new_cust
    Note over 你: 3. 写 SQL...
    你->>FB: 4. Stage → Commit → Push
    你->>Dev: 5. 创建 PR 到 dev
    评审->>Dev: 6. 双人代码评审
    Note over Dev: 7. 评审通过，合并 PR<br/>开发完成 ✅
```

### 5.2 创建开发分支

**重要：** 始终从 `master` 检出，而不是从 `dev`！确保脚本基线是生产版本。

```mermaid
flowchart LR
    A["确认当前在 master<br/>左下角显示 ⎇ master"] --> B["拉取最新 master<br/>命令面板 → Git: Pull"]
    B --> C["点击左下角分支名"]
    C --> D["选择 '+ 创建新分支...'"]
    D --> E["输入分支名<br/>如: fb_dws_cust_sum"]
    E --> F["✅ 自动切换到新分支"]
```

**分支命名规范：**

| 前缀 | 含义 | 示例 |
|------|------|------|
| `fb_` | 功能开发 | `fb_dws_cust_sum`（客户汇总表）|
| `fb_fix_` | Bug 修复 | `fb_fix_date_format`（修复日期格式）|
| `fb_opt_` | 性能优化 | `fb_opt_query_index`（优化查询索引）|

> 💡 命名用下划线分隔，简洁明了。不要用 `fb_xxx`、`fb_test` 这种无意义的名字。

### 5.3 暂存修改（Stage）

在源代码管理面板的 **"更改"** 区域：

- **暂存单个 SQL 文件：** 鼠标悬停在文件上，点击 `+`
- **暂存全部：** 点击 "更改" 行右侧的 `+`
- **取消暂存：** 在 "暂存的更改" 区域点 `-`

### 5.4 提交（Commit）——写好提交信息

提交信息规范（本仓库专用）：

```
<类型>: <层级> - <简短描述>

<详细说明（可选）>
```

| 类型 | 示例 |
|------|------|
| `feat` | `feat: dws层 - 新增客户月度汇总脚本` |
| `fix` | `fix: dim层 - 修复日期字段格式转换错误` |
| `opt` | `opt: dwd层 - 优化订单表增量抽取性能` |
| `docs` | `docs: 更新数据字典 dws_cust_sum 字段说明` |

**好的示例：**

```
feat: dws层 - 新增客户30日留存统计脚本

- 数据源：dwd_order_inc + dim_cust
- 目标表：dws_cust_retention_30d
- 调度依赖：需在 dwd_order_inc 完成后执行
```

1. 在 Message 输入框填写提交信息
2. 按 `Ctrl+Enter` 提交

### 5.5 推送到远程（Push）

| 方式 | 操作 |
|------|------|
| **底部状态栏** | 点击 `↕️` 同步按钮 |
| **命令面板** | `Ctrl+Shift+P` → `Git: Push` |

> ⚠️ **Push 前确认：** 你推的是 `fb_xxx` 分支，不是 `master`！看左下角分支名确认。

---

## 六、Pull Request——从 fb_xxx 到 dev

### 6.1 PR 流程

```mermaid
sequenceDiagram
    actor 你 as 开发者
    participant GL as GitLab
    actor 同事 as Reviewer

    你->>GL: 1. Push fb_new_cust 到远程
    你->>GL: 2. 创建 PR: fb_new_cust → dev
    Note over 你: 写明：改了哪些 SQL<br/>依赖关系
    GL->>同事: 3. 通知 Review
    同事->>GL: 4. 查看 SQL 变更 (Diff)
    同事->>GL: 5. 评论 / 建议修改
    你->>GL: 6. 修改后再次 Push<br/>（PR 自动更新）
    同事->>GL: 7. ✅ 审查通过
    GL->>GL: 8. 合并到 dev（开发完成 ✅）
    Note over 你: 9. fb_new_cust 分支留存<br/>便于后续复查追溯
    Note over 你: 10. 后续由发版人部署到 uat 测试
```

### 6.2 PR 描述模板

在 GitLab 创建 PR 时，按以下模板填写：

```markdown
## 变更说明
- 新增 dws_cust_sum.sql：客户月度汇总
- 修改 dim_date.sql：增加农历日期字段

## 依赖关系
- 依赖 dwd_order_inc 先执行
- 无上下游影响

## 测试情况
- [x] 本地语法校验通过
- [x] UAT 环境数据量 100w 行测试通过
- [x] UAT 全量数据验证通过

## 上线检查项
- [ ] 目标表已建
- [ ] 调度配置已更新
- [ ] 数据质量监控已添加
```

### 6.3 PR 与本地 Merge 的区别

| 对比维度 | 本地 Merge | Pull Request |
|----------|-----------|--------------|
| **操作位置** | VS Code 本地 | GitLab 网页 |
| **代码审查** | 无 | 同事 Review、行级评论 |
| **合并目标** | 任意分支 | 本仓库固定 `fb_xxx → dev` |
| **CI 触发** | 无 | PR 合入 dev 后，由发版人部署 uat 进行测试 |
| **可追溯** | 仅提交记录 | PR 页面永久保存讨论 |

> 🔑 **核心区别：** 在本仓库，你**永远**不直接在本地 merge 到 `dev`。所有合并都通过 GitLab PR，有人 Review 后才能合。

---

## 七、发版流程——版本窗口机制详解

### 7.1 版本窗口全景

```mermaid
gantt
    title 每月版本窗口与发版节奏
    dateFormat  DD
    axisFormat  %d日
    
    section 版本窗口1
    日常开发 fb_xxx→dev    :a1, 01, 13d
    fb→release 合入        :a2, 13, 2d
    准生产验证             :a3, 14, 1d
    生产发版 release→master :milestone, a4, 15, 1d
    
    section 版本窗口2
    日常开发 fb_xxx→dev    :b1, 16, 7d
    fb→release 合入        :b2, 23, 1d
    准生产验证             :b3, 24, 1d
    生产发版 release→master :milestone, b4, 24, 1d
    
    section 版本窗口3
    日常开发 fb_xxx→dev    :c1, 25, 3d
    fb→release 合入        :c2, 28, 1d
    准生产验证             :c3, 29, 1d
    生产发版 release→master :milestone, c4, 29, 1d
```

### 7.2 发版日操作（由发版负责人执行）

```mermaid
flowchart TD
    A["版本日前1-2天<br/>所有 fb_xxx 已合入 dev<br/>且 UAT 测试已通过"] --> B["发版负责人：<br/>发起发版评审"]
    B --> C{"评审批准？"}
    C -->|"通过"| D["将 fb_xxx 合入 release<br/>准生产环境最终验证"]
    C -->|"驳回"| E["补充材料 / 修复问题<br/>重新提交评审"]
    E --> B
    D --> F{"验证通过？"}
    F -->|"是"| G["版本日当天<br/>release → master"]
    F -->|"否"| H["修复问题 → 重新部署 uat<br/>→ 测试通过 → 评审 → fb→release"]
    H --> B
    G --> I["✅ 生产发版完成<br/>master 再次锁定"]
    I --> J["打 Tag 标记版本号<br/>如: v2026.07.15"]
```

### 7.3 开发者在发版日前后要注意什么

| 时间点 | 你应该做什么 | 不应该做什么 |
|--------|-------------|-------------|
| **版本窗口内（1-12日）** | 开发 fb_xxx，及时提 PR 到 dev | 不要拖到最后一刻 |
| **版本窗口关闭前（13-14日）** | 确保自己的 PR 已合并到 dev | **不要再提新 PR** |
| **版本日（15日）** | 关注发版结果，待命修复 | 不要再 push 到 dev |
| **版本日之后（16日起）** | 从新 master 检出下一个 fb_xxx | 不要从旧 master 检出 |

---

## 八、修改提交信息

### 8.1 修改最近一次提交

**场景：** 提交信息写错了，或漏了一个 SQL 文件。

| 场景 | 操作 |
|------|------|
| **只改提交信息** | 命令面板 → `Git: Commit (Amend)` → 修改信息 → `Ctrl+Enter` |
| **漏了文件** | 先暂存漏掉的 SQL → 再执行 Amend |
| **已 Push 到远程** | Amend 后 `Git: Push (Force)` ⚠️ |

> ⚠️ **Force Push 只在你自己一个人的 fb_xxx 分支上用！** 绝对不要对 `dev`、`uat`、`release`、`master` 用！

---

## 九、回退操作

### 9.1 三种回退对比

```mermaid
flowchart TD
    A["需要回退"] --> B{"改动还要吗？"}
    B -->|"要，只是重新提交"| C["Undo Last Commit<br/>改动回到暂存区"]
    B -->|"要，但要保留历史记录"| D["Revert<br/>创建反向提交"]
    B -->|"不要了，彻底丢弃"| E{"已 Push 到远程？"}
    E -->|"否"| F["Reset Hard<br/>彻底清除"]
    E -->|"是，且是 fb_xxx"| G["Reset + Force Push<br/>⚠️ 你自己的分支可以"]
    E -->|"是，且是 dev/master"| H["只能 Revert<br/>🚫 共享分支禁止 Force Push"]
```

### 9.2 具体操作

**Undo Last Commit：** 命令面板 → `Git: Undo Last Commit`

**Revert（撤销某次提交）：** 命令面板 → `Git: Revert Commit...` → 选择要撤销的提交

**Reset 到某个版本：** 命令面板 → `Git: Reset...` → 选择模式
- `Soft`：保留暂存区和工作区
- `Mixed`：保留工作区（默认）
- `Hard`：全部丢弃 🔴

### 9.3 ETL 特殊场景：发版后发现 SQL 有问题

```mermaid
flowchart TD
    A["🚨 生产脚本有 Bug"] --> B{"影响范围？"}
    B -->|"影响小、可等下次版本"| C["创建 fb_fix_xxx<br/>从 master 检出<br/>走正常版本窗口修复"]
    B -->|"影响大、必须立刻修"| D["紧急修复流程："]
    D --> E["1. 从 master 检出 fb_hotfix_xxx"]
    E --> F["2. 修复 SQL 并提交"]
    F --> G["3. 通知发版负责人"]
    G --> H["4. 走简化审批<br/>直接合入 master 并上线"]
    H --> I["5. 同时 cherry-pick 到 dev<br/>确保 dev 也是最新"]
```

---

## 十、冲突解决——SQL 脚本冲突实战

### 10.1 ETL 仓库冲突的常见场景

```mermaid
flowchart TD
    subgraph "场景1：同一脚本两人改了不同位置"
        A1["张三改了 WHERE 条件"]
        A2["李四加了新字段"]
        A1 --> A3["💥 Git 可能自动合并<br/>也可能冲突"]
    end
    subgraph "场景2：同一脚本同一行都改了"
        B1["张三: WHERE dt = '2026-07-10'"]
        B2["李四: WHERE dt = DATE_SUB(CURRENT_DATE, 1)"]
        B1 --> B3["💥 必定冲突！"]
    end
    subgraph "场景3：fb_xxx 长期未合导致冲突"
        C1["fb_new_table 从 master 检出"]
        C2["半个月后 master 已合并了其他脚本"]
        C3["原来 fb_new_table 引用的脚本已被修改"]
        C1 --> C4["💥 合并到 dev 时大面积冲突"]
    end
```

### 10.2 VS Code 解决冲突实战

当你提 PR 到 dev 或 Pull 最新 dev 时，如果出现冲突：

```
┌──────────────────────────────────────┐
│  合并更改 (Merge Changes)             │
├──────────────────────────────────────┤
│  C  dwd_order_inc.sql                │  ← 冲突文件！
│  M  dim_date.sql                     │  ← 正常修改
│  M  dws_cust_sum.sql                 │  ← 正常修改
└──────────────────────────────────────┘
```

点击冲突文件，VS Code 显示内联对比：

```sql
-- dwd_order_inc.sql 冲突示例
INSERT OVERWRITE TABLE dwd_order_inc
SELECT
    order_id,
<<<<<<< HEAD (dev 分支当前的版本)
    order_amount / 100 AS order_amount_yuan   -- 张三：转成元
=======
    order_amount * 0.01 AS order_amount_yuan  -- 你：乘以0.01
>>>>>>> fb_new_cust (你的分支)
    order_time
FROM ods_order;
```

**解决步骤：**

```mermaid
flowchart TD
    A["点击冲突文件"] --> B["看到冲突标记<br/>&lt;&lt;&lt;&lt;&lt;&lt;&lt; HEAD<br/>=======<br/>&gt;&gt;&gt;&gt;&gt;&gt;&gt; fb_xxx"]
    B --> C{"选哪个？"}
    C -->|"用 dev 的"| D["点击 Accept Current Change"]
    C -->|"用你的"| E["点击 Accept Incoming Change"]
    C -->|"都要，手动整合"| F["点击 Accept Both<br/>手动编辑"]
    D --> G["保存文件 Ctrl+S"]
    E --> G
    F --> G
    G --> H["源代码管理面板<br/>暂存该文件（点 +）"]
    H --> I["填写提交信息<br/>如: fix: 解决 dwd_order_inc 合并冲突"]
    I --> J["Ctrl+Enter 提交"]
    J --> K["Push 到远程"]
    K --> L["✅ PR 自动更新冲突已解决"]
```

### 10.3 减少冲突的最佳实践

| 实践 | 说明 |
|------|------|
| **一个 fb_xxx 只做一件事** | 不要一个分支又改抽取又改建表 |
| **及时合入 dev** | 不要攒半个月才提 PR |
| **每天同步 dev** | 在你的 fb_xxx 上 `git merge dev` 保持同步 |
| **避免改别人的脚本** | 如果有依赖，先去沟通 |
| **SQL 格式化统一** | 团队统一用 VS Code SQL 格式化插件 |

---

## 十一、进阶操作

### 11.1 保持 fb_xxx 与 dev 同步

当你开发周期较长，dev 已经被别人的 PR 更新了。定期同步避免最终合并时大冲突：

```mermaid
flowchart LR
    A["当前在 fb_xxx"] --> B["命令面板<br/>Git: Merge Branch..."]
    B --> C["选择 origin/dev"]
    C --> D{"有冲突？"}
    D -->|"无"| E["✅ 同步完成<br/>你的 fb_xxx 包含了<br/>dev 的最新代码"]
    D -->|"有"| F["解决冲突<br/>（见第十章）"]
    F --> E
```

### 11.2 Stash——暂存写到一半的 SQL

**场景：** SQL 写了一半还没法提交，突然需要切分支。

```mermaid
flowchart LR
    A["写了一半的 SQL<br/>不能提交"] -->|"Stash"| B["代码暂存<br/>工作区干净"]
    B --> C["切到其他分支<br/>处理紧急事情"]
    C --> D["切回来"]
    D -->|"Pop Stash"| E["SQL 恢复回来<br/>继续写"]
```

- **暂存：** 命令面板 → `Git: Stash`
- **恢复：** 命令面板 → `Git: Pop Stash`
- **带未跟踪文件：** `Git: Stash (Include Untracked)`

### 11.3 Cherry Pick——只"摘"某次提交

**场景：** 你在 fb_A 写了一个通用日期函数，fb_B 也需要，但不想合并整个分支。

命令面板 → `Git: Cherry Pick...` → 选择目标提交 → 复制到当前分支

### 11.4 查看 SQL 文件的修改历史

1. 在文件资源管理器中右键 `.sql` 文件
2. 选择 `Open Timeline`
3. 底部显示该文件的所有 Git 提交记录

推荐安装 **GitLens** 插件——鼠标悬停在 SQL 行上直接显示作者和时间。

---

## 十二、常见问题与排查

### Q1: 忘记从 master 检出，从 dev 检出了 fb_xxx 怎么办？

**影响：** 你的分支基线不对，包含了 dev 上其他未上线的脚本。

**解决：**
```bash
# 在 fb_xxx 分支上执行
git rebase --onto master dev fb_xxx
# 将你的提交从 dev 基线移到 master 基线上
```

如果操作困难，**最稳妥：** 删除分支，从 master 重新检出，手动复制 SQL 过来。

### Q2: fb_xxx 基于旧 master，版本日后 master 已更新？

```bash
# 在 fb_xxx 分支上
git fetch origin
git merge origin/master
# 解决可能的冲突
```

或在 VS Code 中：命令面板 → `Git: Merge Branch...` → 选择 `origin/master`

### Q3: PR 被退回要求修改怎么办？

直接在 `fb_xxx` 分支上继续改 → Stage → Commit → Push，PR 自动更新，**无需重新创建**。

### Q4: 想放弃 fb_xxx 上的所有改动，重新开始

```bash
git fetch origin
git checkout master
git branch -D fb_xxx          # 删除本地分支
git checkout -b fb_new_name   # 重新从 master 创建
```

### Q5: Push 被拒绝 "rejected, non-fast-forward"

说明远程分支有你本地没有的新提交。先 `Pull` → 解决冲突 → 再 `Push`。

### Q6: 不小心在 dev 分支上改了文件

1. `Git: Stash` 暂存改动
2. 切换到正确的 `fb_xxx` 分支
3. `Git: Pop Stash` 恢复改动

### Q7: 版本窗口关闭前 PR 还没合入

**黄金规则：不要事后补救，要事前沟通。**
- 如果改动不大，联系 Reviewer 加急
- 如果改动大且来不及，通知发版负责人，移入下个版本窗口
- **永远不要**在版本日前一天催着合入未经充分测试的脚本

### Q8: 多个 fb_xxx 之间有依赖关系怎么办？

```mermaid
flowchart TD
    A["fb_A 新增表 t_cust"] --> B["fb_B 读取 t_cust"]
    B --> C{"B 依赖 A？"}
    C -->|"是"| D["fb_B 基于 fb_A 创建<br/>而不是基于 master"]
    D --> E["fb_A 先合入 dev"]
    E --> F["fb_B 的 PR 注明依赖 fb_A"]
    F --> G["Reviewer 确认 A 已合<br/>再合 B"]
    C -->|"否"| H["各合各的，正常流程"]
```

### Q9: 发版后发现 SQL 有问题，但下一个版本窗口还有 10 天？

参照 **9.3 节紧急修复流程**，从 master 检出 `fb_hotfix_xxx`，走简化审批快速上线。

### Q10: dev 上有未通过测试的脚本被误合入，影响其他人的测试？

```mermaid
flowchart TD
    A["Dev 有问题的提交"] --> B["找到问题提交的 SHA"]
    B --> C["Git: Revert Commit..."]
    C --> D["选择有问题的提交"]
    D --> E["创建 Revert 提交并 Push"]
    E --> F["通知团队 dev 已修复"]
```

---

## 十三、命令速查表

| 操作 | VS Code 操作 | 命令面板关键词 |
|------|-------------|---------------|
| 克隆仓库 | `F1` 打开面板 | `Git: Clone` |
| 从 master 创建 fb_xxx | 左下角分支名 → 新分支 | `Git: Create Branch` |
| 暂存文件 | 点击文件旁的 `+` | - |
| 提交 | `Ctrl+Enter` | - |
| 推送 | 底部状态栏 `↕️` | `Git: Push` |
| 拉取 | 底部状态栏 `↕️` | `Git: Pull` |
| 同步 dev | - | `Git: Merge Branch...` |
| 撤销最近提交 | - | `Git: Undo Last Commit` |
| 撤销某次提交 | - | `Git: Revert Commit...` |
| 回退到某版本 | - | `Git: Reset...` |
| 暂存当前工作 | - | `Git: Stash` |
| 恢复暂存 | - | `Git: Pop Stash` |
| 摘取提交 | - | `Git: Cherry Pick...` |
| 删除分支 | - | `Git: Delete Branch...` |
| 查看历史 | 安装 GitLens | `Git: View Git Graph` |

---

## 十四、总结

### 14.1 每日核心口诀

> **Master 检出 → fb_xxx 开发 → Push → 双人评审 → PR 合入 dev（开发完成）→ 测试发版人 fb→uat → 测试验证 → 发版评审批准 → fb_xxx 合入 release → 生产发版 release→master → 新一轮开发**

### 14.2 整体流程图

```mermaid
flowchart TD
    subgraph "日常开发（版本窗口内）"
        A["从 master 检出 fb_xxx"] --> B["写 SQL、本地测试"]
        B --> C["Stage → Commit → Push"]
        C --> D["GitLab 创建 PR → dev"]
        D --> E["双人代码评审"]
        E --> F{"通过？"}
        F -->|"否"| B
        F -->|"是"| G["合入 dev ✅ 开发完成"]
    end
    
    subgraph "UAT 测试阶段"
        G --> H["测试发版人 fb→uat"]
        H --> I["测试人员验证"]
        I --> J{"测试通过？"}
        J -->|"否"| K["修复 → 重新部署"]
        K --> H
    end
    
    subgraph "准生产发版（版本日前1-2天）"
        J -->|"是"| L["发起发版评审"]
        L --> M{"评审批准？"}
        M -->|"驳回"| K
        M -->|"通过"| N["fb_xxx 合入 release（准生产）"]
        N --> O["准生产最终验证"]
    end
    
    subgraph "版本日（15/24/29）"
        O --> P["release → master"]
        P --> Q["🎉 生产发版完成"]
        Q --> R["打 Tag 标记版本"]
        R --> A
    end
```

### 14.3 一句话记住各分支

| 分支 | 一句话 |
|------|--------|
| **master** | 生产的镜子，非版本日碰都别碰 |
| **fb_xxx** | 你的工作台，从 master 来，PR 合入 dev 即开发完成 |
| **dev** | 代码审查站，PR 合入即开发完成，不参与后续部署 |
| **uat** | 测试练兵场，发版人将 fb_xxx 部署到 uat，测试人验证 |
| **release** | 发版前的最后一道安检 |

### 14.4 最核心的几条铁律

1. **永远从 master 检出**，不是 dev
2. **永远通过 PR 合入 dev**，不在本地直接 merge
3. **不要在版本窗口关闭前抢合**未测试的脚本
4. **每天同步 dev**到你的 fb_xxx，减少最终冲突
5. **一个 fb_xxx 只做一件事**，方便 Review 和回退
6. **生产出问题走紧急修复流程**，不要在 master 上直接改
7. **Push 前看清分支名**，绝不误推到 master/dev/uat/release
