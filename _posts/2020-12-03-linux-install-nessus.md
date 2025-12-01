---
layout: post
title: Nessus 的安装与使用
categories: [Linux]
description: Nessus 的安装与使用
keywords: Nessus, Linux, Centos
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

Nessus 是著名信息安全服务公司 tenable 推出的一款漏洞扫描与分析软件，在 Linux, FreeBSD, Solaris, Mac OS X 和Windows 下都可以使用 Nessus。Nessus 目前分为四个版本：Nessus Essentials、Nessus Professional 等，其中Essentials 版本为免费版本。

##### 1、安装配置

根据系统下载安装包：[https://www.tenable.com/downloads/nessus](https://www.tenable.com/downloads/nessus)，本机为 Centos7

```bash
# 安装
rpm -ivh Nessus-8.12.1-es7.x86_64.rpm

# 启动
service nessusd start

# 开放 8834 端口
firewall-cmd --zone=public --permanent --add-port=8834/tcp
firewall-cmd --reload
```

进入：[https://192.168.33.131:8834](https://192.168.33.131:8834)进行配置（windows版安装后会自动打开浏览器），选择 Essentials 免费版Continue

![image-20201203092618659](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/security/image-20201203092618659.png)

注册获取一次性的激活码或进入[官网注册](https://www.tenable.com/products/nessus/activation-code)获取

![image-20201203093142336](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/security/image-20201203093142336.png)

输入激活码或者使用离线注册方式在官网获取 License Key（离线方式可本机重复安装）

![image-20201203093617208](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/security/image-20201203094000377.png)

创建账号 Submit 后会自动下载插件

![image-20201203094000377](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/security/image-20201203093617208.png)![image-20201203093933292](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/security/image-20201203093933292.png)

##### 2、安装插件

启动成功后在`Setting->About`下可以看到插件是否安装成功

本机未安装成功，Plugin Set 显示为 N/A，点击 Last Updated 的小圈会执行更新操作

![image-20201203095130433](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/security/image-20201203095130433.png)

无法访问外网的可使用代理进行在线更新

![image-20201203095352627](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/security/image-20201203095352627.png)

或者使用[插件包](https://cloud.189.cn/t/IZvIz2Rn2qiy)(1yb1)更新，在[官网](https://plugins.nessus.org/offline.php)填入 challenge code 和 activation code（重新注册）来获取下载地址

```bash
# 进入安装目录下
cd /opt/nessus/sbin

# 获取 challenge code
./nessuscli fetch --challenge

# 手动更新
./nessuscli update all-2.0_202011270400.tar.gz

# 重启服务，等待编译完成
service nessusd restart
```

![image-20201203102006441](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/security/image-20201203100505622.png)

![image-20201203100505622](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/security/image-20201203100550805.png)

此插件包为专业版，解除了 16 个 IP 的限制

![image-20201203100550805](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/security/image-20201203102006441.png)
