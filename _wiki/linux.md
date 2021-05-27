---
layout: post
title: Linux
categories: linux
description: 记录学习 linux 中一些方便使用的技巧
keywords: centos ubuntu linux
---

学习和使用 linux 过程中遇到的问题和解决办法

##### 更换yum源

将本地 CentOS 的 yum 安装源更换为阿里源

```shell
# 备份本地 yum 源
mv /etc/yum.repos.d/* /etc/yum.repos.d.bak/

# 使用 curl 或 wget 命令下载阿里源文件
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

# 清理缓存
yum clean all

# 生成新的缓存
yum makecache

# 测试yum
yum search openssh
```

##### 更换apt源

清华开源镜像站：https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu，选择ubuntu版本

```shell
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释 16.04 LTS
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-proposed main restricted universe multiverse
```

```shell
# 备份本地源文件
cp /etc/apt/sources.list /etc/apt/sources.bak1

# 修改源文件，将清华源写入
vim /etc/apt/sources.list

# 更新软件源列表：访问源列表里的每个网址，并读取软件列表，然后保存在本地电脑
apt-get update

# 更新软件：更新本地已安装的软件，生产环境慎用
apt-get upgrade
```

##### 查看 linux 版本

```shell
# 查看版本
cat /proc/version
uname -a

cat /etc/redhat-release
```

