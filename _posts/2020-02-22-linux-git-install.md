---
layout: post
title: Linux 下安装 Git 
categories: [git, linux]
description: linux 下 git 的安装，使用脚本进行安装
keywords: git, linux
---

linux 下编译安装 git 以及使用脚本安装

#### 一、手动安装

##### 1、安装依赖

```shell
# Centos/RedHat
yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker wget

# Debian/Ubuntu
apt-get -y install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev make wget
```

安装编译源码所需依赖时，yum 会自动安装 git，需要先卸载旧版：`yum -y remove git`。

##### 2、编译安装

源码地址：[https://mirrors.edge.kernel.org/pub/software/scm/git/](https://mirrors.edge.kernel.org/pub/software/scm/git/)

```shell
# 下载源码
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.24.1.tar.gz

# 解压
tar -zxvf git-2.24.1.tar.gz

# 编译安装 git 源码
cd git-2.24.1
make configure
./configure --prefix=/usr/local/git
make -j2 all && make -j2 install
```

##### 3、配置环境

```shell
vim /etc/profile

# 添加到 PATH 中
PATH=$PATH:/usr/local/git/bin
export PATH

# 使得刚修改的环境变量生效
source /etc/profile

# 查看 git 是否安装完成
git --version
```

![image-20200613192918431](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/git/image-20200613192918431.png)

![image-20200613193019509](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/git/image-20200613193019509.png)

#### 二、脚本安装

```shell
# 脚本默认下载 2.24.1 版本进行安装，若有版本要求，先 wget 下载脚本，修改版本号后再执行
wget https://cdn.jsdelivr.net/gh/NineHolic/nineholic.github.io@master/_posts/files/shell/install_git.sh && /bin/bash install_git.sh
```

