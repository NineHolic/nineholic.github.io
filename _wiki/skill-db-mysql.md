---
layout: wiki
title: MySQL
cate1: Skill
cate2: DB
description: MySQL 常用命令
keywords: MySQL, Linux, Skill, DB
---

##### 重置密码

```bash
# 安全模式启动
mysqld_safe --skip-grant-tables &

# 登录
mysql -u root

# 刷新权限表
FLUSH PRIVILEGES;

# 执行密码修改
ALTER USER 'root'@'%' IDENTIFIED BY 'root1234!';
exit
```

