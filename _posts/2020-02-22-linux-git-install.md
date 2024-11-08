---
layout: post
title: Linux 下安装 Git 
categories: [Git]
description: Linux 下 git 的安装
keywords: Git, Linux
---

Linux 下编译安装 git 以及使用脚本安装

#### 一、脚本安装

```bash
# 脚本安装 2.45.0 版本
curl -sSL https://fastly.jsdelivr.net/gh/NineHolic/nineholic.github.io@master/_posts/files/shell/install_git.sh | bash
```

#### 二、手动安装

##### 1、安装依赖

```shell
# Centos/RedHat
yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker autoconf automake libtool wget

# 卸载旧版
yum -y remove git

# Debian/Ubuntu
apt-get -y install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev make wget
```

##### 2、编译安装

源码地址：[https://mirrors.edge.kernel.org/pub/software/scm/git/](https://mirrors.edge.kernel.org/pub/software/scm/git/)

```shell
# 下载源码
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.45.0.tar.gz

# 解压
tar -zxvf git-2.45.0.tar.gz && cd git-2.45.0

# 编译安装
make configure
./configure --prefix=/usr/local/git
make -j2 all && make -j2 install
```

##### 3、配置环境

```shell
# 添加软连接
ln -s /usr/local/git/bin/git /usr/bin/git

# 查看 git 是否安装完成
git --version
```

