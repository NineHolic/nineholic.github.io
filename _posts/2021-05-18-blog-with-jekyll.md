---
layout: post
title: Docker 部署 Jekyll 静态博客
categories: [Docker]
description: 本地运行 Jekyll 博客，方便调试
keywords: Jekyll, Docker, Blog, Linux
---

使用 Docker 本地部署 Jekyll 项目，可供服务器上搭建个人博客、本地预览调试代码。

```shell
# 拉取项目
git clone https://github.com/NineHolic/nineholic.github.io
cd nineholic.github.io

# 构建镜像
docker build -t nine_blog:20241031 .

# 查看镜像
docker images

# 使用宿主机端口启动容器
docker run --network host --name blog -v $(pwd):/blog nine_blog:20241031 bash -c "jekyll serve -w --host=192.168.216.128"

# 开放端口
firewall-cmd --zone=public --permanent --add-port=4000/tcp
firewall-cmd --reload
```
浏览器访问查看效果：[http://192.168.216.128:4000](http://192.168.216.128:4000)

镜像使用版本参考：[Github Pages 运行环境](https://pages.github.com/versions.json)

