---
layout: post
title: PostgreSQL 的安装与使用
categories: [PostgreSQL]
description: PostgreSQL 的安装与使用
keywords: PostgreSQL, Linux, Centos, DB
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

服务器系统版本为 centos 7.7。

#### 1、软件安装

选择其中 1 种方式安装即可

##### (1)、yum 安装

官方说明：[https://www.postgresql.org/download/linux/redhat/](https://www.postgresql.org/download/linux/redhat/)

```bash
# 安装 PostgreSQL 软件仓库
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# 查询支持的版本
yum -y search 'PostgreSQL client programs'

# 安装 PostgreSQL，默认安装目录：/var/lib/
yum install -y postgresql15-server

# 初始化数据库
/usr/pgsql-15/bin/postgresql-15-setup initdb

# 按需修改数据库配置文件
vim /var/lib/pgsql/15/data/postgresql.conf

listen_addresses = '*'
max_connections = 200

logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_file_mode = 0644
log_line_prefix = '%m %u %d %p %r %e'
log_statement = 'ddl'

# 设置开机自启
systemctl enable postgresql-15

# 启动数据库
systemctl start postgresql-15

# 开放防火墙端口
firewall-cmd --add-port=5432/tcp --permanent
firewall-cmd --reload
```

##### (2)、源码安装

源码安装包：[https://www.postgresql.org/ftp/source](https://www.postgresql.org/ftp/source)

```bash
# 安装依赖
yum install -y gcc gcc-c++ make libicu-devel bison flex readline-devel zlib-devel wget vim

# 下载解压安装包
wget https://ftp.postgresql.org/pub/source/v17.6/postgresql-17.6.tar.gz
tar -zxvf postgresql-17.6.tar.gz && cd postgresql-17.6
./configure --prefix=/usr/local/pgsql
make -j2 && make -j2 install

# 添加用户并创建数据目录
useradd postgres
mkdir -p /data/pgsql/data
chown -R postgres:postgres /data/pgsql/data
chown -R postgres:postgres /usr/local/pgsql

# 配置环境变量
cat >> /etc/profile << "EOF"
# postgresql
export PGHOME=/usr/local/pgsql
export PGDATA=/data/pgsql/data
export PATH=$PGHOME/bin:$PATH
EOF

# 使环境变量生效
source /etc/profile

# 初始化数据库
su - postgres
/usr/local/pgsql/bin/initdb -D /data/pgsql/data

# 修改数据库配置文件
vim /data/pgsql/data/postgresql.conf

listen_addresses = '*'
max_connections = 4000

shared_buffers = 4GB
work_mem = 64MB
maintenance_work_mem = 1GB
effective_cache_size = 12GB
wal_buffers = 16MB
checkpoint_completion_target = 0.9

logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_file_mode = 0644
log_line_prefix = '%m %u %d %p %r %e'
log_statement = 'ddl'

# 启动服务
/usr/local/pgsql/bin/pg_ctl -D /data/pgsql/data start

# 复制源码包里的启动脚本至 /etc/init.d 目录下，并加执行权限
cp postgresql-17.6/contrib/start-scripts/linux /etc/init.d/postgresql
chmod +x /etc/init.d/postgresql

# 修改数据目录
sed -i 's|^PGDATA=.*|PGDATA="/data/pgsql/data"|' /etc/init.d/postgresql

# 设置开机启动
chkconfig --add postgresql

# 启动服务
systemctl start postgresql

# 服务状态
systemctl status postgresql

# 重启数据库
/usr/local/pgsql/bin/pg_ctl -D /data/pgsql/data rstart

# 开放防火墙端口
firewall-cmd --add-port=5432/tcp --permanent
firewall-cmd --reload
```

> `listen_addresses`：* 为允许服务器监听所有可用的网络接口，允许远程连接
>
> `max_connections`：决定允许的最大数据库连接数。过多的连接会增加系统开销和资源竞争。通常可以使用连接池工具（如 PgBouncer）来控制并发连接数；
>
> `shared_buffers`：这是 PostgreSQL 用于缓存表数据的共享内存区域，通常建议设置为物理内存的 25%-40%。如果设置过低，会导致频繁的磁盘访问；设置过高则会占用操作系统内存，减少可用的文件缓存；
>
> `work_mem`：每个查询操作（如排序、哈希表）所使用的内存。这个参数是每个查询连接单独分配的，因此需要根据查询复杂度和并发量合理设置。如果过小，查询需要频繁进行磁盘交换；过大会导致内存不足。典型值在 10MB-100MB 之间；
>
> `maintenance_work_mem`：控制 PostgreSQL 在执行维护操作时使用的内存大小，比如创建索引、VACUUM。推荐设置为较大的值，尤其是在大规模数据集上操作时；
>
> `effective_cache_size`：PostgreSQL 根据此参数判断系统可用的文件系统缓存大小，从而决定是否使用索引扫描或全表扫描。建议设置为物理内存的 50%-75%；
>
> `wal_buffers`：建议设置为 shared_buffers 的 1/32，用于缓冲 WAL 数据，避免频繁写入磁盘； 
>
> `checkpoint_completion_target`：设置为接近 1 的值可以平滑 WAL 日志写入压力，减少突发I/O 操作。
>
> `logging_collector`：开启日志收集器，用于收集数据库服务器的日志信息
>
> `log_directory`：日志文件的存储目录为 pg_log
>
> `log_filename`：日志文件名包含月份和日期信息
>
> `log_file_mode`：日志文件权限
>
> `log_line_prefix`：日志行前缀（%m 时间，%u 用户名称，%d 数据库名称，%r 客户端 IP 和端口，%e sql 语句）
>
> `log_statement`：none、ddl、mod、all 控制记录哪些 SQL 语句。none 不记录，ddl 记录所有数据定义命令，比如 CREATE、ALTER、DROP 语句。mod 记录所有 ddl 语句,加上数据修改语句INSERT、UPDATE 等，all 记录所有执行的语句，将此配置设置为 all 可跟踪整个数据库执行的 SQL 语句

#### 2、密码修改

安装完成后修改数据库密码并配置密码认证

```bash
# 数据库密码修改
su - postgres
psql
alter user postgres with password 'pgsqlabcd!';

# 创建用户
CREATE USER testuser with password 'pgsqlabcd!';

# 增加允许连接的 ip 地址，0.0.0.0/0 表示任意地址，192.168.1.11/32 表示仅允许 192.168.1.11 连接
vim $PGDATA/pg_hba.conf

host    all             all             0.0.0.0/0               scram-sha-256
host    all             all             192.168.1.11/32         scram-sha-256

# 根据 postgresql.conf 中的 shared-buffers 值计算需要的大页数量
/usr/local/pgsql/bin/postgres -D $PGDATA --shared-buffers=12GB --huge-pages=on -C shared_buffers

# 修改系统配置
vim /etc/sysctl.conf
vm.nr_hugepages = 6146

# 使之生效
sysctl -p

# 检查大页是否分配成功
cat /proc/meminfo | grep Huge

# 重启数据库（yum 安装方式）
systemctl restart postgresql-15

# 重启数据库（源码安装方式）
systemctl restart postgresql
```

> 在传统的操作系统内存管理中，内存被划分为许多小块，通常每块是 **4KB**（这个值取决于架构，x86_64 默认是 4KB），这被称为“基础页”。
>
> **问题：** 当一个像 PostgreSQL 这样需要大量内存的进程（例如，`shared_buffers` 设置为几十GB）运行时，它需要管理成千上万甚至数百万个这些 4KB 的小页面。这会导致：
>
> - **更高的 CPU 开销：** 操作系统需要维护更多的页表项（Page Table Entries）。
> - **更高的 TLB 压力：** TLB（Translation Lookaside Buffer）是 CPU 中的一个高速缓存，用于快速将虚拟地址转换为物理地址。TLB 容量很小，如果进程需要频繁访问大量分散的 4KB 页面，会导致 TLB 缓存未命中（TLB miss），CPU 就不得不去访问更慢的主内存来查找地址转换关系，这会显著降低性能。
>
> **解决方案：大页（Huge Pages）**
> - 大页是另一种内存页大小，通常是 **2MB** 或 **1GB**（相比之下，基础页是 4KB）。
> - 通过使用 2MB 的大页，同样管理 16GB 的内存，操作系统只需要处理 `16GB / 2MB = 8192` 个页表项，而不是 `16GB / 4KB = 4,194,304` 个。这减少了超过 99% 的页表项数量！
> - TLB 可以缓存更多的地址转换关系，从而极大减少 TLB miss，提高内存访问效率。

