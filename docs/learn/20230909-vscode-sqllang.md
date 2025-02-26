---
title: sql语言脚本开发-语法突出 
date: 2023-08-27 23:48:19
toc: true 
tags: ["sql","vscode-extension","vscode"]
categories: ['技术博客']
---

# SQL语言脚本开发-语法突出 

语法突出显示指南：VS Code 使用文本伴侣(TextMate)语法进行语法突出显示。本指南将引导您编写简单的 TextMate 语法并将其转换为 VS Code 扩展。

## TextMate 语法

```js
{  
   scopeName = 'source.untitled';
   fileTypes = ( );
   foldingStartMarker = '\{\s*$';
   foldingStopMarker = '^\s*\}';
   patterns = (
      {  name = 'keyword.control.untitled';
         match = '\b(if|while|for|return)\b';
      },
      {  name = 'string.quoted.double.untitled';
         begin = '"';
         end = '"';
         patterns = ( 
            {  name = 'constant.character.escape.untitled';
               match = '\\.';
            }
         );
      },
   );
}
```

语言语法用于为文档元素（如关键字、注释、字符串或类似元素）分配名称。这样做的目的是允许样式（语法突出显示），并使文本编辑器“智能”了解插入符号所在的上下文。例如，您可能希望击键或制表符触发器根据上下文采取不同的操作，或者您可能希望在键入文本文档中非散文的部分（例如.HTML标签）时禁用拼写检查。

+ scopeName （第 1 行）— 这应该是语法的唯一名称，遵循点分隔名称的约定，其中每个新（最左侧）部分专门化名称。通常，它将是一个由两部分组成的名称，其中第一部分是 text OR source 部分，第二部分是语言或文档类型的名称。但是，如果要专用于现有类型，则可能希望从要专用的类型派生名称。例如 Markdown 是 和 Ruby on Rails （ rhtml 文件） 是 text.html.rails text.html.markdown 。从（在这种情况下） text.html 派生它的优点是，在作用域中工作的所有内容也将在 text.html text.html.«something» 作用域中工作（但优先级低于专门针对 text.html.«something» 的内容）。

+ patterns （第 5-18 行）— 这是一个数组，其中包含用于解析文档的实际规则。在此示例中，有两个规则（第 6-8 行和第 9-17 行）。规则将在下一节中解释。

   **规则可以通过两种方式与文档匹配：**

   它可以提供一个正则表达式，也可以提供两个正则表达式。与上面第一条规则（第 6-8 行）中的 match 键一样，与该正则表达式匹配的所有内容都将获得该规则指定的名称。

   另一种类型的匹配是第二条规则（第 9-17 行）使用的匹配。这里使用 and begin end 键给出两个正则表达式。规则的名称将从开始模式匹配的位置分配到结束模式匹配的位置（包括两个匹配）。如果结束模式不匹配，则使用文档的结尾。
   
   **规则键：**

   name — 分配给匹配部分的名称。这用于样式设置和特定于范围的设置和操作，这意味着它通常应派生自标准名称之一（请参阅后面的命名约定）。

   captures ， ， beginCaptures — endCaptures 这些键允许您将属性分配给 match 、 begin 或 end 模式的捕获。将 captures 键用于 begin / end 规则是给出两者 beginCaptures 并 endCaptures 具有相同值的简写。
   
   include — 这允许您引用不同的语言，递归引用语法本身或在此文件的存储库中声明的规则。





+ repository — 规则的字典（即.key/值对），可以从语法中的其他地方包含。键是规则的名称，值是实际规则。 include 规则键的说明（和示例）之后是进一步的说明。

注入语言嵌入式语言还有一个额外的复杂性：默认情况下，VS Code 将字符串中的所有标记视为字符串内容，将带有注释的所有标记视为标记内容。由于括号匹配和自动结束对等功能在字符串和注释中被禁用，因此如果嵌入语言出现在字符串或注释中，这些功能也将在嵌入语言中被禁用。

语言支持，不能平行扩展，只能细化扩展；平行扩展可以重新搞一份，在基础上改造


