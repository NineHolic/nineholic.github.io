---
layout: post
title: MySQL 的安装与使用
categories: [MySQL]
description: MySQL 安装与使用
keywords: MySQL, Linux, Centos, DB
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

使用离线包方式安装 MySQL。

##### 1、下载 MySQL

官网：[https://downloads.mysql.com/archives/community/](https://downloads.mysql.com/archives/community/)，本机为 Centos 7.7

![image-20211017190131138](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/mysql/image-20211017190131138.png)

```shell
# 下载安装包
wget https://cdn.mysql.com/archives/mysql-8.0/mysql-8.0.34-linux-glibc2.12-x86_64.tar.xz

# 查看系统自带的 Mariadb
rpm -qa | grep mariadb

# 卸载系统自带的 Mariadb
rpm -e --nodeps mariadb-libs-5.5.64-1.el7.x86_64

# 查看是否安装过 MySQL，删除相关目录和配置文件
rpm -qa | grep mysql

# 安装依赖
yum install libaio
```

##### 2、环境配置

```shell
# 解压
tar -xvf mysql-8.0.34-linux-glibc2.12-x86_64.tar.xz -C /data
mv /data/mysql-8.0.34-linux-glibc2.12-x86_64 /data/mysql

# 创建数据目录，修改目录权限
mkdir -p /data/mysql/{data,conf,run,log}
chmod 750 /data/mysql/data

# 创建 mysql 组
groupadd mysql

# 创建 mysql 用户，使用 -g 参数指定组，-r 参数表示 mysql 用户是系统用户，不可用于登录系统
useradd -r -g mysql mysql

# 修改 mysql 的用户和组
chown -R mysql:mysql /data/mysql

# 配置环境变量
echo 'export PATH=$PATH:/data/mysql/bin' >> /etc/profile
source /etc/profile
```

创建配置文件：`vim /etc/my.cnf`

```ini
[mysql]
# 设置 MySQL 客户端默认字符集
default-character-set=utf8
socket=/data/mysql/run/mysql.sock

[mysqld]
port=3306
socket=/data/mysql/run/mysql.sock
pid-file=/data/mysql/run/mysql.pid

mysqlx_port = 33060
mysqlx_socket=/data/mysql/run/mysqlx.sock

# 设置时区
default-time-zone='+8:00'
log_timestamps = SYSTEM

# 设置 MySQL 的安装目录、数据目录
basedir=/data/mysql
datadir=/data/mysql/data

# 允许最大连接数
max_connections=2000

# 默认数据库字符集
character-set-server=utf8mb4
collation-server = utf8mb4_unicode_ci
init_connect = 'SET NAMES utf8mb4'

# 创建新表时将使用的默认存储引擎
default-storage-engine=INNODB

# MYSQL 大小写不敏感
lower_case_table_names=1
max_allowed_packet=16M
default-authentication-plugin=caching_sha2_password
innodb_file_per_table=1

# InnoDB 核心参数
innodb_buffer_pool_size=1G
innodb_buffer_pool_instances=8
innodb_redo_log_capacity=2G
innodb_log_buffer_size=32M

# 日志
log_error=/data/mysql/log/mysql-error.log
slow_query_log=1
slow_query_log_file=/data/mysql/log/slow-query.log
long_query_time=2
log_queries_not_using_indexes=1
log_throttle_queries_not_using_indexes=60

# 跳过 DNS 反向解析
skip-name-resolve=1
```

##### 3、安装 MySQL

```shell
# 初始化 mysqld
/data/mysql/bin/mysqld --initialize --user=mysql

# 查看临时密码和日志是否有报错
cat /data/mysql/log/mysql-error.log

# 启动 MySQL
/data/mysql/support-files/mysql.server start

# 登录 MySQL
mysql -u root -p
```

> 此处登录 MySQL 可能会报错：mysql: error while loading shared libraries: libtinfo.so.5: cannot open shared object file: No such file or directory
>
> 执行此命令修复：`ln -s /usr/lib64/libtinfo.so.6.1 /usr/lib64/libtinfo.so.5`

```mysql
# 修改 root 用户密码
ALTER USER 'root'@'localhost' IDENTIFIED BY 'mysql1234!';

# 对指定 ip 段开放 root 用户远程连接权限
use mysql;
UPDATE user SET user.Host='192.168.216.%' WHERE user.User='root';
FLUSH PRIVILEGES;

# 查询已有用户
SELECT Host, User FROM mysql.user;

# 删除远程登录用户
DELETE FROM USER WHERE User='root' and Host='%';
```

##### 4、配置开机自启

```shell
# 开放端口
firewall-cmd --zone=public --permanent --add-port=3306/tcp
firewall-cmd --reload

# 将 mysql.server 复制到 /etc/init.d 下面
cp /data/mysql/support-files/mysql.server /etc/init.d/mysqld

# 通过 chkconfig 将 mysql 服务添加到开机启动的列表
chkconfig --add mysqld

# 重启 mysql
systemctl restart mysqld
```

