---
layout: post
title: pgAdmin4 的安装与使用
categories: [PostgreSQL]
description: pgAdmin4 的安装与使用
keywords: pgAdmin4, Linux, Centos, PostgreSQL
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

pgAdmin4 是一个用于管理和维护 PostgreSQL 数据库的强大工具。它提供了一个图形化界面，使用户能够轻松地连接到数据库、创建表、运行 SQL 语句以及执行其他数据库管理任务。

##### 1、yum 安装

```bash
# 临时修改为 permissive，同时 selinux 配置改为 disabled，下次重启服务器后会生效
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# 添加 pgAdmin 存储库
wget --no-check-certificate https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/pgadmin4-redhat-repo-2-1.noarch.rpm

rpm -ivh pgadmin4-redhat-repo-2-1.noarch.rpm

# centos7 及以下系统版本需要修改存储库地址
sed -i 's|ftp.postgresql.org/pub/pgadmin|pgadmin-archive.postgresql.org|' /etc/yum.repos.d/pgadmin4.repo

# 查询可以安装的软件
yum -y search pgadmin

# 安装 web 端软件
yum -y install pgadmin4-web

# 修改默认端口 80 为 18080
vim /etc/httpd/conf/httpd.conf

# 执行配置脚本，根据提示配置账号密码
/usr/pgadmin4/bin/setup-web.sh

# 访问服务
http://192.168.216.131:18080/pgadmin4/login
```

##### 2、配置代理

使用 nginx 代理访问

```nginx
        location /pgadmin4 {
            proxy_pass http://192.168.216.131:18080;
            proxy_set_header Host $host:$server_port;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
```

