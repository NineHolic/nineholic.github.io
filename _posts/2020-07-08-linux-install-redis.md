---
layout: post
title: Redis 的安装与使用
categories: [Redis]
description: Redis 的安装与使用
keywords: Redis, Linux, Centos, DB
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

Linux 下编译安装 Redis 以及使用脚本安装。

##### 1、编译安装

```shell
# 下载
wget http://download.redis.io/releases/redis-7.0.4.tar.gz

# 解压文件
tar -zxvf redis-7.0.4.tar.gz && cd redis-7.0.4/src
mkdir -p /data/redis/{etc,logs,pid,} && mkdir -p /data/redis/bin/6379

# 安装依赖
yum -y install gcc gcc-c++ tcl

# 编译 redis 源码，无报错即可
make -j2

# 安装到指定目录
make -j2 install PREFIX=/data/redis
```

##### 2、配置修改

```bash
# 复制配置文件到安装目录下
cd .. && cp redis.conf /data/redis/etc/redis-6379.conf

# 修改配置文件
vim /data/redis/etc/redis-6379.conf

# 后台启动 redis
daemonize yes

# 端口
port 6379

# 绑定地址，默认是 127.0.0.1 表示只能通过本机访问，修改为 0.0.0.0 为任意 IP 均可访问
bind 0.0.0.0

# redis 密码
requirepass redis1234!

# 开启 AOF 持久化
appendonly yes
appendfilename appendonly-6379.aof

# 持久化文件存放目录
dir /data/redis/etc/

# 日志
logfile /data/redis/logs/redis-6379.log

# pid 保护目录
pidfile /data/redis/run/redis_6379.pid
```

```shell
# 创建软连接，让 redis-server、redis-cli 可以在任意目录下直接使用
ln -s /data/redis/bin/redis-server /usr/local/bin/
ln -s /data/redis/bin/redis-cli /usr/local/bin/

# 启动 redis
redis-server /data/redis/etc/redis-6379.conf

# 开放 6379 端口
firewall-cmd --zone=public --add-port=6379/tcp --permanent
firewall-cmd --reload
```

##### 3、开机自启

**方法一**

```shell
# 在 /etc/rc.local 末尾添加一行内容
echo '/data/redis/bin/redis-server /data/redis/etc/redis-6379.conf' >> /etc/rc.d/rc.local

# 添加执行权限
chmod +x /etc/rc.d/rc.local
```

**方法二**

添加启动文件：`vim /lib/systemd/system/redis.service`，写入以下配置

```ini
[Unit]
Description=The redis-server Process Manager
Documentation=https://redis.io/
After=network.target
[Service]
Type=forking
ExecStart=/data/redis/bin/redis-server /data/redis/etc/redis-6379.conf
# 有密码则需要在 redis-cli 后面加 -a "密码"
ExecStop=/data/redis/bin/redis-cli -a "1234" shutdown 
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

##### 4、配置优化

- **高并发场景**：如果 Redis 的并发连接数较高，较小的 `somaxconn` 会导致连接队列快速填满，新连接可能被拒绝。
- **性能优化**：增大 `somaxconn` 可以提升 Redis 处理突发连接的能力。

```bash
# 当前 TCP 连接队列的最大长度（默认 128）
cat /proc/sys/net/core/somaxconn

# 临时修改 somaxconn（立即生效），将 somaxconn 设置为 1024（或大于 Redis 的 tcp-backlog 值）
sudo sysctl -w net.core.somaxconn=1024

# 添加或修改以下行（重启后仍有效）
vim /etc/sysctl.conf

net.core.somaxconn = 1024

# 加载配置
sysctl -p

# 验证是否生效
cat /proc/sys/net/core/somaxconn
```

> `tcp-backlog`：Redis 配置参数，定义 TCP 连接队列的最大长度（默认 511）。
>
> `somaxconn`：Linux 内核参数，定义系统全局的 TCP 连接队列最大长度（默认通常为 128）
>
> 当 Redis 的 `tcp-backlog` 大于系统的 `somaxconn` 时，实际生效的值会是两者中的较小值（即 `somaxconn` 的 128）

Linux 的 `overcommit_memory` 参数控制内核的内存分配策略：

- `0` (默认值)：保守模式，内核会检查可用内存是否足够，如果不足则拒绝分配（可能导致 Redis 的 `BGSAVE` 或 `BGREWRITEAOF` 失败）。
- `1`：激进模式，总是允许分配，即使内存不足（由 OOM Killer 处理溢出）。
- `2`：折中模式，分配不超过 `交换空间 + 物理内存 * overcommit_ratio`。

Redis 建议设置为 `1`，以确保后台持久化操作不会被内核拒绝。

```bash
# 查看内存分配策略，默认为 0
cat /proc/sys/vm/overcommit_memory

# 立即将 overcommit_memory 设为 1
sysctl vm.overcommit_memory=1

# 编辑 sysctl 配置文件
vim /etc/sysctl.conf

# 在文件末尾添加
vm.overcommit_memory = 1

# 加载配置（无需重启）
sysctl -p

# 验证是否生效
cat /proc/sys/vm/overcommit_memory
```

##### 5、报错处理

make 时，发生以下错误，使用`make MALLOC=libc`执行

![image-20201123153608469](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20201123153608469.png)

