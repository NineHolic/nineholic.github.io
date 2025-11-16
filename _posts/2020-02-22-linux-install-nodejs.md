---
layout: post
title: Node.js 的安装与使用
categories: [Node.js]
description: Node.js 的安装与使用
keywords: Node.js, Linux, Windows
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

Node.js 就是运行在服务端的 JavaScript， 是一个基于 [Chrome V8](https://developers.google.com/v8/) 引擎的 JavaScript 运行环境，Node.js 使用了一个事件驱动、非阻塞式 I/O 的模型，使其轻量又高效。npm 是 Node.js 依赖包管理工具，新版的 Node.js 已自带 npm ，安装 Node.js 时会一起安装。

安装包及源码地址：https://nodejs.org/dist

##### 1、Linux 安装配置

```bash
# 下载 Node.js
wget https://nodejs.org/dist/v13.5.0/node-v13.5.0-linux-x64.tar.xz

# 解压到指目录下
tar -xvf node-v13.5.0-linux-x64.tar.xz -C /usr/local/

# 配置环境变量
cat >> /etc/profile << "EOF"

NODE_HOME=/usr/local/node-v13.5.0-linux-x64
NODE_PATH=$NODE_HOME/lib/node_modules
PATH=$PATH:$NODE_HOME/bin
export PATH NODE_HOME NODE_PATH
EOF

# 使修改生效
source /etc/profile

# 配置淘宝镜像
npm config set registry https://registry.npmmirror.com

# sass 模块
npm config set sass_binary_site https://npmmirror.com/mirrors/node-sass/

# 验证以上是否配置成功
npm config list
```

> 原淘宝 npm 域名已下线和停止 DNS 解析，相关服务域名切换规则：
>
> `npm.taobao.org -> npmmirror.com`
> `registry.npm.taobao.org -> registry.npmmirror.com`

##### 2、Windows 安装配置

```bash
# 下载解压到本地，在安装目录下新建 node_global 和 node_cache 目录
https://nodejs.org/dist/v13.5.0/node-v13.5.0-x64.msi

# 配置 npm 安装的全局模块和缓存的路径（默认为 C 盘用户目录下）
npm config set prefix “D:\Program Files\nodejs\node_global”
npm config set cache “D:\Program Files\nodejs\node_cache”

# 配置淘宝镜像
npm config set registry https://registry.npmmirror.com

# 验证是否安装成功
node -v
npm -v

# 验证以上是否配置成功
npm config list
```

![image-20210520001758139](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20210520001758139.png)

##### 3、报错处理

![image-20230709224421516](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20230709224421516.png)

> 新版的 node v18 开始 都需要 GLIBC_2.27 支持，系统内却没有那么高的版本，可以根据提示安装所需要的 glibc-2.28 或者使用旧版本 nodejs，也可以通过 docker 方式来安装高版本

