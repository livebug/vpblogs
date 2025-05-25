---
title: 第二课 Tasks 使用
tags:
  - vscode
  - vscode-extension
---
# 第二课 Tasks 使用

## 1. 出发点
有许多工具可以自动执行 linting、构建、打包、测试或部署软件系统等任务。示例包括 [TypeScript 编译器](https://www.typescriptlang.org/) 、[ESLint](https://eslint.org/) 和 [TSLint](https://palantir.github.io/tslint/) 等 linter 以及 [Make](https://en.wikipedia.org/wiki/Make_software)、[Ant、](https://ant.apache.org/)[Gulp](https://gulpjs.com/)、[Jake](https://jakejs.com/)、[Rake](https://ruby.github.io/rake/) 和 [MSBuild](https://github.com/microsoft/msbuild) 等构建系统。
这些工具主要从命令行运行，并在内部软件开发循环内部和外部自动执行作业（编辑、编译、测试和调试）。
**鉴于它们在开发生命周期中的重要性，能够在 VS Code 中运行工具并分析其结果是很有帮助的。**
==VS Code 中的任务可以配置为运行脚本和启动进程，以便可以从 VS Code 中使用其中许多现有工具，而无需输入命令行或编写新代码。==
特定于工作区或文件夹的任务是从工作区的 `.vscode` 文件夹中的 `tasks.json` 文件配置的。

>**注意：** 任务支持仅在处理工作区文件夹时可用。编辑单个文件时，它不可用。

---

很多插件都自带了很多tasks，可以支持用来调用，常见的就是测试和运行，使用办法就是调用就行
主要说的内容时自定义任务

---


## 2. 自定义任务

### 2.1 先来看看tasks.json 什么样

`tasks.json` 会在 `工作目录/.vscode/` 目录下

```json
{
  // See https://go.microsoft.com/fwlink/?LinkId=733558
  // for the documentation about the tasks.json format
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run tests",
      "type": "shell",
      "command": "./scripts/test.sh",
      "windows": {
        "command": ".\\scripts\\test.cmd"
      },
      "group": "test",
      "presentation": {
        "reveal": "always",
        "panel": "new"
      }
    }
  ]
} 
```

任务的属性具有以下语义：（部分可能不在上面的示例中，下面示例说明）

| 属性                  | 描述                                                        | 补充                                                                                                                        |
| ------------------- | --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **label**           | 用户界面中使用的任务标签。                                             |                                                                                                                           |
| **type**            | 任务的类型。                                                    | 对于自定义任务，这可以是 `shell` 或 `process`。如果指定了 `shell`，则该命令将解释为 shell 命令（例如：bash、cmd 或 PowerShell）。如果指定了 `process`，则命令将解释为要执行的进程。 |
| **command**         | 要执行的实际命令。                                                 |                                                                                                                           |
| **windows**         | 任何特定于 Windows 的属性。                                        | 在 Windows 作系统上执行命令时，将 代替默认属性。                                                                                             |
| **group**           | 定义任务所属的组。                                                 | 在此示例中，它属于 `test` 组。属于测试组的任务可以通过从 **Command Palette** 运行 **Run Test Task** 来执行。                                            |
| **presentation**    | 定义如何在用户界面中处理任务输出。                                         | 显示输出的集成终端``always``显示，并且每次任务运行时`都会创建一个新终端` 。                                                                              |
| presentation.reveal |                                                           | 控制运行任务的终端是否显示。默认设置为“always”。<br>`never`: 不要在此任务执行时显示终端。                                                                   |
| presentation.panel  |                                                           | 控制是否在任务间共享面板。同一个任务使用相同面板还是每次运行时新创建一个面板。                                                                                   |
| **options**         | 覆盖 `cwd` （当前工作目录）、`env` （环境变量） 或 `shell` （默认 shell） 的默认值。 | 选项可以按任务设置，也可以全局设置或按平台设置。此处配置的环境变量只能从任务脚本或进程中引用，如果它们是 args、command 或其他任务属性的一部分，则不会解析。                                      |
| **runOptions**      | 定义任务的运行时间和方式。                                             |                                                                                                                           |
| **hide**            | 从 Run Task Quick Pick 中隐藏任务，这对于复合任务中不可独立运行的元素非常有用。        |                                                                                                                           |
| **args**            | 参数数组                                                      | "args": ["folder with spaces"]                                                                                            |

### 2.2 准备自定义的脚本

该脚本存储在工作区内的脚本文件夹中，对于 Linux 和 macOS 名为 `test.sh`，对于 Windows，名为 `test.cmd`。

windows 下也可以用 powershell 的脚本，但是需要在配置时指定，后续再说

---

准备完脚本，即可配置一个task：
从全局**终端**菜单运行 **Configure Tasks** 并选择 **Create tasks.json file from template** 条目。这将打开以下选取器：
![](../../public/images/Pasted%20image%2020250503220120.png)
如果您没有看到任务运行程序模板列表，则您的文件夹中可能已经有一个 `tasks.json` 文件，其内容将在编辑器中打开。关闭文件，然后删除或重命名它。
