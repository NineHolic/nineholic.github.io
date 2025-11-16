---
layout: post
title: Oracle 11g 修改字符集
categories: [DB]
description: 字符集的修改
keywords: Oracle, Linux, Centos
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

选择静默安装的安装字符集为默认的 ZHS16GBK，修改后的字符集为 AL32UTF8

```bash
# 登录 Oracle
sqlplus / as sysdba

# 关闭数据库，修改字符集
SQL> shutdown immediate;
SQL> STARTUP MOUNT;
SQL> ALTER SESSION SET SQL_TRACE=TRUE;
SQL> ALTER SYSTEM ENABLE RESTRICTED SESSION;
SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES=0;
SQL> ALTER SYSTEM SET AQ_TM_PROCESSES=0;
SQL> ALTER DATABASE OPEN;
SQL> ALTER DATABASE character set INTERNAL_USE AL32UTF8;
SQL> ALTER SESSION SET SQL_TRACE=FALSE;
SQL> shutdown immediate;
SQL> startup;

# 查看当前字符集
SQL> select userenv('language') from dual;
 
USERENV('LANGUAGE')
----------------------------------------------------
AMERICAN_AMERICA.AL32UTF8
 
# 查看变更记录
SQL> SELECT parameter, value FROM v$nls_parameters WHERE parameter LIKE '%CHARACTERSET';
 
PARAMETER
----------------------------------------------------------------
VALUE
----------------------------------------------------------------
NLS_CHARACTERSET
AL32UTF8
 
NLS_NCHAR_CHARACTERSET
AL16UTF16
```
