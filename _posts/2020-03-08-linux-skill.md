---
layout: post
title: Linux 使用技巧
categories: [Linux]
description: Linux 使用技巧
keywords: Linux, Centos, Ubuntu
topmost: true
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

工作、学习期间陆续记录的 Linux 使用技巧。

##### 更换 yum 源

```bash
# 备份现有源
cp -r /etc/yum.repos.d /etc/yum.repos.d.bak

# Centos 7 阿里云
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo && curl -o /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo

# Centos 7 华为云
curl -o /etc/yum.repos.d/CentOS-Base.repo https://repo.huaweicloud.com/repository/conf/CentOS-7-anon.repo

# Centos 8
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# 清理缓存
yum clean all && yum makecache
```

##### 更换 apt 源

```bash
# 备份现有源
cp -r /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak

# Ubuntu 24.04 版本更换源的方式有所变化，不再使用 sources.list 文件，而是改为使用 /etc/apt/sources.list.d/ubuntu.sources 配置文件
sed -i 's@//.*archive.ubuntu.com@//mirrors.aliyun.com@g' /etc/apt/sources.list.d/ubuntu.sources && sed -i 's@//.*security.ubuntu.com@//mirrors.aliyun.com@g' /etc/apt/sources.list.d/ubuntu.sources && apt update

# 系统低于 Ubuntu 24.04 版本
sed -i 's@//.*archive.ubuntu.com@//mirrors.aliyun.com@g' /etc/apt/sources.list && sed -i 's@//.*security.ubuntu.com@//mirrors.aliyun.com@g' /etc/apt/sources.list && apt update
```

##### 查看系统版本

```bash
# 查看版本
cat /etc/*-release

# 综合信息查看
hostnamectl

# 查看内核详细信息
cat /proc/version

# 查看完整系统信息
uname -a

# 查看系统位数
getconf LONG_BIT
```

##### 常用软件安装

