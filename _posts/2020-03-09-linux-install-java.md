---
layout: post
title: Java 的安装与使用
categories: [Java]
description: Java 的安装与使用
keywords: Java, Linux
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

Linux 下安装配置 jdk 1.8、jdk 11。

##### 1、手动安装

Oracle 官网地址：[jdk 1.8](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html)、[jdk 11](https://www.oracle.com/java/technologies/javase/javase-jdk11-downloads.html)

```shell
# 根据自身 Linux 的版本下载对应的 jdk 版本
uname -a

# 新建 Java 安装目录
mkdir /usr/local/java

# 解压
tar -zxvf jdk-8u241-linux-x64.tar.gz -C /usr/local/java
```

![image-20200510203033047](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20200510203033047.png)

```bash
# 添加环境变量，JAVA_HOME，JRE_HOME 根据自己的实际安装路径及 JDK 版本配置
vim /etc/profile

# jdk8
JAVA_HOME=/usr/local/java/jdk1.8.0_241        
JRE_HOME=/usr/local/java/jdk1.8.0_241/jre     
CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export JAVA_HOME JRE_HOME CLASS_PATH PATH

# jdk11 配置环境变量
JAVA_HOME=/usr/local/java/jdk-11.0.11
export PATH=$PATH:$JAVA_HOME/bin

# 使修改的环境变量生效
source /etc/profile

# 测试是否安装成功
java -version
```

![image-20200510203046295](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20200308231107030.png)

##### 2、脚本安装

安装目录在脚本中修改：`/usr/local/java`

```bash
# jdk 1.8
wget https://fastly.jsdelivr.net/gh/NineHolic/nineholic.github.io@master/_posts/files/shell/install_jdk8.sh && /bin/bash install_jdk8.sh

# jdk 11
wget https://fastly.jsdelivr.net/gh/NineHolic/nineholic.github.io@master/_posts/files/shell/install_jdk11.sh && /bin/bash install_jdk11.sh
```

