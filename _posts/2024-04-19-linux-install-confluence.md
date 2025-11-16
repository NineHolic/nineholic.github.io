---
layout: post
title: Confluence 的安装与使用
categories: [Confluence]
description: Confluence 的安装与使用
keywords: Confluence, Linux
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

Confluence 是由 Atlassian 公司推出的一款企业级团队协作与知识管理工具。它是一个团队协作空间，将知识与协作无缝融合，让团队能够在一个平台上创建、协作和组织所有工作。

##### 1、安装部署

```bash
# 禁用 selinux 后重启服务器
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# 新建安装目录
mkdir -p /data/confluence/wiki/data && chmod 777 /data/confluence/wiki/data

# 保证当前目录下存在 docker-compose.yml，根据配置启动服务
docker compose up -d

# 查看日志
docker logs --tail 300 -f confluence

# 访问服务：http://192.168.216.131:18090
点击 Next -> License key 页面记录下 Server ID
```

`docker-compose.yml`内容如下：

```ini
services:
  mysql8-confluence:
    image: mysql:8.0
    container_name: mysql8-confluence
    ports:
      - 3308:3306
    volumes:
      - /data/confluence/wiki/mysql/conf.d:/etc/mysql/conf.d
      - /data/confluence/wiki/mysql/data:/var/lib/mysql
    security_opt: 
      - seccomp:unconfined
    environment:
      TZ: Asia/Shanghai
      MYSQL_ROOT_PASSWORD: 'root1234!'
    command: --default-authentication-plugin=mysql_native_password --lower-case-table-names=1

  confluence:
    image: atlassian/confluence:7.9.0
    container_name: confluence
    environment:
      TZ: Asia/Shanghai
    ports:
      - 18090:8090
    volumes:
      - /data/confluence/wiki/data:/var/atlassian/confluence
```

##### 2、环境配置

```bash
# 进入 mysql 容器中
docker exec -it mysql8-confluence bash

# 登录 mysql
mysql -uroot -p

# 创建数据库
CREATE DATABASE confluence CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
quit
exit

# 网页下载插件
https://flynine.lanzoul.com/iziJq3b9sumj

# 复制插件到容器 confluence 中
docker cp atlassian-agent.jar confluence:/home/

# 修改环境变量脚本，增加一行配置
docker cp confluence:/opt/atlassian/confluence/bin/setenv.sh .
vim setenv.sh

CATALINA_OPTS="-javaagent:/home/atlassian-agent.jar ${CATALINA_OPTS}"

docker cp setenv.sh confluence:/opt/atlassian/confluence/bin/

# 下载 mysql 驱动
wget https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-j-9.5.0.tar.gz

# 解压，复制 jar 包到容器中
tar -zxvf mysql-connector-j-9.5.0.tar.gz
docker cp mysql-connector-j-9.5.0/mysql-connector-j-9.5.0.jar confluence:/opt/atlassian/confluence/confluence/WEB-INF/lib

# 重启容器
docker restart confluence

# 有打印 agent working 则说明插件加载成功
docker logs --tail 100 -f confluence

# 重启容器
docker restart confluence

# 有打印 agent working 则说明破解插件加载成功
docker logs --tail 300 -f confluence

# 根据上面记录的 Server ID 来生成授权码
docker exec -it confluence bash -c "java -jar /home/atlassian-agent.jar -p conf -m test.com -m test -o http://192.168.216.131:18090 -s BRJ3-T8L7-J5M3-UIZH"

# 刷新网页：http://192.168.216.131:18090
填入上面生成的 license code —> 选择 My own database -> 选择 MySQL，Setup type 选择 By connection string：jdbc:mysql://192.168.216.131:3308/confluence?useUnicode=true&zeroDateTimeBehavior=convertToNull&characterEncoding=UTF-8&useSSL=false&sessionVariables=transaction_isolation='READ-COMMITTED'
用户名 root，密码在 docker-compose.yml 中有写明，填写后 Test connection，成功后 Next，等待设置完成 -> 选择 empty site -> 设置账号
```

**参考**

- [Atlassian系列产品及插件激活方法 JIRA8.19.0+](https://zhile.io/2018/12/20/atlassian-license-crack.html)

