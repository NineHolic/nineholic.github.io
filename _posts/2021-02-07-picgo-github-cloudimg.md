---
layout: post
title: PicGo 结合 GitHub 搭建图床
categories: [GitHub]
description: GitHub/Gitee 作为图床介绍
keywords: Picgo, GitHub, Gitee, 图床
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

PicGo 结合 GitHub/Gitee 搭建图床，用于存储博客图片。

##### 1、安装 PicGo 

下载地址：[https://github.com/Molunerfinn/PicGo/releases](https://github.com/Molunerfinn/PicGo/releases)，[说明文档](https://picgo.github.io/PicGo-Doc/zh/guide/getting-started.html)

> 安装插件需有 Node.js 环境，否则安装时会一直显示安装中
>
> Gitee 上的图片目前已取消了外部链接访问，网站图片无法显示，仅本地可显示

![image-20210521100351986](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20210521100351986.png)

##### 2、新建图床仓库

在  GitHub 上新建一个公开的非空仓库（空仓库上传图片时会报 500 错误），然后在`Settings / Developer settings`下生成一个新 token 用于 PicGo 上传图片，权限勾选 repo 下所有选项

![image-20220609234116020](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20220609234116020.png)

Gitee 则在设置 -> 私人令牌下生成

![image-20210521135839665](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20210521135839665.png)

##### 3、图床设置

参数说明见[插件文档](https://github.com/lizhuangs/picgo-plugin-gitee-uploader)

按 GitHub 仓库信息配置，自定义域名使用 jsdeliver 的 cdn：

![image-20220609234326112](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20220609234326112.png)

按 Gitee 仓库信息配置：

![image-20210521110641031](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20210521104752973.png)

> - customPath 选择 default ，则实际的 path 值为 linux
> - customPath 选择年，则实际的 path 值为 linux/2021
> - customPath 选择年季，则实际的 path 值为 linux/2021/summer
> - customPath 选择年月，则实际的 path 值为 linux/2021/02

##### 4、图片上传

上传区选择 GitHub 或 Gitee，文件会上传至仓库 linux 文件夹下，上传后可在相册下查看和删除（远程仓库也会同步删除）。

![image-20210521104752973](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20210521110641031.png)



##### 5、结合 Typora 使用

在文件 -> 偏好设置 -> 图像设置下配置上传服务设定：

![image-20210521112858130](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20210521112728115.png)

点击验证图片上传选项，上传成功。

![image-20210521103849517](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20210521112858130.png)

![image-20210521112728115](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20210521103849517.png)

对于 md 文件内的本地或其它外链图片，也可单独或者上传全部图片到远程仓库中。

![2021-05-21_11-35-49](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/win/2021-05-21_11-35-49.png)

慎用上传所有本地图片，图片较多时会打乱图片在文章中的位置，应该是 Typora 的 bug

![image-20210521140022177](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20210521140022177.png)

