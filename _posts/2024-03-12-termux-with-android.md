---
layout: post
title: Termux 的简单使用
categories: [Android]
description: Android 上终端模拟器简单使用
keywords: Android, Termux
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

Termux 是一个 Android 下一个高级的终端模拟器，开源且不需要 root，支持 apt 管理软件包，十分方便安装软件包，完美支持 Python、 PHP、 Ruby、 Nodejs、 MySQL 等。

首次启动 Termux 时需要从[远程服务器](http://termux.net/bootstrap/)加载数据，可能会遇到以下报错，可尝试使用代理或流量再重试：

![image-20240312102411238](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/android/image-20240312102411238.png)

```shell
# 替换官方源为 TUNA 镜像源
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-main stable main@' $PREFIX/etc/apt/sources.list
apt update && apt upgrade

# 安装基本工具
pkg install vim curl wget git unzip -y
```

Termux 除了支持 `apt` 命令外，还在此基础上封装了 `pkg` 命令，`pkg` 命令向下兼容 `apt` 命令

```shell
pkg search <query>              # 搜索包
pkg install <package>           # 安装包
pkg uninstall <package>         # 卸载包
pkg reinstall <package>         # 重新安装包
pkg update                      # 更新源
pkg upgrade                     # 升级软件包
pkg list-all                    # 列出可供安装的所有包
pkg list-installed              # 列出已经安装的包
pkg show <package>              # 显示某个包的详细信息
pkg files <package>             # 显示某个包的相关文件夹路径

# 相关目录
echo $HOME
/data/data/com.termux/files/home

echo $PREFIX
/data/data/com.termux/files/usr

echo $TMPPREFIX
/data/data/com.termux/files/usr/tmp/zsh
```

```shell
# 终端配色，github 访问不了的可以使用第二个地址
sh -c "$(curl -fsSL https://github.com/Cabbagec/termux-ohmyzsh/raw/master/install.sh)"
sh -c "$(curl -fsSL https://html.sqlsec.com/termux-install.sh)"
```

Android6.0 以上会弹框确认是否授权访问文件，点击`允许`授权后 Termux 可以方便的访问 SD 卡文件

![image-20240314213753019](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/android/image-20240314213753019.png)

```shell
# 脚本允许后先后有如下两个选项，分别是背景色和字体
Enter a number, leave blank to not to change: 14
Enter a number, leave blank to not to change: 22

# 想要继续更改挑选配色的话，可以运行脚本再次选择
~/.termux/colors.sh
~/.termux/fonts.sh
```

![image-20240314202804546](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/android/image-20240314202804546.png)

```shell
# 查看本机 ip 
ifconfig

# 启动 SSH 服务并配置自启动
sshd && echo sshd >> ~/.bashrc

# 查看当前用户
whoami

# 设置密码
passwd

# 查看 ssh 端口，一般为 8022
netstat -tnlp
```

然后可以使用 xshell 等工具进行连接

proot-distro 支持几乎所有常用的 Linux 发行版：Alpine、Arch、Debian、ubuntu、manjaro 等等

```shell
pkg install proot-distro -y

# 查看本机支持安装的 linux 环境
proot-distro list

# 安装 ubuntu 环境，等待安装完成
proot-distro install ubuntu

# 进入 ubuntu shell 环境
proot-distro login ubuntu
```

