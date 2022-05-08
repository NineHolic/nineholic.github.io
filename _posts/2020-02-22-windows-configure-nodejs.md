---
layout: post
title: Windows 下安装配置 Node.js
categories: [Windows, Node.js]
description: Node.js 环境配置
keywords: Windows, Node.js
---

Windows 下安装配置Node.js

##### 1、安装 Node.js

安装包及源码地址：https://nodejs.org/dist，下载相应版本，本文为：`node-v13.10.0-x64.msi`。

修改安装目录后点击 next 至安装完成，打开 cmd 验证是否安装成功。

> Node.js 就是运行在服务端的 JavaScript， 是一个基于 [Chrome V8](https://developers.google.com/v8/) 引擎的 JavaScript 运行环境
>
> Node.js 使用了一个事件驱动、非阻塞式 I/O 的模型，使其轻量又高效
>
> npm 是 Node.js 依赖包管理工具，新版的 Node.js 已自带 npm ，安装 Node.js 时会一起安装

```powershell
node -v
npm -v
```

![image-20210519230930635](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20210519230930635.png)

##### 2、环境配置

在安装目录下新建 node_global 和 node_cache 目录。

```shell
# 配置 npm 安装的全局模块和缓存的路径（默认为 C 盘用户目录下）
npm config set prefix “D:\Program Files\nodejs\node_global”
npm config set cache “D:\Program Files\nodejs\node_cache”

# 配置淘宝镜像
npm config set registry https://registry.npm.taobao.org

# 验证以上是否配置成功
npm config list

# 全局安装 Vue 模块，安装后会发现空目录 node_global 和 node_cache 产生了相关文件
npm install -g vue
```

![image-20210520001758139](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20210520001758139.png)