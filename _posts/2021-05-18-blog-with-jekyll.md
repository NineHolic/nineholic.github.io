---
layout: post
title: Docker 本地部署 Jekyll 静态博客
categories: [Jekyll]
description: 本地运行 Jekyll 博客，方便调试
keywords: Jekyll, Docker, Linux, Centos, Blog
topmost: true
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

使用 Docker 本地部署 Jekyll 项目，可供服务器上搭建个人博客、本地实时预览调试代码。

```shell
# 拉取项目
git clone https://github.com/NineHolic/nineholic.github.io
cd nineholic.github.io

# 构建镜像
docker build -t Blog:v1 .

# 查看镜像
docker images

# 使用宿主机端口启动容器，并在修改源文件时自动重新构建
docker run --network host --name blog -v $(pwd):/blog Blog:v1 bash -c "jekyll serve -w --host=192.168.216.128"

# 开放端口
firewall-cmd --zone=public --permanent --add-port=4000/tcp
firewall-cmd --reload
```

Dockerfile 文件内容：

```Dockerfile
# 使用 Ruby 官方镜像作为基础镜像
FROM ruby:3.3.4
 
# 创建一个新的目录用于存放 Jekyll 网站
RUN mkdir /blog
WORKDIR /blog
 
# 安装依赖
COPY Gemfile /blog
RUN bundle config mirror.https://rubygems.org https://mirrors.tuna.tsinghua.edu.cn/rubygems
RUN bundle install --verbose

# 容器启动时执行的命令
CMD jekyll --version
```

浏览器访问查看效果：[http://192.168.216.128:4000](http://192.168.216.128:4000)

镜像使用版本参考：[Github Pages 运行环境](https://pages.github.com/versions.json)
