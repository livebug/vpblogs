---
title: 正则表达式-先行断言(lookahead)和后行断言(lookbehind)
date: 2023-09-17 23:48:19
tags:
- regex

---
# 正则表达式 学习

## 先行断言(lookahead)和后行断言(lookbehind)
正则表达式的先行断言和后行断言一共有 4 种形式：
 
+ `(?=pattern)`  零宽正向先行断言`(zero-width positive lookahead assertion)`

    正向先行断言 代表字符串中的一个位置，紧接该位置之后的字符序列能够匹配 pattern。

+ `(?!pattern)`  零宽负向先行断言`(zero-width negative lookahead assertion)`

    负向先行断言 代表字符串中的一个位置，紧接该位置之后的字符序列不能匹配 pattern。

+ `(?<=pattern)` 零宽正向后行断言`(zero-width positive lookbehind assertion)`

    正向后行断言 代表字符串中的一个位置，紧接该位置之前的字符序列能够匹配 pattern。
+ `(?<!pattern)` 零宽负向后行断言`(zero-width negative lookbehind assertion)`

    负向后行断言 代表字符串中的一个位置，紧接该位置之前的字符序列不能匹配 pattern。