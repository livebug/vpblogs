---
title: python3 基础学习
tags:
  - python
---
# python3 基础学习
### 1. python 生成requirements.txt
```bash
pip freeze > requirements.txt
```
### 2. 根据  requirements.txt 下载包
```bash
pip download -r .\requirements.txt .\packages\
```
### 3. venv 开发环境
```bash
# 基本语法
python3 -m venv 环境名称
```