rpm 包下载：[https://rpmfind.net/linux/rpm2html/](https://rpmfind.net/linux/rpm2html/)

```bash
yum -y install gcc gcc-c++ make lsof tcpdump vim lrzsz wget net-tools telnet unzip screen

apt -y install lrzsz screenfetch
```

##### 用户名高亮显示

配置完成后重新登录生效（终端需支持彩色输出）

```bash
# 执行配置脚本
curl -s https://raw.githubusercontent.com/NineHolic/script/master/linux/setcolor.sh | bash

# 或者执行以下命令
cat >> ~/.bashrc << "EOF"

force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
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
EOF
```

![image-20251119171050930](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20251119171050930.png)

##### 网速测试

```bash
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh | sudo bash
yum -y install speedtest
speedtest
```

##### 域名无法 ping 通

添加 DNS 服务器 IP 地址：`cat /etc/resolv.conf`

默认 resolv.conf 内容是按照网卡设置的 DNS 内容自动生成，若要使直接修改的 DNS 内容不会在服务器重启之后丢失，需要设置网卡中 NM_CONTROLLED 的值为 no

```bash
# 修改网卡设置：是否允许 Network Manager 管理，设置为 no，
echo 'NM_CONTROLLED="no"' >> /etc/sysconfig/network-scripts/ifcfg-ens33

# 重启网卡
service network restart

# 阿里 DNS
echo "nameserver 223.5.5.5" >> /etc/resolv.conf
echo "nameserver 223.6.6.6" >> /etc/resolv.conf

# 腾讯DNS
echo "nameserver 119.29.29.29" >> /etc/resolv.conf

# 百度DNS
echo "nameserver 180.76.76.76" >> /etc/resolv.conf

# 一般修改完 reolv.conf 后就能 ping 通了，否则再重启网络
nmcli c reload
```

##### 修改主机名称

```bash
# 修改后重新登录，若 /etc/hosts 有主机名称映射应手动修改
hostnamectl set-hostname nine-test
```

##### 设置静态IP

```bash
# 查看当前网卡名称
ip a

# 修改配置文件,BOOTPROTO 改为 static，ONBOOT 改为yes，IPADDR 为 NAT 模式中子网 ip 同一网段 ip，GATEWAY、NETMASK、DNS1 分别设置为 NAT 模式中的网关 ip、子网掩码、网关 ip
vi /etc/sysconfig/network-scripts/ifcfg-ens33

IPADDR="192.168.216.131"
GATEWAY="192.168.216.2"
NETMASK="255.255.255.0"
DNS1="192.168.216.2"

# 重启网络服务
service network restart
```

##### 临时修改网卡名称

```bash
# 将网卡关闭
ip link set ens160 down
 
# 临时更改网卡名称，服务器重启后网卡名称会还原
ip link set ens160 name eth0
 
# 将网卡打开
ip link set eth0 up
```

##### 永久修改网卡名称

```bash
# 编辑 GRUB 配置文件，禁用默认的网卡命名规则
vim /etc/default/grub

# 在 GRUB_CMDLINE_LINUX 行中添加以下参数，修改 GRUB 配置时，确保语法正确，否则可能导致系统无法启动
net.ifnames=0 biosdevname=0

# 修改网卡配置文件，将 NAME 和 DEVICE 字段改为新名称
cd /etc/sysconfig/network-scripts/
mv ifcfg-ens33 ifcfg-eth0
vim ifcfg-eth0

# 判断操作系统是基于 UEFI 模式引导的系统还是基于 BIOS 引导的系统
[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS

# 基于 UEFI 模式引导的系统，目录 redhat 有的为 centos
grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
 
# 基于 BIOS 模式引导的系统 
grub2-mkconfig -o /boot/grub2/grub.cfg

# 重启服务器
reboot

# 查看网卡信息
ip a
```

![image-20250728145315278](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20250728145315278.png)

##### 修改ssh端口号

```bash
# 将默认的 22 端口改为 22333 端口
vim /etc/ssh/sshd_config

# 重启 ssh，此时另起 xshell 窗口使用 22333 端口测试连接，防止修改失败连不上
systemctl restart sshd
```

##### ssh 登陆慢

将 UseDNS 配置为 yes 会导致登陆慢，原因是在登陆的过程中服务端会发送四次反向域名解析的请求，每次请求相隔 5s，共 20s，反映在登陆过程中就是卡了几十秒。ssh 中该配置主要用于安全加固，服务器会先根据客户端的 IP地址进行 DNS PTR反向查询出客户端的主机名，然后根据查询出的客户端主机名进行DNS正向A记录查询，并验证是否与原始IP地址一致，通过此种措施来防止客户端欺骗。

```bash
# 关闭反向 DNS 解析功能
sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config

# 重启 ssh 服务
systemctl restart sshd
```

##### 历史命令数量修改

```bash
# 保存 1 万条历史命令
sed -i 's/^HISTSIZE=.*/HISTSIZE=10000/g' /etc/profile
```

##### 配置开机自启

```bash
# 指定用户服务开启自启
su - guest -c "/data/redis/bin/redis-server /data/redis/etc/redis-6379.conf"
su - guest -c "/data/tomcat/apache-tomcat-8.5.88/bin/startup.sh"
su - guest -c "nohup java -jar /data/admin.jar --spring.profiles.active=test >> /data/nohup.out 2>&1 &"
```

##### 为普通用户添加 sudo 权限

```bash
# root 用户下执行
chmod u+w /etc/sudoers

# 默认新建的用户不在 sudo 组
vi /etc/sudoers

# 添加一行，默认 5 分钟后刚才输入的 sodo 密码过期，下次 sudo 需要重新输入密码
centos ALL=(ALL) ALL

# 加上 NOPASSWD 可以不用每次输入密码
centos ALL=(ALL)NOPASSWD: ALL

# 普通用户有 sudo 权限后切换到 root 下
sudo -i
```

 注意： 有的时候你的将用户设了 nopasswd，但是不起作用，原因是被后面的 group 的设置覆盖了，需要把group 的设置也改为 nopasswd

```bash
joe ALL=(ALL)NOPASSWD: ALL
%admin ALL=(ALL)NOPASSWD: ALL
```

```bash
# 查询特权用户特权用户(uid 为0)
awk -F: '$3==0{print $1}' /etc/passwd

# 查询可以远程登录的帐号信息
awk '/\$1|\$6/{print $1}' /etc/shadow

# 除 root 帐号外，其他帐号是否存在 sudo 权限
more /etc/sudoers | grep -v "^#\|^$" | grep "ALL=(ALL)"

# 禁用帐号，帐号无法登录，/etc/shadow 第二栏为 ! 开头
usermod -L user

# 删除 user 用户
userdel user

# 将删除user用户，并且将 /home 目录下的 user 目录一并删除
userdel -r user
```

##### 修改 umask 值

`umask`用于设置用户创建文件或者目录的默认权限，root 的`umask`为 0022，普通用户的默认`umask`为 0002

对于文件和目录来说， 最大的权限其实都是 777，但是执行权限对于文件来说，不是必要权限，而对目录来说执行权限是个基本权限。所以默认目录的最大权限是 777，而文件的默认最大权限就是 666。

```bash
# 查看
umask

# 临时修改
umask 0022

# 永久修改
echo 'umask=022' >> /etc/bashrc
```

> 对于目录，直接使用 777-umask 即可，就得到了最终结果
>
> 对于文件，先使用 666-umask
>
> 如果对应位上为偶数：最终权限就是这个偶数值，如果上面的对应为上有奇数，就对应位+1。

##### 修改系统和进程的 Max open files

```bash
# 修改/etc/security/limits.conf，此设置对 system services 不生效，只对通过 PAM 登录的用户生效
cat >> /etc/security/limits.conf << "EOF"
* soft nproc 102400
* hard nproc 102400
* soft nofile 655350
* hard nofile 655350
EOF

# 修改系统总限制
echo "fs.file-max = 655350" >> /etc/sysctl.conf
sysctl -p

# 对于 systemd service 的资源设置，需修改全局配置
sed -i 's/#DefaultLimitNOFILE=/DefaultLimitNOFILE=655350/' /etc/systemd/system.conf && sed -i 's/#DefaultLimitNPROC=/DefaultLimitNPROC=102400/' /etc/systemd/system.conf && sed -i 's/#DefaultLimitNOFILE=/DefaultLimitNOFILE=655350/' /etc/systemd/user.conf && sed -i 's/#DefaultLimitNPROC=/DefaultLimitNPROC=102400/' /etc/systemd/user.conf
```

> `hard`硬限制是可以在任何时候任何进程中设置 但硬限制只能由超级用户修改
>
> `soft`软限制是内核实际执行的限制，任何进程都可以将软限制设置为任意小于等于对进程限制的硬限制的值
>
> `noproc`进程的最大数目，`nofile`打开文件的最大数目

##### 禁用系统 openjdk

```bash
# 查看 openjdk 的路径
alternatives --config java

# ARM 架构位置
/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.232.b09-0.el7_7.aarch64/jre/bin/java

# X86 架构位置
/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.171-2.6.13.2.el7.x86_64/jre/bin/java

# 不必真的删除 openjdk，解除 openjdk 的链接配置后自己安装的 jdk 就行
alternatives --remove java /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.232.b09-0.el7_7.aarch64/jre/bin/java

# 彻底删除，使用 java -version 查看是否删除成功
rm -rf java-1.8.0-openjdk-1.8.0.232.b09-0.el7_7.aarch64
```

##### 添加中文字体

```bash
# 查看当前字体
fc-list

# fc-list 未找到命令时，先安装字体软件
yum install -y fontconfig mkfontscale

# 上传中文字体，解压后刷新字体缓存，注意权限需要让其它用户可读
mkdir /usr/share/fonts/chinese && chmod 755 /usr/share/fonts/chinese
unzip chinese.zip -d /usr/share/fonts
chmod 644 /usr/share/fonts/chinese/*.tt*
fc-cache -fv
```

##### Pgrep 无法获取部分进程 pid

```bash
# 结果为空，增加参数 -f 才可获取到
pgrep code-6609ac3d66f4eade5cf376d1cb76f13985724bcb
pgrep -f code-6609ac3d66f4eade5cf376d1cb76f13985724bcb

# 查看实际进程名，结果中 Name: code-6609ac3d66
cat /proc/27078/status
```

> 查看帮助信息：`man pgrep`，可以看到 pgrep 默认只能匹配进程的前 15 个字符
>
> NOTES
>     The process name used for matching is limited to the 15 characters present in the output of /proc/pid/stat.  Use the -f option to match against the complete command line, /proc/pid/cmdline.

##### VI/VIM 显示行号

临时显示，`vi`命令执行后输入：`：set nu`

永久显示：`vi /etc/vim/vimrc`，在最后一行加上`set nu`，保存，再次使用`vi`时就会显示行号

##### 防火墙操作firewall

```bash
# 查看状态
systemctl status firewalld
firewall-cmd --state

# 开启服务
systemctl start firewalld
service firewalld start

# 重启服务
systemctl restart firewalld
service firewalld restart

# 关闭服务
systemctl stop firewalld
service firewalld stop

# 查看防火墙规则
firewall-cmd --list-all 

# 查询端口是否开放
firewall-cmd --zone=public --query-port=8080/tcp

# 开放80端口
firewall-cmd --zone=public --add-port=80/tcp --permanent

# 移除端口
firewall-cmd --zone=public --remove-port=8080/tcp --permanent

#重启防火墙(修改配置后要重启防火墙)
firewall-cmd --reload
```

> `firwall-cmd`：是 Linux 提供的操作 firewall 的一个工具
> `--zone=public`：作用域
> `--add-port`：标识添加的端口
> `--permanent`：设置永久

##### 将 \r 替换成空

脚本运行时出现问题

![image-20200314174432913](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20200511013057229.png)

原因：在 window 下编写脚本然后在上传到 Linux 上时，由于 window 上换行显示的为 \n\r，然而在 linux上换行显示应该为 \n，所以在 Linux 下无法读取从 window 上传来的脚本，将 \r 替换成空即可

```bash
sed -i 's/\r$//' test.sh
```

##### 启用 vi 编辑时数字小键盘

使用 vi 编辑文件时小键盘数字会变成字母，要恢复输入数字状态需要在 Xshell 中修改 VT 模式设为普通

![image-20200511013057229](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20200314174432913.png)

##### Centos 永久关闭蜂鸣器

在 VMware 软件中操作时会有蜂鸣声

```bash
# root 用户下执行
rmmod pcspkr && echo "rmmod pcspkr" >>/etc/rc.d/rc.local
```