![image-20200314233256451](https://gitee.com/NineHolic/cloudimage/raw/master/linux/image-20200314233256451.png)

##### 域名无法ping通

```shell
# 修改 reolv.conf，配置 dns，添加两行
nameserver 114.114.114.114
nameserver 223.5.5.5
```

![image-20210201190205276](https://gitee.com/NineHolic/cloudimage/raw/master/linux/image-20210201190205276.png)

##### 修改主机名称

修改 etc 目录下的 hosts 文件和 hostname 文件后重启系统

![image-20200308201048591](https://gitee.com/NineHolic/cloudimage/raw/master/linux/image-20200308201048591.png)

##### 修改 ssh 端口号

```shell
# 将默认的 22 端口改为 22333 端口
vim /etc/ssh/sshd_config

# 重启ssh，此时另起连接窗口使用 22333 端口测试连接，防止修改失败连不上
systemctl restart sshd
```

##### 用户名所在行高亮显示

修改登录用户目录下的 .bashrc 文件，把46行的`# force_color_prompt=yes`注释去掉保存后重新登录，

（如果使用其他用户登录，其下的 .bashrc 也要修改，和终端软件无关）

![image-20200307235430234](https://gitee.com/NineHolic/cloudimage/raw/master/linux/image-20200307235430234.png)

重新登录后

![image-20200307235437332](https://gitee.com/NineHolic/cloudimage/raw/master/linux/image-20200307235437332.png)

如果没有找到`# force_color_prompt=yes`这一行，把以下内容添加到 .bashrc 中：

```shell
force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
```

```shell
# 执行后重新登录即可
wget https://cdn.jsdelivr.net/gh/NineHolic/nineholic.github.io@master/_posts/files/shell/setcolor.sh && /bin/bash setcolor.sh
```

##### 删除自带的 openjdk

```shell
# 查看 openjdk 的路径
alternatives --config java

# ARM 架构位置
/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.232.b09-0.el7_7.aarch64/jre/bin/java

# X86 架构位置
/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.171-2.6.13.2.el7.x86_64/jre/bin/java

# 假删除（防止出现一些奇怪错误），解除 openjdk 的链接配置后自己的 jdk 就行
alternatives --remove java /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.232.b09-0.el7_7.aarch64/jre/bin/java

# 真删除，使用 java -version 查看是否删除成功
rm -rf java-1.8.0-openjdk-1.8.0.232.b09-0.el7_7.aarch64
```

##### vi/vim 临时/永久显示行号

- 临时显示，`vi`命令执行后输入：`：set nu`


- 永久显示：`vi /etc/vim/vimrc`，在最后一行加上`set nu`，保存后再次使用`vi`时就会显示行号了


![image-20200308000935928](https://gitee.com/NineHolic/cloudimage/raw/master/linux/image-20200308000935928.png)

##### 防火墙操作 firewall

```shell
# 查看 firewall 服务状态
systemctl status firewalld

# 查看 firewall 的状态
firewall-cmd --state

# 开启服务
service firewalld start

# 重启服务
service firewalld restart

# 关闭服务
service firewalld stop
```

****

![image-20200517215608126](https://gitee.com/NineHolic/cloudimage/raw/master/linux/image-20200517215608126.png)

```shell
# 查看防火墙规则
firewall-cmd --list-all 

# 查询端口是否开放
firewall-cmd --zone=public --query-port=80/tcp

# 开放 80 端口
firewall-cmd --zone=public --add-port=80/tcp --permanent

# 移除端口
firewall-cmd --zone=public --remove-port=80/tcp --permanent

#重启防火墙(修改配置后要重启防火墙)
firewall-cmd --reload

# 参数解释
1、firwall-cmd：是 Linux 提供的操作 firewall 的一个工具；
2、--zone=public：作用域
3、--add-port：标识添加的端口；
4、--permanent：设置永久；
```

##### 替换为 unix 格式换行（将 \r 替换成空）

脚本运行时出现问题

![image-20200314174432913](https://gitee.com/NineHolic/cloudimage/raw/master/linux/image-20200511013057229.png)

原因：在 window 下编写脚本然后在上传到 Linux 上时，由于 window 上换行显示的为 \r\n，然而在 linux 上换行显示应该为 \n，所以在 Linux 下无法读取从 window 上传来的脚本，将 \r 替换成空即可（ Mac 系统里，每行结尾是回车，即 \r ）

```shell
chmod +x color.sh
sed -i 's/\r$//' color.sh
```

#####  vi 编辑时启用数字小键盘

使用 vi 编辑文件时小键盘数字会变成字母，要恢复输入数字状态需要在 Xshell 中修改 VT 模式设为普通

![image-20200511013057229](https://gitee.com/NineHolic/cloudimage/raw/master/linux/image-20200314174432913.png)

##### 为普通用户添加 sudo 权限

```shell
# root 用户下执行
chmod u+w /etc/sudoers

# 默认新建的用户不在 sudo 组
vi /etc/sudoers

# 添加一行，默认 5 分钟后刚才输入的 sodo 密码过期，下次 sudo 需要重新输入密码
centos ALL=(ALL) ALL

# 加上 NOPASSWD 可以不用每次输入密码
centos ALL=(ALL)NOPASSWD: ALL
```

 ![image-20200316221703192](https://gitee.com/NineHolic/cloudimage/raw/master/linux/image-20200316221703192.png)

注意： 有的时候你的将用户设了 nopasswd，但是不起作用，原因是被后面的 group 的设置覆盖了，需要把 group的设置也改为 nopasswd

```shell
joe ALL=(ALL)NOPASSWD: ALL
%admin ALL=(ALL)NOPASSWD: ALL
```

##### 获取目录下的文件名

```shell
# 显示目录下的文件名，带后缀
find /home/oracle/impdir/ -name '*.DMP' -exec basename {} \;
```

![image-20200804172734220](https://gitee.com/NineHolic/cloudimage/raw/master/linux/image-20200804172734220.png)

```shell
# 显示目录下的文件名，不带后缀
for file_name in `ls /home/oracle/impdir/*.DMP`;do basename $file_name .DMP;done
```

![image-20200804172457866](https://gitee.com/NineHolic/cloudimage/raw/master/linux/image-20200804172457866.png)

##### Centos 永久关闭蜂鸣器

虚拟机安装 centos 后出现蜂鸣声

```shell
# root用户下执行
echo “rmmod pcspkr” >>/etc/rc.d/rc.local

# 添加执行权限后重启
chmod +x /etc/rc.d/rc.local
```
