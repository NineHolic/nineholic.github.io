---
layout: post
title: MongoDB 的安装与使用
categories: [DB]
description: MongoDB 的安装与简单配置
keywords: MongoDB, Linux, Centos
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

MongoDB 是免费开源的跨平台 NoSQL 数据库，命名源于英文单词 humongous，意思是「巨大无比」。与关系型数据库不同，MongoDB 的数据以类似于 JSON 格式的二进制文档存储

##### 1、官方源安装

官方文档：[https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-red-hat/](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-red-hat/)

```bash
# 设置官方安装源
vim /etc/yum.repos.d/mongodb-org-4.4.repo

# 写入以下内容
[mongodb-org-4.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc

# 安装 4.4 最新稳定版
yum install -y mongodb-org

# 安装指定版本
yum install -y mongodb-org-4.4.13

# 启动MongoDB
systemctl start mongod

# 设置开机自启
systemctl enable mongod
```

| 包名               | 描述                                                         |
| ------------------ | :----------------------------------------------------------- |
| mongodb-org        | 一个将自动安装以下四个组件包的组合包                         |
| mongodb-org-server | 包含mongod守护程序，关联的init脚本和配置文件（/etc/mongod.conf）。您可以使用初始化脚本从mongod配置文件开始 |
| mongodb-org-mongos | 包含mongos守护进程                                           |
| mongodb-org-shell  | 包含mongoshell                                               |
| mongodb-org-tools  | 包含以下的MongoDB工具：mongoimport bsondump, mongodump, mongoexport, mongofiles, mongorestore, mongostat, 和 mongotop |

##### 2、修改配置

```bash
# 连接
mongo localhost:27017

# 进入 admin 数据库
use admin

# 创建root用户
db.createUser({ user: "root", pwd: "db123456", roles: [{ role: "userAdminAnyDatabase", db: "admin" }] })

# 测试密码
db.auth('root','db123456')
```

修改配置文件：`vim /etc/mongod.conf`

```yaml
# 开启密码验证
security:
  authorization: enabled

# 修改默认端口，仅允许本机IP进行连接
net:
  port: 27027
  bindIp: 127.0.0.1,192.168.159.138
```

```shell
# 重启服务
systemctl restart mongod

# 登录测试
mongo -uroot 192.168.159.138:27027/admin -p

# 用户查询
db.system.users.find()

# 创建数据库
use test

## 创建 sr_db 数据库的用户
db.createUser({ user: "db_user", pwd: "db123456", roles: [{ role: "readWrite", db: "test_db" }] })

# 删除用户
use test
db.dropUser('test_db')
```

##### 3、导入导出

```shell
# 备份
mongodump -h 192.168.159.138:27027 -u db_user -p=db123456 -d test_db -o /root/mongodb_bak/$(date +%Y%m%d) --authenticationDatabase test

# 恢复
mongorestore -h 192.168.159.138:27027 -u db_user -p=db123456 -d test_db --drop --authenticationDatabase test /root/sr_db/
```

> --drop 用于指定，恢复是如果对应数据库或者 colleciton 存在，则先删除然后在恢复

定时备份脚本：`00 03 * * * /bin/bash /root/mongodb_bak/export_mongodb.sh >> /root/mongodb_bak/crontab.log 2>&1`

```shell
#!/bin/bash

echo start export in $(date +'%F %T')

# 导出数据库
mongodump -h 192.168.159.138:27027 -u db_user -p=db123456 -d test_db -o /root/mongodb_bak/$(date +%Y%m%d) --authenticationDatabase test

# 删除 30 天前的目录
find /root/mongodb_bak -mindepth 1 -maxdepth 1 -type d -mtime +30 -exec rm -rfv {} \;

echo end export in $(date +'%F %T')
```

##### 4、登录报错

输入正确的密码后无法登录，报错如下

![image-20220607235645573](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20220607235645573.png)

这是因为 SELinux 当前为`enforcing`模式，可改为`disabled`后重启服务器即可：`vim /etc/selinux/config`

![image-20220608000038638](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20220608000038638.png)

或者采用官网文档进行配置

[https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-red-hat/#configure-selinux](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-red-hat/#configure-selinux)

