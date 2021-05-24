---
layout: post
title: Linux 下安装 java
categories: [java, linux]
description: linux 下 java 的手动安装及脚本安装
keywords: java linux
---

linux 下安装配置 jdk 1.8、jdk 11

#### 一、手动安装

##### 1、下载 jdk

官网地址：[jdk 1.8](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html)、[jdk 11](https://www.oracle.com/java/technologies/javase/javase-jdk11-downloads.html)

```shell
# 根据自身 linux 的版本下载对应的 jdk 版本
uname -a

# 新建 java 安装目录
mkdir /usr/local/java

# 解压
tar -zxvf jdk-8u241-linux-x64.tar.gz -C /usr/local/java
```

![image-20200510203033047](https://gitee.com/NineHolic/cloudimage/raw/master/linux/image-20200510203033047.png)

##### 2、配置环境变量

```ini
vim /etc/profile

# 在 profile 文件末尾中添加如下内容并保存
JAVA_HOME=/usr/local/java/jdk1.8.0_241        
JRE_HOME=/usr/local/java/jdk1.8.0_241/jre     
CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export JAVA_HOME JRE_HOME CLASS_PATH PATH

# jdk 11 配置环境变量则较为简单
JAVA_HOME=/usr/local/java/jdk-11.0.11
export PATH=$PATH:$JAVA_HOME/bin

# 使修改的环境变量生效
source /etc/profile
```

> 其中 JAVA_HOME，JRE_HOME 根据自己的实际安装路径及 JDK 版本配置

##### 3、验证是否安装成功

输入`java -version`，显示 java 版本信息，则说明 JDK 安装成功

![image-20200510203046295](https://gitee.com/NineHolic/cloudimage/raw/master/linux/image-20200308231107030.png)

#### 二、脚本安装

```shell
# jdk 1.8
wget https://cdn.jsdelivr.net/gh/NineHolic/nineholic.github.io@master/_posts/files/shell/install_jdk8.sh && /bin/bash install_jdk8.sh
```

```shell
# # jdk 11
wget https://cdn.jsdelivr.net/gh/NineHolic/nineholic.github.io@master/_posts/files/shell/install_jdk11.sh && /bin/bash install_jdk11.sh
```
