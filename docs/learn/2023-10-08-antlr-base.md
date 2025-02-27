---
title : ' Antlr4 基础介绍'
date : 2023-10-04T09:13:17+08:00
toc: true
# draft : true
tags :
- antlr4

---
# Antlr4 基础介绍

## antlr 安装

下载 jar 包，因为生成工具是用java写的，要保证安装了java，11版本以适应最新版安装

有大量 java C# 的案例代码

github 地址： https://github.com/antlr/antlr4 

基础文档： [getting-started-with-antlr-v4](https://github.com/antlr/antlr4/blob/master/doc/getting-started.md#getting-started-with-antlr-v4)

```bash
$ cd /usr/local/lib
$ curl -O https://www.antlr.org/download/antlr-4.9-complete.jar
# 后面的写到 .bashrc 中
$ export CLASSPATH=".:/usr/local/lib/antlr-4.9-complete.jar:$CLASSPATH"
$ alias antlr4='java -Xmx500M -cp "/usr/local/lib/antlr-4.9-complete.jar:$CLASSPATH" org.antlr.v4.Tool'
$ alias grun='java -Xmx500M -cp "/usr/local/lib/antlr-4.9-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig'
```

## 编译案例
```bash
# 编译
antlr4 -lib ./ HiveParser.g4 -o csharp -Dlanguage=CSharp  -visitor -package Hive.V3
```

## C# 项目中增加 build 工具
### 添加工具包
```bash
# Antlr4BuildTasks
<Project Sdk="Microsoft.NET.Sdk">
	<PropertyGroup>
		<OutputType>Exe</OutputType>
		<TargetFramework>net6.0</TargetFramework>
		<ImplicitUsings>enable</ImplicitUsings>
		<Nullable>enable</Nullable>
	</PropertyGroup>
	<ItemGroup>
		<Content Include="input">
			<CopyToOutputDirectory>Always</CopyToOutputDirectory>
		</Content>
	</ItemGroup>
	<ItemGroup>
		<PackageReference Include="Antlr4.Runtime.Standard" Version="4.10.1" />
		<PackageReference Include="Antlr4BuildTasks" Version="10.7" />
	</ItemGroup>
	<ItemGroup>
		<Antlr4 Include="Hello.g4" />
	</ItemGroup>
</Project>
```

### 方法二： 项目文件增加构建规则
```bash
<Project Sdk="Microsoft.NET.Sdk">
	<PropertyGroup>
		<OutputType>Exe</OutputType>
		<TargetFramework>net6.0</TargetFramework>
		<ImplicitUsings>enable</ImplicitUsings>
		<Nullable>enable</Nullable>
	</PropertyGroup>
	<ItemGroup>
		<Content Include="input">
			<CopyToOutputDirectory>Always</CopyToOutputDirectory>
		</Content>
	</ItemGroup>
	<ItemGroup>
		<PackageReference Include="Antlr4.Runtime.Standard" Version="4.10.1" />
	</ItemGroup>
	<Target Name="tool">
		<Exec Command="java -jar ../antlr4-4.10.1-complete.jar -Dlanguage=CSharp *.g4"/>
	</Target>
	<PropertyGroup>
		<BuildDependsOn>
			tool;
			$(BuildDependsOn)
		</BuildDependsOn>
	</PropertyGroup>
	<PropertyGroup>
		<CoreCompileDependsOn>
			tool;
			$(CoreCompileDependsOn)
		</CoreCompileDependsOn>
	</PropertyGroup>
	<ItemGroup>
		<Compile Include="Program.cs;HelloBaseListener.cs;HelloLexer.cs;HelloListener.cs;HelloParser.cs"/>
		<CompileDesignTime Include="Program.cs;HelloBaseListener.cs;HelloLexer.cs;HelloListener.cs;HelloParser.cs"/>
	</ItemGroup>
	<PropertyGroup>
		<EnableDefaultCompileItems>false</EnableDefaultCompileItems>
	</PropertyGroup>
	<PropertyGroup>
		<NoWarn>3021;1701;1702</NoWarn>
	</PropertyGroup>
</Project>
```