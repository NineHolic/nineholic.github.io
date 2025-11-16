---
layout: post
title: Redis 的安装与使用
categories: [DB]
description: Redis 的安装与使用
keywords: Redis, Linux, Centos
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

Linux 下编译安装 Redis 以及使用脚本安装

##### 1、编译安装 Redis

```shell
# 下载解压文件
wget http://download.redis.io/releases/redis-5.0.7.tar.gz
tar -zxvf redis-5.0.7.tar.gz

# 安装依赖
yum -y install gcc gcc-c++ tcl

# 编译 redis6.x 需要高版本的 gcc
yum -y install centos-release-scl
yum -y install devtoolset-9-gcc devtoolset-9-gcc-c++ devtoolset-9-binutils
source /opt/rh/devtoolset-9/enable
echo "source /opt/rh/devtoolset-9/enable" >>/etc/profile
gcc --version

# 编译 redis 源码
cd redis-5.0.7
make -j2

# 安装到指定目录
cd src
make -j2 install PREFIX=/usr/local/redis
```

![image-20200708175841687](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20200708174648619.png)

##### 2、配置 redis

```shell
# 移动配置文件到安装目录下
mkdir /usr/local/redis/etc
mv ../redis.conf /usr/local/redis/etc
```

修改配置文件：`vim /usr/local/redis/etc/redis.conf`

```ini
# 配置 redis 为后台启动
# 将 daemonize no 改成 daemonize yes
# 在 bind 127.0.0.1 后添加本机 ip 供局域网访问
# 将 requirepass foobared 改为 requirepass 1234，1234 为 redis 密码
```

![image-20200708174648619](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20200708175841687.png)![image-20200708175529165](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20200708182146625.png)![image-20200708182146625](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20200708175529165.png)

```shell
# 创建软连接，让 redis-server、redis-cli 可以在任意目录下直接使用
ln -s /usr/local/redis/bin/redis-server /usr/local/bin/
ln -s /usr/local/redis/bin/redis-cli /usr/local/bin/

# 启动 redis
redis-server /usr/local/redis/etc/redis.conf

# 开放6379端口，重启防火墙
firewall-cmd --zone=public --add-port=6379/tcp --permanent
systemctl restart firewalld
```

##### 3、设置开机自启

- **方法一**

```shell
# 在 /etc/rc.local 末尾添加一行内容
echo '/usr/local/redis/bin/redis-server /usr/local/redis/etc/redis.conf' >> /etc/rc.d/rc.local

# 添加执行权限
chmod +x /etc/rc.d/rc.local
```

- **方法二**

添加启动文件：`vim /lib/systemd/system/redis.service`，写入以下配置

```ini
[Unit]
Description=The redis-server Process Manager
Documentation=https://redis.io/
After=network.target
[Service]
Type=forking
ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/etc/redis.conf
# 有密码则需要在 redis-cli 后面加 -a "密码"
ExecStop=/usr/local/redis/bin/redis-cli -a "1234" shutdown 
[Install]
WantedBy=multi-user.target
```

```shell
# 设置开机自启动
systemctl enable redis

# 开启服务
systemctl start redis

# 停止服务
systemctl stop redis

# 查看运行状态
systemctl status redis
```

##### 可能遇到的问题：

make 时，发生以下错误，使用`make MALLOC=libc`执行

![image-20201123153608469](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20201123153608469.png)

