---
title: gitee增加ssh 实现免密访问
date: 2023-09-22 23:48:19
toc: true
tags:
- ssh
- gitee 

---
# gitee增加ssh 实现免密访问

## 前言
其实实现这个很简单，根据提供的提示文档按部就班增加就行

https://help.gitee.com/base/account/SSH%E5%85%AC%E9%92%A5%E8%AE%BE%E7%BD%AE#:~:text=%E5%85%AC%E9%92%A5%E8%AE%BE%E7%BD%AE-,SSH%20%E5%85%AC%E9%92%A5%E8%AE%BE%E7%BD%AE,-Gitee%20%E6%8F%90%E4%BE%9B%E4%BA%86


本文主要是想说明 ssh的原理以及应用

## SSH 原理

### 什么是SSH 
SSH 叫安全外壳协议（Secure Shell），是一种加密的网络传输协议，可在不安全的网络中网络服务提供安全的传输环境。它通过在网络中创建安全隧道来实现 SSH 客户端和服务器之间的连接。
### 对称加密
对方同自己用于同样的密钥，加解密时用一样的
### 非对称加密
非对称加密需要一对秘钥来进行加密和解密，公开的秘钥叫公钥，私有的秘钥叫私钥。注意公钥加密的信息只有私钥才能解开（加密过程），私钥加密的信息只有公钥才能解开（验签过程）。比较常用的非对称加密算法有 RSA。


<img src="https://img-blog.csdn.net/20160319193556260" alt="ssh免密码登录原理图" title=""> 

图解， `Server A` 免登录到 `Server B` :  
1. 在A上生成公钥、私钥
2. 将公钥拷贝给 `Server B` ，将公钥拷贝到
3.  `Server A` 向 `Server B` 发送一个连接请求。 
4.  `Server B` 得到 `Server A` 的信息后，在authorized_key中查找，如果有相应的用户名和IP，则随机生成一个字符串，并用 `Server A` 的公钥加密，发送给 `Server A` 。 
5.  `Server A` 得到 `Server B` 发来的消息后，使用私钥进行解密，然后将解密后的字符串发送给 `Server B` 。 `Server B` 进行和生成的对比，如果一致，则允许免登录。   

总之 ：A要免密码登录到B，B首先要拥有A的公钥，然后B要做一次加密验证。对于非对称加密，公钥加密的密文不能公钥解开，只能私钥解开。


 