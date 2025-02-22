---
title: Antlr4 python 使用
tags:
  - antlr4
  - python
date: 2023-09-26T00:15:06+08:00
---
# Antlr4 python 使用学习
## 安装及基本说明
官方网站：[ANTLR](https://www.antlr.org/index.html)

语法示例GitHub仓库：[antlr/grammars-v4: Grammars written for ANTLR v4; expectation that the grammars are free of actions.](https://github.com/antlr/grammars-v4)

python版本：3.11 官网[Python Releases for Windows | Python.org](https://www.python.org/downloads/windows/)

python antlr4 使用说明：[antlr4/doc/python-target.md 在 master ·ANTLR/ANTLR4 --- antlr4/doc/python-target.md at master · antlr/antlr4](https://github.com/antlr/antlr4/blob/master/doc/python-target.md)

*简单说明用python的原因，一是不想用java，写着难受；二是这段时间用python多。主要是学习用法，之后改写各种语言也方便。*

安装库：`antlr4-python3-runtime`

## 分析SQL语句的规划
1. 表级数据流分析
2. 识别sql语句的表名字段名称
	1. 能把 * 替换为元数据具体字段
	2. 能把表名编译到字段上去，直接替换表明 as alias 的场景
