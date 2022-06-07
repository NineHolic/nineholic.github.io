---
layout: post
title: Centos7 升级 OpenSSH
categories: OpenSSH
description: Centos7 下的 openssl、openssh 升级
keywords: Linux, Centos, OpenSSH
---

Centos7.6 升级后测试 ssh 登录及重启后 ssh 登录均无问题，升级无需卸载原先的 openssl 和 openssh

系统环境为服务器安装镜像时自带的 openssh，没有经历过手动编译安装方式

##### 1、升级准备

升级前版本

![image-20210818183950745](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20210818183950745.png)

升级后版本

![image-20210818210016091](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20210818210016091.png)

> **注意事项：**
>
> 升级前先关闭 selinux
>
> 使用 telnet 登录升级，备份ssh 相关文件，避免失败时无法回退版本
>
> 先在相同版本的测试环境进行升级，ssh 服务重启、服务器重启、su 切换用户等无问题后再到生产环境操作

先使用 yum 升级到目前 yum 仓库默认的 openssh7.4p1 版本，再进行编译安装升级到 openssh8.6p1

```shell
yum -y update openssh
```

![image-20210818191234569](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20210818191234569.png)

关闭 selinux：`vim /etc/selinux/config`，将`SELINUX=enforcing`改为`SELINUX=disabled`

重启服务器：`shutdown -r now`

##### 2、安装配置 telnet

防止SSH远程控制时，升级过程中出现连接中断，可通过telnet备用方式进行远程连接（由于telnet是明文传输，不安全，只作为临时使用，升级完成后，必须停止卸载该服务）

```shell
yum -y install xinetd telnet-server
```

修改配置文件：`vim /etc/xinetd.d/telnet`

```
# default: on
# # description: The telnet server serves telnet sessions; it uses \
# #   unencrypted username/password pairs for authentication.
service telnet
{
     disable     = yes
     flags       = REUSE
     socket_type = stream               
     wait        = no
     user        = root
     server      = /usr/sbin/in.telnetd
     log_on_failure  += USERID
}
```

配置 telnet 登录的终端类型：`vim /etc/securetty`，再文件末尾增加一些 pts 终端

```
pts/0
pts/1
pts/2
pts/3
```

设为开机自动启动

```shell
systemctl enable xinetd
systemctl enable telnet.socket
systemctl start telnet.socket
systemctl start xinetd

# 查看服务是否启动
netstat -lntp|grep 23
```

![image-20210819104413583](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20210819104413583.png)

测试 telnet 登录

![image-20210819104602717](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20210819104602717.png)

以下升级操作均在 telnet 终端下操作，防止 ssh 连接意外中断造成升级失败

##### 3、升级 openssl

```shell
# 安装依赖包
yum -y install gcc gcc-c++ glibc make autoconf openssl openssl-devel pcre-devel  pam-devel
yum -y install pam* zlib*

# 下载解压 openssl 包
wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz
tar -zxvf openssl-1.1.1g.tar.gz

# 备份 openssl (存在就备份)
mv /usr/bin/openssl /usr/bin/openssl_bak
mv /usr/include/openssl /usr/include/openssl_bak

# 编译安装 openssl
cd openssl-1.1.1g
./config --prefix=/usr/ --openssldir=/usr/ shared
make -j2 && make -j2 install

# 查看最后的命令 make install 是否有报错，0 表示无问题
echo $?

# 查看升级后的 openssl 版本
openssl version
```

![image-20210818192248033](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20210818192248033.png)

##### 4、升级 openssh

```shell
# 下载解压 openssh 包
wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.6p1.tar.gz
tar -zxvf openssh-8.6p1.tar.gz
chown -R root:root openssh-8.6p1

# 备份ssh
mv /etc/ssh /etc/ssh.bak
mv /usr/bin/ssh /usr/bin/ssh.bak
mv /usr/sbin/sshd /usr/sbin/sshd.bak

# 编译安装 openssh
cd openssh-8.6p1
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-ssl-dir=/usr/local/ssl --with-md5-passwords --with-pam --with-zlib --with-tcp-wrappers --without-hardening
make -j2 && make -j2 install

# 查看最后的命令 make install 是否有报错
echo $?

# 授权
chmod 600 /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_ed25519_key

# 从原先的解压的包中拷贝一些文件到目标位置
cp -a contrib/redhat/sshd.init  /etc/init.d/sshd
cp -a contrib/redhat/sshd.pam /etc/pam.d/sshd.pam
chmod u+x /etc/init.d/sshd

# 将原先 systemd 管理的 sshd 文件删除或者移走，否则会影响重启 sshd 服务
mv /usr/lib/systemd/system/sshd.service /usr/lib/systemd/system/sshd.service.bak

# 修改 ssh 配置
vim /etc/ssh/sshd_config

UseDNS no
UsePAM yes
PermitRootLogin yes
PasswordAuthentication yes

# 设置开机自启
chkconfig --add sshd
chkconfig sshd on

# 重启 ssh 服务
systemctl daemon-reload
systemctl restart sshd

# 查看 ssh 状态
systemctl status sshd.service

# 查看升级后的 openssh 版本
ssh -V
```

![image-20210818210216061](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20210818210216061.png)

使用 systemd 方式测试

```shell
netstat -lntp
systemctl stop sshd
netstat -lntp
systemctl start sshd
netstat -lntp
systemctl restart sshd
netstat -lntp
```

![image-20210818195309024](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20210818195309024.png)

telnet 测试

![image-20210819091246218](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20210819091246218.png)

重启后再次测试均无问题，关闭 telnet

```shell
systemctl disable xinetd.service
systemctl stop xinetd.service
systemctl disable telnet.socket
systemctl stop telnet.socket
netstat -lntp
```

##### 5、版本回退

```shell
rm -rf /etc/ssh
mv /etc/ssh.bak /etc/ssh
mv /usr/bin/ssh.bak /usr/bin/ssh
mv /usr/sbin/sshd.bak /usr/sbin/sshd
systemctl restart sshd
ssh -V
```
回退后注意验证ssh登录是否正常

![image-20210819102454585](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20210819102454585.png)
