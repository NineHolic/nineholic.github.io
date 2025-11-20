---
layout: post
title: Git 的安装与使用
categories: [Git]
description: Git 的安装与使用
keywords: Git, Linux
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

以 yum 安装的 git 版本较旧，这里使用源码编译的方式安装 git。

##### 1、脚本安装

```bash
# 脚本安装 2.45.0 版本，会卸载 yum 安装的旧版本
curl -sSL https://raw.githubusercontent.com/NineHolic/script/master/linux/install_git.sh | bash
```

##### 2、手动安装

```bash
# 安装依赖，会自动安装较旧版本的 git
yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker autoconf automake libtool wget

# 卸载旧版
yum -y remove git

# Debian/Ubuntu
apt-get -y install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev make wget

# 下载源码
wget https://github.com/git/git/archive/refs/tags/v2.45.0.tar.gz

# 镜像地址
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.45.0.tar.gz

# 解压
tar -zxvf git-2.45.0.tar.gz && cd git-2.45.0

# 编译安装
make configure
./configure --prefix=/usr/local/git
make -j2 all && make -j2 install

# 添加软连接
ln -s /usr/local/git/bin/git /usr/bin/git

# 查看 git 版本
git --version
```
